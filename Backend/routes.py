from flask import Blueprint, request, jsonify
from extensions import mongo, bcrypt
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from datetime import datetime
from bson import ObjectId
import base64
import numpy as np
from PIL import Image
from torchvision import transforms
import io
import torch
import timm
import torch.nn as nn


image_model = None
nlp_model = None
vectorizer = None



class DermNetClassifier(nn.Module):

    def __init__(self, num_classes=10, dropout=0.4):
        super().__init__()

        self.backbone = timm.create_model(
            "tf_efficientnetv2_s",
            pretrained=False,
            num_classes=0,
            global_pool=""
        )

        in_features = self.backbone.num_features

        self.pool = nn.AdaptiveAvgPool2d(1)

        self.head = nn.Sequential(
            nn.Flatten(),
            nn.BatchNorm1d(in_features),
            nn.Dropout(dropout),

            nn.Linear(in_features, 512),
            nn.BatchNorm1d(512),
            nn.GELU(),
            nn.Dropout(dropout * 0.5),

            nn.Linear(512, 256),
            nn.BatchNorm1d(256),
            nn.GELU(),
            nn.Dropout(dropout * 0.25),

            nn.Linear(256, num_classes),
        )

    def forward(self, x):
        feats = self.backbone.forward_features(x)
        feats = self.pool(feats)
        return self.head(feats)

NUM_CLASSES = 10

image_model = None

def get_image_model():
    global image_model

    if image_model is None:

        model = DermNetClassifier(
            num_classes=NUM_CLASSES,
            dropout=0.4
        )

        checkpoint = torch.load(
            "best_model.pth",
            map_location="cpu"
        )

        model.load_state_dict(
            checkpoint["state_dict"]
        )

        model.eval()

        image_model = model

        print("Model Loaded Successfully")

    return image_model

with open("classes.txt", "r") as f:
    classes = [
        line.strip().split(". ", 1)[1]
        if ". " in line else line.strip()
        for line in f.readlines()
    ]

main = Blueprint('main', __name__)

import pickle

nlp_model = None
vectorizer = None

def get_nlp_model():
    global nlp_model

    if nlp_model is None:
        with open("nlp_model.pkl", "rb") as f:
            nlp_model = pickle.load(f)

    return nlp_model


def get_vectorizer():
    global vectorizer

    if vectorizer is None:
        with open("vectorizer.pkl", "rb") as f:
            vectorizer = pickle.load(f)

    return vectorizer

# ---------------- REGISTER ----------------
@main.route('/register', methods=['POST'])
def register():
    data = request.json

    if mongo.db.users.find_one({"email": data['email']}):
        return jsonify({"msg": "User already exists"}), 400

    hashed_pw = bcrypt.generate_password_hash(data['password']).decode('utf-8')

    mongo.db.users.insert_one({
        "name": data['name'],
        "email": data['email'],
        "age": data['age'],
        "password": hashed_pw
    })

    return jsonify({"msg": "User registered"})


# ---------------- LOGIN ----------------
@main.route('/login', methods=['POST'])
def login():
    data = request.json
    user = mongo.db.users.find_one({"email": data['email']})

    if user and bcrypt.check_password_hash(user['password'], data['password']):
        token = create_access_token(identity=str(user['_id']))
        return jsonify({"token": token})

    return jsonify({"msg": "Invalid credentials"}), 401

#----------google login---------------
@main.route('/google-login', methods=['POST'])
def google_login():
    data = request.json

    email = data.get("email")
    name = data.get("name")

    if not email:
        return jsonify({"msg": "Email required"}), 400

    # Check if user exists
    user = mongo.db.users.find_one({"email": email})

    if not user:
        #  Create new user (NO PASSWORD)
        new_user = {
            "name": name,
            "email": email,
            "age": None,
            "password": None,  
            "provider": "google"
        }

        result = mongo.db.users.insert_one(new_user)
        user_id = str(result.inserted_id)

    else:
        user_id = str(user["_id"])

    # Create JWT token
    token = create_access_token(identity=user_id)

    return jsonify({
        "token": token,
        "msg": "Google login success"
    })


