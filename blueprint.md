# Project Blueprint: Mail-san

## 1. Overview

**Mail-san** is an intelligent, privacy-first email triage client for iOS and Android, built with Flutter. It's designed to automate inbox sorting for students and professionals by using local-first AI and a high-performance, offline-capable database.

## 2. Core Architecture & Design

*   **Framework**: Flutter (Dart)
*   **Architecture**: Clean Architecture (Data, Domain, Presentation layers)
*   **State Management**: Riverpod for predictable, unidirectional data flow and dependency injection.
*   **Local Storage**: Isar for a high-performance, offline-first, and queryable database.
*   **Styling**: Dark-mode-first, minimalist aesthetic with monochrome icons.
*   **Concurrency**: Dart Isolates for background tasks like sync, AI processing, and database operations to ensure a smooth UI.

## 3. Implemented Features & Style

*This section will be updated as features are implemented.*

### Initial Setup:
- **Project Structure**: Implemented a Clean Architecture directory structure (`data`, `domain`, `presentation`, `core`).
- **Dependencies**: Added `flutter_riverpod`, `isar`, `isar_flutter_libs`, and corresponding generator packages.
- **Data Model**: Created the `LocalEmail` entity and the `LocalEmailModel` for Isar with necessary annotations.
- **Theming**: Configured a dark-mode-first theme in `main.dart`.
- **State**: Set up initial Riverpod providers for database and future services.

## 4. Current Plan: Initial Bootstrap

The current focus is on bootstrapping the application by setting up the foundational pieces.

**Steps:**

1.  **✅ Create `blueprint.md`**: Establish the project's architectural and feature guide.
2.  **✅ Add Core Dependencies**: Update `pubspec.yaml` with `flutter_riverpod`, `riverpod_annotation`, `isar`, `isar_flutter_libs`, `path_provider`, and the necessary build tools (`build_runner`, `isar_generator`, `riverpod_generator`).
3.  **✅ Create Directory Structure**: Scaffold the Clean Architecture directories: `lib/core`, `lib/data`, `lib/domain`, `lib/presentation`.
4.  **✅ Define Core Data Model**: Create the `LocalEmail` entity and the Isar-annotated `LocalEmailModel`.
5.  **✅ Initialize Services & Providers**: Set up the Isar service and create initial Riverpod providers.
6.  **✅ Run Code Generation**: Execute `build_runner` to generate files for Isar and Riverpod.
7.  **✅ Configure `main.dart`**: Initialize services, set up the `ProviderScope`, and apply the dark theme.
8.  **Create Placeholder UI**: Build a basic home screen with a `Scaffold` to verify the setup.

