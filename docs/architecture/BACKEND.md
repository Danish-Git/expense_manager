# Backend Architecture

The backend utilizes FastAPI and is structured into domain-driven modules.

## Directory Structure
```text
backend/src/expense_manager_backend/
├── config/
├── common/
├── interface/
├── infrastructure/
├── routes/
└── modules/
```

## Feature-Module Convention
Modules start flat and grow based on complexity.

### Small Module
```text
routes.py
schemas.py
service.py
```

### Grown Module
```text
models/
schemas/
services/
repositories/
interfaces/
routes.py
```

## Layer Responsibilities
- **Routes:** `routes.py` files are the only components that know about HTTP or FastAPI constructs.
- **Services:** Contain pure business logic.
- **Repositories:** Abstract database or persistence access.
- **Interfaces:** Define protocol contracts.
- **Infrastructure:** Implements the interfaces (e.g., DB connectors, external API clients).
