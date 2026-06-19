<div align="center">

# 🩺 DermSight
### AI-Powered Skin Disease Detection & Medical Report Generation System

<img src="https://img.shields.io/badge/Flutter-Mobile-blue?style=for-the-badge&logo=flutter">
<img src="https://img.shields.io/badge/Python-Flask-green?style=for-the-badge&logo=python">
<img src="https://img.shields.io/badge/MongoDB-Database-success?style=for-the-badge&logo=mongodb">
<img src="https://img.shields.io/badge/Deep%20Learning-EfficientNetV2-red?style=for-the-badge">
<img src="https://img.shields.io/badge/NLP-Logistic%20Regression-orange?style=for-the-badge">
<img src="https://img.shields.io/badge/Status-Completed-brightgreen?style=for-the-badge">

---

### 🚀 Intelligent Skin Disease Detection Using Artificial Intelligence

*Detect • Predict • Analyze • Generate Medical Reports*

</div>

---

# 📖 Overview

**DermSight** is an AI-powered healthcare application that assists users in identifying skin diseases using **computer vision** and **natural language processing** technologies.

The application enables users to either:

📷 Upload an image of the affected skin area

or

📝 Enter symptoms manually

The AI system then predicts the most probable skin disease, generates a confidence score, and produces an informative medical report including symptoms, causes, precautions, and treatment recommendations.

DermSight integrates:

- 📱 Flutter Mobile Application
- ⚙️ Flask REST API
- 🧠 Deep Learning Image Classification
- 💬 NLP-Based Symptom Analysis
- 🍃 MongoDB Database

creating a complete intelligent healthcare ecosystem.

---

# ✨ Key Features

## 📸 Image-Based Disease Detection

- Upload or capture skin images
- AI-powered disease prediction
- Confidence percentage
- Disease description
- Recommended precautions
- Suggested treatments

---

## 💬 Symptom-Based Disease Prediction

Users can simply enter symptoms such as:

> itching, redness, dry skin, burning sensation

The NLP engine performs:

- Text Cleaning
- Tokenization
- TF-IDF Vectorization
- Disease Classification

---

## 🤖 AI Medical Report Generation

Automatically generates a detailed medical report containing:

- Disease Name
- Prediction Confidence
- Symptoms
- Possible Causes
- Preventive Measures
- Treatment Suggestions

---

## 👤 User Authentication

- Secure Registration
- Login
- User Profiles
- Prediction History
- Medical Report Storage

---

## 🗄 Database Management

MongoDB stores:

- User Information
- Prediction History
- Disease Reports
- Generated Reports
- Login Credentials

---

# 🏗 System Architecture

```text
                  📱 Flutter Mobile App
                           │
                           │
                 REST API Requests
                           │
                           ▼
                 ⚙ Flask Backend Server
                 ├─────────────────────┐
                 │                     │
                 ▼                     ▼
      🧠 Image Prediction       💬 Symptom Prediction
      EfficientNetV2-S         Logistic Regression
                 │                     │
                 └────────────┬────────┘
                              ▼
                   AI Report Generator
                              │
                              ▼
                     🍃 MongoDB Database
```

---

# 🧠 Machine Learning Models

## Image Classification Model

| Property | Value |
|----------|--------|
| Architecture | EfficientNetV2-S |
| Transfer Learning | ✅ |
| Framework | PyTorch |
| Number of Classes | 10 |
| Image Size | 224 × 224 |
| Optimizer | Adam |
| Loss Function | Cross Entropy Loss |

---

## NLP Model

| Property | Value |
|----------|--------|
| Algorithm | Logistic Regression |
| Feature Extraction | TF-IDF |
| Text Processing | Tokenization |
| Library | Scikit-learn |

---

# 📊 Model Performance

## 🖼 Image Classification

| Metric | Score |
|---------|-------|
| Accuracy | **83.81%** |
| Balanced Accuracy | **81.85%** |
| Macro F1 Score | **80.09%** |
| Weighted F1 Score | **84.11%** |

---

## 💬 Symptom Prediction Pipeline

