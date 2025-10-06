# VMS Resident Mobile Application (Flutter)

## 1. Project Overview

The VMS Resident Mobile Application is the core user interface for homeowners and tenants within the residential estates. It enables the primary function of the Visitor Management System (VMS): generating secure, time-bound access codes (5-character codes and QR codes) for visitors.

* **Role:** Resident (Tenant/Home Owner)
* **Goal:** To securely generate access passes, view personal visit history, and manage visitor access.
* **Target Platforms:** iOS and Android.
* **Status:** Phase 1 MVP Development.
* **Methodology:** Agile/Scrum.

---

## 2. Technology Stack & Requirements

| Component | Technology | Rationale |
| :--- | :--- | :--- |
| **Framework** | **Flutter (Dart)** | Single codebase for iOS and Android deployment. |
| **State Management** | **Provider** | Simple, robust, and scalable solution for managing app state. |
| **Networking** | **Dio** | Robust HTTP client for secure, token-based API communication. |
| **Security/Storage** | **`flutter_secure_storage`** | **CRITICAL:** Mandatory for securely storing the JWT token on the device (keychain/Keystore). |
| **QR Generation** | **`qr_flutter`** | Required to generate and display the QR code image on the Visitor Pass screen. |
| **Routing** | **`go_router`** | Recommended for robust deep linking and complex authentication-aware navigation. |

### API Contract Details

* **Base URL:** `https://vmsbackend.vercel.app/api/v1`
* **Authentication:** All requests require a **JWT Bearer Token** in the header.
* **Error Handling:** The app must catch `401 Unauthorized` errors and automatically redirect the user to the Login Screen.

---

## 3. Project Architecture (Modular & Scalable)

The application adheres to a clean, **Layered Architecture** to ensure robust, scalable, and maintainable code.

| Layer | Directory | Contents & Responsibility |
| :--- | :--- | :--- |
| **Core** | `lib/src/core` | **Foundation.** Contains global settings: `constants.dart` (Base URL), `api_client.dart` (Dio setup), and global error handlers. |
| **Data** | `lib/src/data` | **Abstraction.** Contains all feature **Repositories** (API logic) and **Models** (JSON serialization via `json_serializable`). |
| **Features** | `lib/src/features` | **Business Logic.** Contains separated modules (`auth`, `visitor_codes`, `history`). Each module houses its screens and Providers. |
| **Shared** | `lib/src/shared` | **Reusable UI.** Stateless widgets, themes, and design tokens used across multiple features (e.g., `CustomButton`). |

---

## 4. Getting Started (Onboarding)

### Prerequisites

1.  Flutter SDK (Latest Stable Channel).
2.  Code Editor (VS Code or Android Studio).
3.  Access to the VMS Backend (via the Base URL).

### Setup Instructions

1.  **Clone the Repository:**
    ```bash
    git clone [repository_url]
    cd vms_resident_app
    ```
2.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Generate Serialized Files:** (Run this **every time** a data model (`.dart` file with `@JsonSerializable()`) is modified.)
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```
4.  **Run the Application:**
    ```bash
    flutter run
    ```

---

## 5. Phase 1 MVP Feature Summary

The following features must be completed and tested for the Phase 1 sign-off:

| Module | Screens & Components | Key API Endpoints |
| :--- | :--- | :--- |
| **Authentication** | `LoginScreen`, Auth Providers | `POST /auth/resident/login`, `GET /auth/verify` |
| **Codes Generation**| `GenerateCodeScreen` (Date/Time Input) | `POST /codes/generate` |
| **Visitor Pass** | `VisitorPassScreen` (5-char code & QR display) | N/A (Displays data received from the generate endpoint) |
| **History** | `VisitHistoryScreen` | `GET /codes/my-history` |

---

## 6. Development and Security Notes

1.  **Security Mandate:** The JWT token **must** be stored using **`flutter_secure_storage`**. Tokens must **never** be stored in standard `SharedPreferences` or state memory.
2.  **Agile Tracking:** All work must be tracked and updated daily in the ClickUp project board.
3.  **Unit Testing:** Focus on writing unit tests for all **Providers** and **Repositories** to ensure business logic is robust and prevents regressions.
4.  **Token Refresh/Expiration:** The app must gracefully handle token expiration (401 errors) by immediately prompting the user to log in again.