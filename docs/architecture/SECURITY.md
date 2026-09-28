# Security Architecture

## High-Level Boundaries
- **Firebase Authentication:** Manages identity verification and issues tokens.
- **FastAPI Backend:** Verifies the authenticated identity via Firebase tokens and enforces authorization.
- **PostgreSQL:** Securely stores financial data.
- **Firebase Storage:** Secures document and file assets.
- **Firebase Cloud Messaging (FCM):** Secures push notifications.
- **Firebase Crashlytics:** Secures crash monitoring data.

## Identity and Authorization Flow

The application relies strictly on Firebase for identity and FastAPI for authorization, culminating in strict multi-tenant isolation at the database level.

1. **Firebase UID (Identity):** The Flutter app authenticates the user via Firebase Auth, retrieving a secure ID token.
2. **FastAPI Authentication (Token Validation):** The Flutter app passes the ID token to FastAPI via the `Authorization: Bearer` header. FastAPI validates the token cryptographically against Firebase public keys.
3. **Authenticated Request Context:** Upon successful validation, the Firebase UID is mapped to the internal PostgreSQL `users.id`. This `user_id` is injected into the FastAPI request state, creating a secure authenticated context for the lifecycle of the request.
4. **Authorization (Ownership Checks):** Services and Repositories access the request context. Any operation on a resource (read, update, delete) MUST verify that the resource's `user_id` matches the context's `user_id`.
5. **PostgreSQL User Isolation:** The database serves as the ultimate financial source of truth. All tenant tables contain a `user_id` foreign key. Every SQL query is hard-scoped with `WHERE user_id = :current_user_id`, guaranteeing absolute data isolation between users.

*(Note: No complex Role-Based Access Control (RBAC) or custom roles are implemented. The architecture relies purely on strict resource ownership.)*

## Security Constraints

### API Security
- **Transport:** All communication between the client and server must be strictly over HTTPS.
- **Authentication Default:** All backend API routes must require a valid Firebase ID token by default, with explicit, rare exceptions for public endpoints (e.g., health checks).

### Local Data Security & Secrets Handling
- **Secrets:** No API keys, database credentials, or secret tokens may be hardcoded or bundled in the Flutter application. All secrets must be securely provided to the backend via environment variables.
- **Database Access:** The Flutter app must NEVER connect directly to PostgreSQL. It interacts exclusively through the FastAPI backend.

### Logging Rules
- **Sensitive Data:** Absolutely no sensitive financial information (account balances, raw transaction amounts, PII) may be written to application logs or crash reports.
- **Raw SMS:** No raw SMS data may be logged or uploaded by default. 

### Service-Account Boundaries
- **Backend Privileges:** The FastAPI backend utilizes a Firebase Admin service account credential. This credential operates outside user restrictions to perform token verification, Storage signing, and FCM delivery. However, it MUST NOT be used to bypass PostgreSQL user-isolation logic when serving user-initiated requests.

*Note: Security systems and specific Firebase verification middleware are not yet implemented.*
