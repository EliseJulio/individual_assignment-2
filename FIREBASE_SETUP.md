# Firebase Setup Guide for BookSwap App

## Quick Setup Steps

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Name it "bookswap-app" (or your preferred name)
4. Enable Google Analytics (optional)

### 2. Enable Authentication
1. In Firebase Console, go to **Authentication**
2. Click **Get started**
3. Go to **Sign-in method** tab
4. Enable **Email/Password** provider
5. Save changes

### 3. Create Firestore Database
1. Go to **Firestore Database**
2. Click **Create database**
3. Choose **Start in test mode** (for development)
4. Select your preferred location
5. Click **Done**

### 4. Add Web App
1. In Project Overview, click the **Web** icon (`</>`)
2. Register app with nickname "bookswap-web"
3. **Copy the Firebase configuration object**
4. Click **Continue to console**

### 5. Update Firebase Configuration
Replace the demo configuration in `lib/firebase_options.dart` with your actual Firebase config:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_API_KEY',
  appId: 'YOUR_APP_ID', 
  messagingSenderId: 'YOUR_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
);
```

### 6. Security Rules (Optional for Production)
In Firestore Database > Rules, update to:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read/write their own data
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 7. Test the App
1. Run `flutter pub get`
2. Run `flutter run -d chrome` for web testing
3. Register a new user and verify email functionality

## Troubleshooting

### White Screen Issue
- Ensure Firebase configuration is correct
- Check browser console for errors
- Verify all Firebase services are enabled

### Email Verification Not Working
- Check spam folder
- Ensure Authentication is properly configured
- Verify domain settings in Firebase Auth

### Firestore Permission Errors
- Update security rules to allow authenticated access
- Check user authentication status

## Demo Data
For testing, you can add sample books directly in Firestore Console:
1. Go to Firestore Database
2. Create collection "books"
3. Add documents with fields: title, author, condition, imageUrl, ownerId, ownerEmail, createdAt, status

Your app should now work properly with real Firebase backend!