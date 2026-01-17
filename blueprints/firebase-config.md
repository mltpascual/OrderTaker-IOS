# Firebase Configuration & Security

This document serves as the source of truth for the Firebase backend configuration. Use this to configure new environments (e.g., Staging vs. Production).

## 1. Authentication Providers

Enable the following sign-in methods in the Firebase Console:

| Provider | Configuration Notes |
| :--- | :--- |
| **Email/Password** | Enable "Email link (passwordless sign-in)" is **OFF**. Just standard Email/Password. |
| **Google** | Requires SHA-1 fingerprint from Xcode (for local dev) and App Store Connect (for prod). Reverse client ID must be added to `Info.plist`. |

---

## 2. Firestore Security Rules

These rules ensure strict data isolation. Users can **only** read/write their own data.

**Copy/Paste into Firebase Console > Firestore > Rules:**

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check ownership
    function isOwner(userId) {
      return request.auth != null && request.auth.uid == userId;
    }

    // USER PROFILE
    match /users/{userId} {
      allow read, write: if isOwner(userId);

      // ORDERS Subcollection
      match /orders/{orderId} {
        allow read, write: if isOwner(userId);
      }

      // MENU Subcollection
      match /menu/{menuId} {
        allow read, write: if isOwner(userId);
      }
    }
  }
}
```

---

## 3. Firestore Indexes (Composite)

The app sorts orders by **Pickup Date** and **Pickup Time**. You *may* need to create the following exemptions or manual indexes if queries fail.

**Collection Group**: None currently required (queries are scoped to specific users).

**Single Field Index Exemptions**:
*   No specific exemptions required yet.

**Composite Indexes**:
If you see a query error in the Xcode console containing a link, click it to create the index automatically. 

Expected Index for Default Sort:
*   Collection: `orders`
*   Fields: 
    *   `pickupDate` (Ascending)
    *   `pickupTime` (Ascending)
*   Scope: Collection

---

## 4. Storage Security Rules (Future)

*Currently, the app does not use Cloud Storage. If image attachments are added later, use these rules:*

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```
