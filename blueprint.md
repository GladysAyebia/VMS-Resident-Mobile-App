
# VMS Resident App Blueprint

## Overview

This document outlines the architecture and implementation plan for a Flutter-based mobile application for residents in a Visitor Management System (VMS). The app will allow residents to log in, view their profile, and generate temporary access codes for their visitors.

## Project Structure

The project is organized by feature, with a core set of shared components and services.

```
lib/
├── src/
│   ├── core/
│   │   ├── api_client.dart
│   │   ├── error_handler.dart
│   │   └── constants.dart
│   ├── features/
│   │   ├── auth/
│   │   │   ├── models/
│   │   │   │   └── resident_model.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   ├── providers/
│   │   │   │   └── auth_provider.dart
│   │   │   └── screens/
│   │   │       └── login_screen.dart
│   │   ├── visitor_codes/
│   │   │   ├── repositories/
│   │   │   │   └── visitor_code_repository.dart
│   │   │   ├── providers/
│   │   │   │   └── code_provider.dart
│   │   │   └── screens/
│   │   │       └── generate_code_screen.dart
│   │   └── home/
│   │       └── screens/
│   │           └── home_screen.dart
│   └── shared/
│       ├── custom_button.dart
│       └── loading_indicator.dart
└── main.dart
```

## Style and Design

- **UI Components:** The app will use standard Material Design components.
- **Styling:** A consistent color scheme and typography will be defined in the `ThemeData`.
- **Layout:** Screens will be designed to be simple, intuitive, and responsive.

## Features

- **Authentication:** Residents can log in with their email and password.
- **Dashboard:** A home screen to welcome the resident and provide access to key features.
- **Visitor Code Generation:** Residents can generate a temporary access code for a visitor, specifying the visitor's name and the code's expiry date.

## Implementation Plan

1.  **Project Setup:**
    *   Create a new Flutter project.
    *   Add necessary dependencies: `provider`, `dio`, `json_serializable`, `build_runner`.

2.  **Core Components:**
    *   `ApiClient`: A Dio-based client for making API requests.
    *   `ErrorHandler`: A utility to handle API errors.
    *   `constants.dart`: To store constant values for the app.

3.  **Shared Widgets:**
    *   `CustomButton`: A reusable button widget.
    *   `LoadingIndicator`: A reusable loading indicator widget.

4.  **Authentication Feature:**
    *   `resident_model.dart`: A data model for the resident.
    *   `auth_repository.dart`: A repository to handle authentication API calls.
    *   `auth_provider.dart`: A provider to manage authentication state.
    *   `login_screen.dart`: A UI for the login form.

5.  **Visitor Code Feature:**
    *   `visitor_code_repository.dart`: A repository to handle visitor code generation.
    *   `code_provider.dart`: A provider to manage the state of the generated code.
    *   `generate_code_screen.dart`: A UI for the code generation form.

6.  **Home Feature:**
    *   `home_screen.dart`: The main dashboard screen after login.

7.  **Main Application:**
    *   `main.dart`: The entry point of the application, which sets up providers and routing.

