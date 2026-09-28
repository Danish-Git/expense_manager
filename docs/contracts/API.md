# REST API Contracts

This document defines the foundational REST API contracts for the expense_manager application.

All endpoints adhere to strict JSON formatting.

---

## 1. System Health

### `GET /health`
- **Authentication:** None (Public)
- **Request:** Empty
- **Response:** `200 OK`
  ```json
  {
    "status": "ok",
    "timestamp": "2026-09-28T23:10:00Z"
  }
  ```
- **Errors:** `500 Internal Server Error` (if database/infrastructure checks fail).
- **Idempotency Behavior:** Safe. No state mutation.

---

## 2. User Management

### `GET /users/me`
- **Authentication:** Required (Firebase Bearer Token)
- **Request:** Empty
- **Response:** `200 OK`
  ```json
  {
    "id": "uuid",
    "firebase_uid": "string",
    "email": "string",
    "created_at": "datetime",
    "updated_at": "datetime"
  }
  ```
- **Errors:** `401 Unauthorized` (Invalid/Missing Token).
- **Idempotency Behavior:** Safe.

---

## 3. Financial Accounts

### `GET /accounts`
- **Authentication:** Required
- **Request:** Query parameters: `?is_active=true`
- **Response:** `200 OK`
  ```json
  [
    {
      "id": "uuid",
      "name": "string",
      "type": "string",
      "currency": "string",
      "is_active": true
    }
  ]
  ```
- **Errors:** `401 Unauthorized`.
- **Idempotency Behavior:** Safe. Returns isolated user data.

### `POST /accounts`
- **Authentication:** Required
- **Request:**
  ```json
  {
    "name": "string",
    "type": "string (e.g., bank, credit_card)",
    "currency": "string (ISO 4217)"
  }
  ```
- **Response:** `201 Created` containing the newly created account.
- **Errors:** `400 Bad Request` (Validation failure), `401 Unauthorized`.
- **Idempotency Behavior:** Not naturally idempotent. A client submitting this multiple times will create duplicate accounts unless a unique client-side idempotency key is provided.

---

## 4. Transactions

### `GET /transactions`
- **Authentication:** Required
- **Request:** Query parameters for pagination and filtering (e.g., `?limit=50&offset=0&account_id=uuid`).
- **Response:** `200 OK`
  ```json
  {
    "data": [
      {
        "id": "uuid",
        "account_id": "uuid",
        "type": "string",
        "amount": "numeric",
        "currency": "string",
        "transaction_time": "datetime",
        "status": "string"
      }
    ],
    "pagination": {
      "total": "integer",
      "limit": "integer",
      "offset": "integer"
    }
  }
  ```
- **Errors:** `400 Bad Request` (Invalid filter), `401 Unauthorized`.
- **Idempotency Behavior:** Safe.

### `GET /transactions/{id}`
- **Authentication:** Required
- **Request:** Path parameter `id`.
- **Response:** `200 OK` containing full transaction details, including merchant and category data.
- **Errors:** `401 Unauthorized`, `403 Forbidden` (User does not own transaction), `404 Not Found`.
- **Idempotency Behavior:** Safe.

---

## 5. Financial Events (Ingestion)

### `POST /financial-events`
- **Authentication:** Required
- **Request:**
  ```json
  {
    "source": "string (e.g., sms, notification)",
    "source_id": "string (optional)",
    "payload": "json object",
    "timestamp": "datetime"
  }
  ```
- **Response:** `201 Created` or `202 Accepted` (if processed asynchronously).
- **Errors:** `400 Bad Request`, `401 Unauthorized`.
- **Idempotency Behavior:** **Strictly Idempotent**. The backend deterministically computes a `source_hash`. If a duplicate hash is detected for the user, the server safely aborts processing and returns `200 OK` (or `409 Conflict` depending on REST convention), preventing duplicate event/transaction creation.

### `POST /financial-events/batch`
- **Authentication:** Required
- **Request:**
  ```json
  {
    "events": [
      {
        "source": "string",
        "payload": "json object",
        "timestamp": "datetime"
      }
    ]
  }
  ```
- **Response:** `207 Multi-Status` or `200 OK` containing an array of statuses indicating which events were created, duplicated, or failed.
- **Errors:** `400 Bad Request`, `401 Unauthorized`, `413 Payload Too Large`.
- **Idempotency Behavior:** **Strictly Idempotent (Per Event)**. The pipeline evaluates the `source_hash` of each event in the batch individually. Duplicates within the batch or against the database are ignored safely without failing the entire batch.
