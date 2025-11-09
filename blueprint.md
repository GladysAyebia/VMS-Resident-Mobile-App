# VMS Resident App Blueprint

## Overview

This document outlines the architecture and implementation of the VMS Resident App, a Flutter-based mobile application designed for residents to manage visitor access.

## Project Structure

- **`lib/`**: Main application code.
  - **`main.dart`**: App entry point, theme definition, and routing.
  - **`src/`**: Core application logic, features, and widgets.
    - **`core/`**: Shared components like API clients, navigation, and error handlers.
    - **`features/`**: Individual feature modules (e.g., `auth`, `visitor_codes`).
      - **`auth/`**: User authentication (login, logout, session management).
        - **`models/`**: Data models (e.g., `Resident`).
        - **`providers/`**: State management (e.g., `AuthProvider`).
        - **`repositories/`**: Data access logic.
        - **`presentation/`**: UI components (pages, widgets).
    - **`widgets/`**: Reusable UI widgets.

## Features & Design

### Authentication

- **Login**: Residents can log in with their email and password.
- **Session Management**: The app maintains user sessions and directs users to the appropriate screen based on their authentication state.
- **UI**: The login screen features a modern design with a logo, custom text fields, and a prominent login button.

### Navigation

- **Initial Route**: The app now uses a `SplashScreen` to handle initial authentication checks, preventing redirect loops.
- **Routing**: Named routes are used for navigation between screens.

## Current Task: Fix Redirect Loop

### Plan & Steps

1.  **Create `SplashScreen`**: A new screen was introduced to manage the initial authentication flow.
    - The `SplashScreen` checks if the user is logged in.
    - If logged in, it navigates to the main `ShellScreen`.
    - Otherwise, it navigates to the `LoginPage`.

2.  **Update `main.dart`**:
    - The initial route was changed from `LoginPage` to `SplashScreen`.
    - The `SplashScreen` was added to the routes map.

3.  **Update `AuthProvider`**:
    - An `isLoggedIn` method was added to check for a token in secure storage.
    - The `isLoggedIn` getter was renamed to `isLoggedInState` to avoid conflicts.

4.  **Update `login_page.dart`**:
    - The code was updated to use the `isLoggedInState` getter, ensuring consistency with the `AuthProvider`.
