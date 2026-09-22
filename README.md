# Swiss Luxury Services (SLS) — Web Admin Panel

A Flutter Web administration portal for **Swiss Luxury Services (SLS)** — private jet charter and VIP concierge services.

Built with Flutter Web, Riverpod MVVM state management, GoRouter authentication and role guarding, and Firebase Suite (Firestore, Authentication, Storage, Cloud Functions).

---

## 🚀 Getting Started

### 1. Prerequisites
- Flutter SDK `^3.13.1` (or latest stable)
- Node.js `18+` (for Firebase Cloud Functions deployment)
- Firebase CLI (`npm install -g firebase-tools`)

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run Locally (Chrome)
```bash
flutter run -d chrome
```

### 4. Build for Production Web
```bash
flutter build web --release
```

---

## 🔐 Creating the First Super Administrator

Since the admin panel guards all routes against the `admins` collection in Firestore:

1. **Create an Auth User**:
   - In the **Firebase Console** -> **Authentication** -> **Users**, click **Add user** (or sign up through the mobile app).
   - Copy the generated `User UID`.

2. **Add Admin Record in Firestore**:
   - In **Firestore Database**, create a document inside the collection `admins`:
     - **Collection ID**: `admins`
     - **Document ID**: `<User UID>` (the UID copied above)
     - **Fields**:
       ```json
       {
         "uid": "<User UID>",
         "email": "admin@swissluxuryservices.ch",
         "role": "super_admin",
         "createdAt": [Server Timestamp]
       }
       ```
3. **Sign In**:
   - Navigate to `/login` on the Web Admin Panel and sign in with those credentials.

---

## ⚡ Cloud Functions Deployment (User Management)

The Web SDK cannot list all Firebase Auth users directly. Deploy the provided Cloud Functions:

```bash
# Login to Firebase CLI
firebase login

# Set active project
firebase use swissproject-33b18

# Deploy functions
firebase deploy --only functions

# Deploy Firestore security rules
firebase deploy --only firestore:rules
```

---

## 📦 Firestore Schema & Collections

| Collection | Description | Access |
|---|---|---|
| `admins` | Administrative users and roles (`super_admin`, `editor`) | Super Admin (Write), Admins (Read) |
| `jets` | Fleet aircraft with multilingual specs and images | Public (Read), Admins (Write) |
| `destinations` | VIP routes, travel guides, and rich content blocks | Public (Read), Admins (Write) |
| `blogs` | Journal articles, excerpts, and rich content blocks | Public (Read), Admins (Write) |
| `home_content` | Live carousel route cards and counters for mobile app | Public (Read), Admins (Write) |
| `quote_requests` | Incoming charter flight leads and staff notes | App Users (Create), Admins (CRUD) |
| `concierge_requests` | VIP ground handling & helicopter transfer inquiries | App Users (Create), Admins (CRUD) |
| `settings` | Quote notification recipient email and global configs | Public (Read), Super Admin (Write) |

---

## 🌍 Multilingual Content

All content models support 4 languages:
- 🇬🇧 English (`en`)
- 🇫🇷 French (`fr`)
- 🇩🇪 German (`de`)
- 🇦🇪 Arabic (`ar`)

The `LocalizedFieldTabs` widget provides seamless tabbed input for each language across all forms.

---

## 📲 Next Steps: Mobile App Integration

To switch the SLS mobile app from static Dart lists to the live Firestore collections:
1. **Fleet**: Update `FleetRepository` in mobile app to stream from `jets` ordered by `order`.
2. **Destinations**: Update `DestinationsRepository` in mobile app to stream from `destinations`.
3. **Blog**: Update `BlogRepository` in mobile app to stream from `blogs` where `isPublished == true`.
4. **Home**: Update home view to stream cards and stats from `home_content/main`.
5. **Localization**: Use the existing locale lookup helper to select the appropriate field from `LocalizedText` (`en`, `fr`, `de`, `ar`).
