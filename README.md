# Caste Census Database

An end-to-end, multi-module census platform with:

1. Spring Boot backend API (authentication, census submission, verification workflow).
2. Python FastAPI AI service (income anomaly detection using Isolation Forest).
3. Flutter enumerator app (offline-first field collection + sync).
4. Next.js admin dashboard (analytics, review, and manual verification actions).

## Repository Layout

```text
.
|-- README.md
|-- LICENSE
`-- Caste-census/
		`-- caste-census/
				|-- pom.xml                         # Spring Boot backend
				|-- src/
				|-- ai-service/                     # FastAPI + scikit-learn anomaly service
				`-- census_app/
						|-- lib/                        # Flutter app source
						`-- admin-dashboard/            # Next.js dashboard
```

## Architecture Overview

1. Enumerator logs in through Flutter app.
2. Enumerator captures census data and profile image, saves locally (SQLite) when offline.
3. Enumerator syncs pending records to Spring Boot backend.
4. Backend stores data in PostgreSQL and marks each new record as `PENDING`.
5. Admin triggers AI verification from dashboard.
6. Backend sends safe payload (`id`, `householdId`, `income`) to Python AI service.
7. AI service flags anomalous records; backend updates those records to `FLAGGED`.
8. Admin verifies or flags records manually from dashboard.

## Tech Stack

### Backend (Java)

- Java 17
- Spring Boot 3
- Spring Web, Spring Data JPA, Spring Validation, Spring Security (basic role model)
- PostgreSQL
- Lombok

### AI Service (Python)

- Python 3.10+
- FastAPI
- Uvicorn
- pandas
- scikit-learn (IsolationForest)

### Mobile/Desktop Enumerator App

- Flutter (Dart)
- sqflite / sqflite_common_ffi (offline local DB)
- connectivity_plus
- image_picker
- http

### Admin Dashboard

- Next.js 16 (App Router)
- React 19
- TypeScript
- Axios
- Recharts
- Tailwind CSS

## Prerequisites

- Java 17+
- Maven 3.9+
- PostgreSQL 14+
- Python 3.10+
- Flutter SDK 3+
- Node.js 20+

## Environment and Configuration

Backend config is currently in [Caste-census/caste-census/src/main/resources/application.yml](Caste-census/caste-census/src/main/resources/application.yml) and [Caste-census/caste-census/src/main/resources/application.properties](Caste-census/caste-census/src/main/resources/application.properties):

- Backend port: `9090`
- PostgreSQL DB: `censusdb`
- Default DB user: `postgres`

Update DB credentials before running in your environment.

AI service endpoint expected by backend:

- `http://127.0.0.1:8001/ai/verify`

Dashboard and Flutter app call backend on:

- `http://localhost:9090`

## Local Setup and Run

### 1. Start PostgreSQL

Create database:

```sql
CREATE DATABASE censusdb;
```

### 2. Start Spring Boot Backend

```bash
cd Caste-census/caste-census
mvn spring-boot:run
```

Backend starts on `http://localhost:9090`.

### 3. Start Python AI Service

```bash
cd Caste-census/caste-census/ai-service
python -m venv .venv
# Windows PowerShell
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
uvicorn main:app --host 127.0.0.1 --port 8001 --reload
```

### 4. Start Admin Dashboard

```bash
cd Caste-census/caste-census/census_app/admin-dashboard
npm install
npm run dev
```

Dashboard runs on `http://localhost:3000`.

### 5. Start Flutter App

```bash
cd Caste-census/caste-census/census_app
flutter pub get
flutter run
```

On Windows/Linux desktop, `sqflite_common_ffi` is initialized in app startup.

## Seeded Users (Development)

On first backend run, default users are created by [Caste-census/caste-census/src/main/java/com/census/config/DataSeeder.java](Caste-census/caste-census/src/main/java/com/census/config/DataSeeder.java):

1. Admin
	 - Username: `admin`
	 - Password: `admin123`
2. Enumerator
	 - Username: `user`
	 - Password: `user123`

Use these only for local development.

## Key API Endpoints

### Authentication

- `POST /api/auth/login`
	- Returns role string: `ROLE_ADMIN` or `ROLE_ENUMERATOR`.

### Census

- `POST /api/census/submit`
	- Validated submission payload (household, caste, education, occupation, income, region, image).
- `GET /api/census/all`
	- Returns all census records.
- `POST /api/census/run-ai`
	- Triggers AI verification scan.
- `GET /api/census/status/{householdId}`
	- Public status lookup by household ID.

### Verification / Admin

- `POST /api/verify/{id}/flag`
	- Flags record for review.
- `GET /api/admin/flagged-records`
	- Returns records flagged by AI/manual checks.
- `POST /api/admin/verify/{id}`
	- Marks record as `VERIFIED`.
- `POST /api/admin/flag/{id}`
	- Marks record as `FLAGGED`.

## Data Model Highlights

Main census entity fields are defined in [Caste-census/caste-census/src/main/java/com/census/model/CensusEntity.java](Caste-census/caste-census/src/main/java/com/census/model/CensusEntity.java):

- `id` (UUID)
- `householdId`
- `caste` (stored via JPA converter)
- `education`
- `occupation`
- `income`
- `region`
- `profileImageBase64`
- `verificationStatus` (`PENDING`, `FLAGGED`, `VERIFIED`)

## AI Verification Logic

The AI service in [Caste-census/caste-census/ai-service/model.py](Caste-census/caste-census/ai-service/model.py):

1. Converts incoming records to DataFrame.
2. Uses `income` feature for outlier detection.
3. Runs IsolationForest with `contamination=0.1`.
4. Returns anomalous record IDs.

Backend integration is in [Caste-census/caste-census/src/main/java/com/census/service/AiVerificationService.java](Caste-census/caste-census/src/main/java/com/census/service/AiVerificationService.java).

## Offline Sync Workflow (Flutter)

1. Enumerator saves forms locally to SQLite table `census`.
2. Records are tracked with status (`PENDING` / `SYNCED`).
3. Sync screen uploads pending records to backend.
4. Successful uploads are marked `SYNCED` locally.

Relevant files:

- [Caste-census/caste-census/census_app/lib/services/local_db_service.dart](Caste-census/caste-census/census_app/lib/services/local_db_service.dart)
- [Caste-census/caste-census/census_app/lib/screens/sync_status.dart](Caste-census/caste-census/census_app/lib/screens/sync_status.dart)

## Common Troubleshooting

1. Login fails for valid users:
	 - Ensure backend started successfully and DataSeeder has run.
	 - Check backend logs for DB connection issues.

2. AI verification says offline:
	 - Confirm FastAPI service is running on port `8001`.
	 - Verify endpoint path `/ai/verify`.

3. Dashboard shows no records:
	 - Make sure synced records exist in DB.
	 - Confirm dashboard can reach `http://localhost:9090`.

4. Flutter sync not working:
	 - Check machine network access and backend availability.
	 - Verify pending records exist in local SQLite DB.

## Security Notes

- Current auth is simple username/password with plain-text comparison and role response.
- Replace with secure password hashing (e.g., BCrypt), token-based auth (JWT), and restricted CORS before production.
- Move DB credentials and secrets to environment variables.
- Avoid storing large base64 images in primary transactional tables for production scale.

## License

See [LICENSE](LICENSE).