```
Input Symptoms
      │
      ▼
Text Cleaning
      │
      ▼
Tokenization
      │
      ▼
TF-IDF Vectorization
      │
      ▼
Logistic Regression
      │
      ▼
Disease Prediction
```

---

# 🦠 Supported Skin Diseases

| Disease |
|----------|
| Eczema |
| Warts, Molluscum & Viral Infections |
| Melanoma |
| Atopic Dermatitis |
| Basal Cell Carcinoma (BCC) |
| Melanocytic Nevi (NV) |
| Benign Keratosis-like Lesions (BKL) |
| Psoriasis & Lichen Planus |
| Seborrheic Keratoses |
| Ringworm, Candidiasis & Fungal Infections |

---

# 💻 Technology Stack

## Frontend

- Flutter
- Dart

---

## Backend

- Python
- Flask
- REST APIs

---

## Machine Learning

- PyTorch
- EfficientNetV2-S
- Transfer Learning
- Scikit-learn
- Logistic Regression
- TF-IDF

---

## Database

- MongoDB

---

## Tools

- VS Code
- Android Studio
- Git
- GitHub

---

# 📂 Project Structure

```
DermSight/
│
├── frontend/
│     ├── lib/
│     ├── assets/
│     └── pubspec.yaml
│
├── backend/
│     ├── app.py
│     ├── routes/
│     ├── models/
│     ├── utils/
│     └── requirements.txt
│
├── ml_models/
│     ├── image_model.pth
│     ├── symptom_model.pkl
│     └── tfidf_vectorizer.pkl
│
├── database/
│
├── README.md
│
└── LICENSE
```

---

# ⚙ Installation

## Clone Repository

```bash
git clone https://github.com/yourusername/DermSight.git

cd DermSight
```

---

## Install Backend

```bash
cd backend

pip install -r requirements.txt

python app.py
```

---

## Install Flutter App

```bash
cd frontend

flutter pub get

flutter run
```

---

## MongoDB

Configure your MongoDB connection string inside the Flask configuration file.

Example:

```python
MONGO_URI = "mongodb://localhost:27017/dermsight"
```

---

# 📱 Application Workflow

```
User

│

├── Upload Image
│       │
│       ▼
│  AI Image Model
│       │
│       ▼
│ Disease Prediction
│
└── Enter Symptoms
        │
        ▼
 NLP Model
        │
        ▼
 Disease Prediction

            │
            ▼

 Medical Report Generation

            │

            ▼

 Results Stored in MongoDB

            │

            ▼

 Displayed in Flutter App
```

---

# 🚀 Future Enhancements

- 👨‍⚕ Doctor Consultation
- 📅 Appointment Booking
- ☁ Cloud Deployment
- 🌍 Multi-language Support
- 📈 Disease Severity Detection
- 🤖 AI Chatbot
- 🧬 Personalized Healthcare Recommendations
- 📊 Analytics Dashboard
- 🛰 Telemedicine Integration
- 📤 PDF Medical Report Export

---

# 📸 Screenshots

> Add screenshots of your application here.

```
Home Screen

Prediction Screen

Medical Report

Profile Screen

History Screen
```

---

# 🔒 Security

- Secure Authentication
- REST API Validation
- Database Protection
- Encrypted User Data
- Prediction History Management

---

# 🤝 Contributing

Contributions are always welcome.

1. Fork the repository

2. Create your feature branch

```bash
git checkout -b feature/NewFeature
```

3. Commit your changes

```bash
git commit -m "Added New Feature"
```

4. Push

```bash
git push origin feature/NewFeature
```

5. Open a Pull Request

---

# 📄 License

This project is licensed under the **MIT License**.

---

# ⚠ Disclaimer

**DermSight** is developed for **educational, research, and demonstration purposes** only.

The predictions generated by this application are based on artificial intelligence models and should **not** be considered a substitute for professional medical diagnosis, treatment, or clinical decision-making. Users are strongly encouraged to consult a qualified healthcare professional for accurate diagnosis and appropriate medical advice.

---

<div align="center">

## ⭐ If you found this project useful, consider giving it a Star!

Made with ❤️ using Flutter, Flask, PyTorch & Artificial Intelligence

</div>