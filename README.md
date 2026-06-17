# DermSight - AI Powered Skin Disease Detection System

## Overview

DermSight is an AI-powered mobile healthcare application designed to assist users in identifying skin diseases through image analysis and symptom-based prediction. The application combines Deep Learning and Natural Language Processing (NLP) techniques to provide accurate disease classification and generate informative medical reports.

The system consists of a Flutter mobile application, a Flask backend API, MongoDB database, and Machine Learning models for image and symptom analysis.

---

## Features

### Image-Based Skin Disease Detection

* Upload or capture skin images using the mobile app.
* Deep Learning model predicts skin disease from the uploaded image.
* Confidence score for each prediction.
* Disease information and recommendations.

### Symptom-Based Disease Prediction

* Users can enter symptoms manually.
* NLP preprocessing extracts meaningful information.
* Logistic Regression model predicts the most likely skin condition.

### AI Medical Report Generation

* Generates detailed disease reports.
* Displays symptoms, causes, precautions, and treatment suggestions.
* User-friendly healthcare insights.

### User Management

* User Registration and Login.
* Secure user profile management.
* Prediction history storage.

### Database Integration

* MongoDB stores:

  * User details
  * Prediction records
  * Medical reports
  * History data

---

## Technology Stack

### Frontend

* Flutter
* Dart

### Backend

* Python Flask
* REST APIs

### Database

* MongoDB

### Machine Learning

#### Image Classification Model

* EfficientNetV2-S
* Transfer Learning
* Trained on 10 Skin Disease Classes

#### NLP Model

* TF-IDF Vectorization
* Logistic Regression

---

## Supported Diseases

1. Eczema
2. Warts Molluscum and other Viral Infections
3. Melanoma
4. Atopic Dermatitis
5. Basal Cell Carcinoma (BCC)
6. Melanocytic Nevi (NV)
7. Benign Keratosis-like Lesions (BKL)
8. Psoriasis, Lichen Planus and Related Diseases
9. Seborrheic Keratoses and Other Benign Tumors
10. Tinea Ringworm, Candidiasis and Other Fungal Infections

---

## Project Architecture

Flutter App
↓
Flask REST API
↓
AI Models (EfficientNetV2-S + Logistic Regression)
↓
MongoDB Database

---

## Model Performance

### Image Classification Model

* Architecture: EfficientNetV2-S
* Classes: 10
* Accuracy: 83.81%
* Balanced Accuracy: 81.85%
* Macro F1 Score: 80.09%
* Weighted F1 Score: 84.11%

### Symptom Classification Model

* Algorithm: Logistic Regression
* NLP Pipeline:

  * Text Cleaning
  * Tokenization
  * TF-IDF Vectorization
  * Classification

---

## Installation

### Clone Repository

```bash
git clone https://github.com/your-username/DermProject.git
cd DermProject
```

### Flutter Frontend

```bash
flutter pub get
flutter run
```

### Flask Backend

```bash
pip install -r requirements.txt
python app.py
```

### MongoDB

Configure MongoDB connection string inside the backend configuration file.

---

## Future Enhancements

* Doctor Consultation Module
* Appointment Booking System
* Multi-language Support
* Cloud Deployment
* Real-Time AI Chat Assistant
* Disease Severity Analysis


## Disclaimer

This application is intended for educational and research purposes only. It is not a substitute for professional medical diagnosis, treatment, or healthcare advice. Always consult a qualified healthcare professional for medical concerns.