# ---------------- combine ANALYZE ----------------
@main.route('/analyze-combined', methods=['POST'])
@jwt_required()
def analyze_combined():

    try:

        print("COMBINED STEP 1")

        text = request.form.get("text", "").strip()

        if not text:
            return jsonify({"error": "Text is required"}), 400

        print("COMBINED STEP 2")

        if 'image' not in request.files:
            return jsonify({"error": "Image is required"}), 400

        file = request.files['image']

        print("COMBINED STEP 3")

        # =========================
        # IMAGE
        # =========================

        image = Image.open(file).convert("RGB")

        transform = transforms.Compose([
            transforms.Resize((384, 384)),
            transforms.ToTensor(),
            transforms.Normalize(
                mean=[0.485, 0.456, 0.406],
                std=[0.229, 0.224, 0.225]
            )
        ])

        image_tensor = transform(image).unsqueeze(0)

        print("COMBINED STEP 4")

        with torch.no_grad():

            image_model = get_image_model()

            print("COMBINED STEP 5")

            outputs = image_model(image_tensor)

            print("COMBINED STEP 6")

            probs = torch.softmax(outputs, dim=1)

            img_confidence = float(torch.max(probs).item() * 100)

            img_index = int(torch.argmax(probs).item())

        image_prediction = classes[img_index]

        print("COMBINED STEP 7")

        # =========================
        # TEXT
        # =========================

        nlp_model = get_nlp_model()

        print("COMBINED STEP 8")

        vectorizer = get_vectorizer()

        print("COMBINED STEP 9")

        x = vectorizer.transform([text])

        print("COMBINED STEP 10")

        text_prediction = nlp_model.predict(x)[0]

        text_probs = nlp_model.predict_proba(x)[0]

        text_confidence = float(np.max(text_probs) * 100)

        print("COMBINED STEP 11")

        # =========================
        # FINAL DECISION
        # =========================

        if image_prediction == text_prediction:

            final_prediction = image_prediction

            final_confidence = min(
                (img_confidence + text_confidence) / 2 + 10,
                99.99
            )

        else:

            if img_confidence >= text_confidence:
                final_prediction = image_prediction
                final_confidence = img_confidence
            else:
                final_prediction = text_prediction
                final_confidence = text_confidence

        print("COMBINED STEP 12")

        if final_prediction in [
            "Melanoma",
            "Basal Cell Carcinoma (BCC)"
        ]:
            severity = "High"

        elif final_prediction in [
            "Psoriasis pictures Lichen Planus and related diseases",
            "Atopic Dermatitis",
            "Tinea Ringworm Candidiasis and other Fungal Infections"
        ]:
            severity = "Medium"

        else:
            severity = "Low"

        print("COMBINED STEP 13")

        return jsonify({
            "final_prediction": final_prediction,
            "final_confidence": round(final_confidence, 2),
            "image_prediction": image_prediction,
            "image_confidence": round(img_confidence, 2),
            "text_prediction": text_prediction,
            "text_confidence": round(text_confidence, 2),
            "severity": severity,
            "advice": ADVICE.get(
                final_prediction,
                "Consult a dermatologist."
            )
        }), 200

    except Exception as e:

        print("COMBINED ERROR:", str(e))

        return jsonify({
            "error": str(e)
        }), 500

# ---------------- SAVE SCAN ----------------
@main.route('/save-scan', methods=['POST'])
@jwt_required()
def save_scan():

    user_id = get_jwt_identity()
    data = request.json

    mongo.db.scans.insert_one({
    "user_id": user_id,

    "text": data.get("text"),
    "image": data.get("image"),

    "final_prediction": data.get("final_prediction"),
    "final_confidence": data.get("final_confidence"),

    "image_prediction": data.get("image_prediction"),
    "image_confidence": data.get("image_confidence"),

    "text_prediction": data.get("text_prediction"),
    "text_confidence": data.get("text_confidence"),

    "severity": data.get("severity"),
    "advice": data.get("advice"),

    "date": datetime.utcnow()
})

    return jsonify({"msg": "Scan saved successfully"})

# ---------------- HISTORY ----------------
@main.route('/history', methods=['GET'])
@jwt_required()
def history():

    user_id = get_jwt_identity()

    scans = list(mongo.db.scans.find(
        {"user_id": user_id},
       {
    "_id": 0,

    "text": 1,
    "image": 1,

    "final_prediction": 1,
    "final_confidence": 1,

    "image_prediction": 1,
    "image_confidence": 1,

    "text_prediction": 1,
    "text_confidence": 1,

    "severity": 1,
    "advice": 1,

    "date": 1
}
    ).sort("date", -1))

    for scan in scans:
        if "date" in scan:
          scan["date"] = scan["date"].isoformat()

    return jsonify(scans)


# ---------------- PROFILE ----------------
@main.route('/profile', methods=['GET'])
@jwt_required()
def profile():
    user_id = get_jwt_identity()

    user = mongo.db.users.find_one(
        {"_id": ObjectId(user_id)},
        {"password": 0}
    )

    if not user:
        return jsonify({"msg": "User not found"}), 404

    user['_id'] = str(user['_id'])

    return jsonify(user)


