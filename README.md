# BookSwap App

A Flutter mobile application that allows students to list textbooks and initiate swap offers with other users. Built with Firebase for authentication, real-time data sync, and cloud storage.

## Features

### Authentication
- Email/password authentication with Firebase Auth
- Email verification requirement
- Secure user sessions

### Book Management (CRUD)
- **Create**: Add books with title, author, condition, and cover image
- **Read**: Browse all available book listings
- **Update**: Edit your own book listings
- **Delete**: Remove your book listings

### Swap System
- Request swaps on available books
- Real-time status updates (Pending, Accepted, Rejected)
- Automatic book status management
- Separate views for sent and received offers

### Chat System (Bonus)
- Real-time messaging between users
- Chat initiation after swap offers
- Message history and timestamps

### Navigation
- Bottom navigation with 4 main sections:
  - Browse Listings
  - My Books (with tabs for books, sent offers, received offers)
  - Chats
  - Settings

### Settings
- User profile information
- Notification preferences (simulated)
- App information and help

## Technology Stack

- **Frontend**: Flutter with Material Design
- **Backend**: Firebase (Firestore, Auth, Storage)
- **State Management**: Provider pattern
- **Real-time Updates**: Firestore listeners
- **Image Handling**: Network images with error handling

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── book.dart
│   ├── swap_offer.dart
│   └── chat_message.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   ├── book_provider.dart
│   ├── swap_provider.dart
│   └── chat_provider.dart
├── screens/                  # UI screens
│   ├── auth_wrapper.dart
│   ├── auth_screen.dart
│   ├── email_verification_screen.dart
│   ├── home_screen.dart
│   ├── browse_listings_screen.dart
│   ├── my_listings_screen.dart
│   ├── add_book_screen.dart
│   ├── chats_screen.dart
│   ├── chat_detail_screen.dart
│   └── settings_screen.dart
└── widgets/                  # Reusable components
    └── book_card.dart
```

## Database Schema

### Books Collection
```
books: {
  id: string,
  title: string,
  author: string,
  condition: string, // New, Like New, Good, Used
  imageUrl: string,
  ownerId: string,
  ownerEmail: string,
  createdAt: timestamp,
  status: string // available, pending, swapped
}
```

### Swap Offers Collection
```
swapOffers: {
  id: string,
  requesterId: string,
  requesterEmail: string,
  ownerId: string,
  ownerEmail: string,
  bookId: string,
  bookTitle: string,
  status: string, // pending, accepted, rejected
  createdAt: timestamp
}
```

### Chats Collection
```
chats: {
  id: string,
  participants: [string],
  lastMessage: string,
  lastMessageTime: timestamp,
  messages: {
    id: string,
    senderId: string,
    senderEmail: string,
    receiverId: string,
    message: string,
    timestamp: timestamp,
    chatId: string
  }
}
```

## Setup Instructions

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd bookswap_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project
   - Enable Authentication (Email/Password)
   - Enable Firestore Database
   - Enable Storage (optional for image uploads)
   - Download and replace `google-services.json` (Android)
   - Update `firebase_options.dart` with your project configuration

4. **Run the app**
   ```bash
   flutter run
   ```

## Key Implementation Details

### State Management
- Uses Provider pattern for reactive state management
- Real-time listeners for Firestore collections
- Automatic UI updates when data changes

### Authentication Flow
- AuthWrapper handles routing based on auth state
- Email verification required before app access
- Persistent login sessions

### Real-time Features
- Firestore listeners for books, swaps, and messages
- Instant UI updates across all users
- Optimistic UI updates for better UX

### Error Handling
- Comprehensive error handling for all Firebase operations
- User-friendly error messages
- Graceful fallbacks for network issues

## Testing

Run the Dart analyzer to check code quality:
```bash
flutter analyze
```

## Demo Video Requirements

The demo should show:
1. User registration and email verification
2. Adding, editing, and deleting books
3. Browsing listings and making swap offers
4. Swap status updates in real-time
5. Chat functionality between users
6. Firebase console showing data changes

## Deliverables

1. Source code in GitHub repository
2. Demo video (7-12 minutes)
3. Design summary document
4. Experience write-up with Firebase integration
5. Dart Analyzer report screenshot