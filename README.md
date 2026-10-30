# Bondly

**Bondly** is a cross-platform mobile application designed for nurturing meaningful friendships, private relationship tracking, messaging, reminders, and collaboration.

---

## 🛠️ Tech Stack

- **Mobile Client:** Flutter (Material 3)
- **Backend Infrastructure:** Firebase
- **Database:** Cloud Firestore
- **Authentication:** Firebase Authentication
- **File & Media Storage:** Firebase Storage
- **Push Notifications:** Firebase Cloud Messaging (FCM)
- **Backend Logic & Triggers:** Firebase Cloud Functions (TypeScript)

---

## 📁 Project Architecture & Folder Structure

Bondly follows a scalable **feature-first Clean Architecture** layout. Each feature module is self-contained with decoupled `data`, `domain`, and `presentation` layers.

```text
bondly/
├── app/                                    # Flutter Mobile & Web Client
│   └── lib/
│       ├── main.dart                       # App entry point (Firebase initialization & bootstrap)
│       ├── app.dart                        # Root BondlyApp widget (Theme, Routing, AppConfig)
│       ├── core/                           # Cross-cutting foundational modules
│       │   ├── config/                     # Environment and app configuration
│       │   ├── constants/                  # Global constants & Firestore collection names
│       │   ├── errors/                     # App-wide failures and exceptions
│       │   ├── firebase/                   # Firebase initialization & options
│       │   ├── router/                     # Navigation route paths & generator
│       │   ├── theme/                      # AppColors, typography, & ThemeData
│       │   ├── utils/                      # Common date utilities & form validators
│       │   └── widgets/                    # Core widgets (scaffold, loading indicator)
│       ├── shared/                         # Reusable domain-agnostic components
│       │   ├── models/                     # Shared models (e.g. UserSummary)
│       │   ├── services/                   # Analytics, notification services
│       │   └── widgets/                    # Common UI components (buttons, avatars)
│       └── features/                       # 14 Independent Feature Modules
│           ├── auth/                       # Registration, login, authentication, and sessions
│           ├── users/                      # User profiles and account settings
│           ├── connections/                # Friend requests, connections, and blocking
│           ├── invitations/                # Private invitation links and codes
│           ├── messaging/                  # Direct messages and conversations
│           ├── relationships/              # Private contacts, notes, and interaction history [STRICT PRIVACY]
│           ├── followups/                  # Follow-up schedules and reminders [STRICT PRIVACY]
│           ├── notifications/              # Push notification handling
│           ├── groups/                     # Groups, memberships, and permissions
│           ├── goals/                      # Personal and shared goals
│           ├── projects/                   # Projects, tasks, and milestones
│           ├── reports/                    # User reports and moderation
│           ├── privacy/                    # Privacy settings, data export, consent, account deletion
│           └── insights/                   # Relationship insights and AI-powered recommendations
├── functions/                              # Firebase Cloud Functions (TypeScript Backend)
│   └── src/
│       ├── index.ts                        # Master functions export entry point
│       ├── shared/                         # Shared backend config, constants, middleware, utils
│       │   ├── config/
│       │   ├── constants/
│       │   ├── middleware/                 # Auth verification middleware
│       │   └── utils/
│       └── features/                       # 14 Backend Feature Triggers & Handlers
│           ├── auth/
│           ├── users/
│           ├── connections/
│           ├── invitations/
│           ├── messaging/
│           ├── relationships/              # Owner-only privacy enforcement
│           ├── followups/                  # Private scheduler enforcement
│           ├── notifications/
│           ├── groups/
│           ├── goals/
│           ├── projects/
│           ├── reports/
│           ├── privacy/
│           └── insights/
├── firebase.json                           # Firebase CLI configuration
├── firestore.rules                         # Security rules with strict ownership rules
├── firestore.indexes.json                  # Firestore compound query indexes
├── storage.rules                           # Firebase Storage access rules
├── .gitignore                              # Git exclusion rules
└── README.md                               # Project documentation
```

---

## 🧩 Flutter Feature Module Convention

Every feature folder inside `app/lib/features/` follows this standard Clean Architecture convention:

```text
feature_name/
├── data/
│   ├── datasources/        # Remote and local data source interfaces & implementations
│   ├── models/             # Data transfer models with serialization (toMap/fromMap)
│   └── repositories/       # Concrete repository implementations
├── domain/
│   ├── entities/           # Pure business models independent of frameworks
│   ├── repositories/       # Abstract repository interfaces (contracts)
│   └── usecases/           # Individual business actions / use cases
└── presentation/
    ├── controllers/        # State management / controllers / notifiers
    ├── pages/              # Screen-level UI widgets
    └── widgets/            # Feature-specific reusable UI components
```

---

## 🔒 Important Privacy Architecture

> **CRITICAL PRIVACY REQUIREMENT**
> 
> Bondly's relationship contacts, notes, personal interaction history, and follow-up schedules are **confidential and visible ONLY to their owner**.
> 
> Connecting with another user or forming mutual friendships **must NEVER grant access to that private data**.
> 
> - **Firestore Rules (`firestore.rules`):** Relationship contacts (`/users/{userId}/relationships/{relationshipId}`) and follow-ups (`/users/{userId}/followups/{followupId}`) enforce `request.auth.uid == userId` for all read and write operations.
> - **Storage Rules (`storage.rules`):** Private voice notes and attachments are restricted under `/users/{userId}/private/{allPaths=**}` and accessible only by `userId`.
> - **Backend Logic:** Cloud Functions and data sources treat private relationship data as strictly isolated subcollections per authenticated user.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev) (v3.11.0+)
- [Node.js](https://nodejs.org) (v18+) & [Firebase CLI](https://firebase.google.com/docs/cli)

### Running Flutter App
```bash
cd app
flutter pub get
flutter run
```

### Building Cloud Functions
```bash
cd functions
npm install
npm run build
```
