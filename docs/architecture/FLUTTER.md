# Flutter Architecture

The frontend follows a clean, feature-driven architecture using GetX. The overarching dependency direction is strictly enforced:
`presentation → domain ← data`

## Directory Responsibilities

### `core/`
- **Responsibility:** App-wide configuration, constants, global routing, and theme definitions.
- **Rules:** May be shared across layers. Must not contain business logic or feature-specific code.

### `domain/`
- **Responsibility:** The absolute core of the application. Contains pure business rules, entities (e.g., `FinancialEvent`, `Transaction`), and repository abstract interfaces.
- **Strict Constraints:** MUST remain completely free from the Flutter SDK, GetX, HTTP clients, Firebase, PostgreSQL concepts, and platform-specific APIs. Pure Dart only.

### `data/`
- **Responsibility:** Implements the repository interfaces defined by the `domain`. Handles API communication, JSON serialization (DTOs), and local data persistence.
- **Rules:** Depends on the `domain`. Must map raw API responses into pure domain entities before returning them to the presentation layer.

### `services/`
- **Responsibility:** Global, long-running infrastructure wrappers (e.g., `AuthService`, SMS listener).
- **Rules:** Typically initialized at application startup. Should expose reactive state or methods that presentation controllers can consume.

### `presentation/`
- **Responsibility:** The UI layer. Contains all screens, widgets, and state management controllers. Organized strictly by feature (e.g., `presentation/features/transactions/`).
- **Rules:** Depends on the `domain`. Must not execute direct HTTP requests or bypass the domain to interact with data sources. Feature-specific controllers belong inside their respective feature folder, not a global directory.

### `utils/`
- **Responsibility:** Stateless helper functions and extensions (e.g., date formatting, string parsing).
- **Rules:** May be shared across layers. Must not hold application state.

---

## GetX Usage and Data Flow

Data and control flow follows a strict linear pattern coordinated by GetX:

1. **View (Flutter UI):**
   - Renders state and captures user input.
   - Binds to a specific `GetxController`.
2. **Controller (GetxController):**
   - Lives inside `presentation/features/<feature>/`.
   - Manages reactive UI state.
   - Receives events from the View and delegates complex logic to the domain boundary.
3. **Domain / Use-case Boundary:**
   - The interface layer defining the contract for business operations.
4. **Repository (`data` layer):**
   - Executes the implementation of the domain contract.
5. **Data Source (`data` layer):**
   - Executes the actual network request (e.g., calling `POST /financial-events`) or local database query.

*Note: Do not create additional architectural layers or speculative modules beyond this structure.*
