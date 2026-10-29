# Bondly

Full-stack application featuring a **Flutter** UI, **Node.js Express** API, **PostgreSQL (`pg`)** database, and **Cloudinary** for media upload, processing, and transformations.

---

## 🏗️ Architecture

```
Bondly/
├── backend/                       # Express REST API
│   ├── src/
│   │   ├── config/
│   │   │   ├── db.js              # PostgreSQL client (pg.Pool) with auto-table setup
│   │   │   └── cloudinary.js      # Cloudinary v2 SDK & image transformation helper
│   │   ├── controllers/
│   │   │   ├── fileController.js  # Upload, list, and delete handlers
│   │   │   └── healthController.js# System health & DB/Cloudinary diagnostics
│   │   ├── middleware/
│   │   │   ├── uploadMiddleware.js# Multer memory storage & file type filter
│   │   │   └── errorHandler.js    # Global error handler
│   │   ├── routes/
│   │   │   ├── fileRoutes.js      # /api/files (GET, POST /upload, DELETE /:id)
│   │   │   └── healthRoutes.js    # /api/health
│   │   ├── app.js                 # Express application & CORS configuration
│   │   └── server.js              # Server entry point (starts on port 5000)
│   ├── tests/
│   │   └── api.test.js            # Automated Jest & Supertest API test suite
│   ├── .env.example               # Example environment variables
│   ├── .env                       # Active environment configuration
│   └── package.json
│
└── frontend/                      # Flutter UI Application
    ├── lib/
    │   ├── models/
    │   │   └── file_item.dart     # Uploaded file item data model
    │   ├── services/
    │   │   └── api_service.dart   # REST client for backend API communication
    │   └── main.dart              # Material 3 Dashboard (live status, uploader, feed)
    ├── test/
    │   └── widget_test.dart       # Flutter widget test suite
    └── pubspec.yaml
```

---

## ⚙️ Configuration (`backend/.env`)

Edit `backend/.env` to configure your PostgreSQL credentials and Cloudinary credentials:

```env
PORT=5000
NODE_ENV=development

# PostgreSQL Configuration
PGHOST=localhost
PGPORT=5432
PGUSER=postgres
PGPASSWORD=your_postgres_password
PGDATABASE=bondly_db

# Cloudinary Configuration
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
```

> **Note**: If PostgreSQL credentials are pending, the backend will safely run with an in-memory fallback store and indicate connection status via `/api/health`. Once valid credentials are provided, it automatically connects and creates the `uploaded_files` table.

---

## 🚀 Running the Project

### 1. Start the Express API Backend
```bash
cd backend
npm install
npm start
```
The API will run on `http://localhost:5000`.
- Health status: [http://localhost:5000/api/health](http://localhost:5000/api/health)
- Files endpoint: [http://localhost:5000/api/files](http://localhost:5000/api/files)

### 2. Run the Flutter Frontend
Open a new terminal window:
```bash
cd frontend
flutter pub get

# Run on Chrome Web:
flutter run -d chrome

# Or run on Windows Desktop:
flutter run -d windows
```

---

## 🧪 Testing and Verification

- **Backend tests**:
  ```bash
  cd backend
  npm test
  ```
  Runs 6 automated Jest & Supertest integration tests covering API endpoints, upload handling, and file management.

- **Flutter analyzer & tests**:
  ```bash
  cd frontend
  flutter analyze
  flutter test
  ```
  Runs Dart static analysis and widget tests.
