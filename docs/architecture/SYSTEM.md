# System Boundaries and Dependencies

## Backend Boundaries
The backend architecture enforces the following dependency direction:
`routes -> module routes -> services -> interfaces <- infrastructure`

- **Feature-Module Convention:** Modules begin flat and grow only when complexity demands it.
- **Domain Independence:** Domain and business logic must never depend on infrastructure components.

## Flutter Boundaries
The mobile client architecture enforces the following dependency direction:
`presentation -> domain <- data`

Domain logic is the core of the client and must remain fully isolated from the presentation or data storage mechanisms.