# ---------------- UPDATE PROFILE ----------------
@main.route('/update-profile', methods=['PUT'])
@jwt_required()
def update_profile():
    user_id = get_jwt_identity()
    data = request.json

    update_data = {}

    if data.get("name"):
        update_data["name"] = data.get("name")

    # 🔹 EMAIL
    if data.get("email"):
        update_data["email"] = data.get("email")

    # 🔹 AGE
    if data.get("age"):
        update_data["age"] = data.get("age")

    # 🔹 PASSWORD (OPTIONAL)
    if data.get("password"):
        hashed_pw = bcrypt.generate_password_hash(
            data.get("password")
        ).decode('utf-8')

        update_data["password"] = hashed_pw

    # UPDATE DATABASE
    mongo.db.users.update_one(
        {"_id": ObjectId(user_id)},
        {"$set": update_data}
    )

    return jsonify({"msg": "Profile updated"})

#----------for text---------------

ADVICE = {
    "Eczema": "Use moisturizer and avoid harsh soaps.",
    "Melanoma": "Consult a dermatologist immediately.",
    "Atopic Dermatitis": "Keep skin hydrated and avoid irritants.",
    "Basal Cell Carcinoma (BCC)": "Seek professional medical evaluation.",
    "Melanocytic Nevi (NV)": "Monitor any changes in size, shape, or color.",
    "Benign Keratosis-like Lesions (BKL)": "Usually benign but consult a dermatologist if concerned.",
    "Psoriasis pictures Lichen Planus and related diseases":
        "Keep skin moisturized and avoid triggers.",
    "Seborrheic Keratoses and other Benign Tumors":
        "Generally harmless but monitor for changes.",
    "Tinea Ringworm Candidiasis and other Fungal Infections":
        "Keep the area dry and use antifungal treatment.",
    "Warts Molluscum and other Viral Infections":
        "Avoid scratching and consult a dermatologist if spreading."
}

@main.route('/analyze-text', methods=['POST'])
@jwt_required()
def analyze_text():

    try:

        data = request.get_json()

        text = data.get("text", "").strip()

        if not text:
            return jsonify({
                "error": "Text is required"
            }), 400

        print("STEP 1")

        model = get_nlp_model()

        print("STEP 2")

        vec = get_vectorizer()

        print("STEP 3")

        x = vec.transform([text])

        print("STEP 4")

        prediction = model.predict(x)[0]

        print("STEP 5")

        probs = model.predict_proba(x)[0]

        print("STEP 6")

        confidence = float(np.max(probs) * 100)

        if prediction in [
            "Melanoma",
            "Basal Cell Carcinoma (BCC)"
        ]:
            severity = "High"

        elif prediction in [
            "Psoriasis pictures Lichen Planus and related diseases",
            "Atopic Dermatitis",
            "Tinea Ringworm Candidiasis and other Fungal Infections"
        ]:
            severity = "Medium"

        else:
            severity = "Low"

        return jsonify({
            "prediction": prediction,
            "confidence": round(confidence, 2),
            "severity": severity,
            "advice": ADVICE.get(
                prediction,
                "Consult a dermatologist."
            )
        }), 200

    except Exception as e:

        print("ANALYZE TEXT ERROR:", str(e))

        return jsonify({
            "error": str(e)
        }), 500

#----------------------for image-------------------
@main.route('/analyze-image', methods=['POST'])
@jwt_required()
def analyze_image():

    if 'image' not in request.files:
        return jsonify({"error": "No image file provided"}), 400

    file = request.files['image']

    try:

        image = Image.open(file).convert("RGB")

        transform = transforms.Compose([
            transforms.Resize((384, 384)),
            transforms.ToTensor(),
            transforms.Normalize(
                mean=[0.485, 0.456, 0.406],
                std=[0.229, 0.224, 0.225]
            )
        ])

        image_tensor = transform(image).unsqueeze(0)

        with torch.no_grad():
            model = get_image_model()
            outputs = model(image_tensor)
            # outputs = image_model(image_tensor)

            probs = torch.softmax(outputs, dim=1)

            confidence = float(torch.max(probs).item() * 100)

            class_index = int(torch.argmax(probs).item())

        prediction = classes[class_index]

        if prediction in [
            "Melanoma",
            "Basal Cell Carcinoma (BCC)"
        ]:
            severity = "High"

        elif prediction in [
            "Psoriasis pictures Lichen Planus and related diseases",
            "Atopic Dermatitis",
            "Tinea Ringworm Candidiasis and other Fungal Infections"
        ]:
            severity = "Medium"

        else:
            severity = "Low"

        return jsonify({
            "prediction": prediction,
            "confidence": round(confidence, 2),
            "severity": severity,
            "advice": ADVICE.get(
                prediction,
                "Consult a dermatologist."
            )
        })

    except Exception as e:
        return jsonify({
            "error": str(e)
        }), 500