# Bharat Shikshak Sahayak (Teacher Assistant)

A production-grade Flutter application designed for teachers to digitize classroom resources, manage attendance, and organize teaching materials.

## 🚀 Production Features

- **Multi-Language Support**: Fully localized in English, Hindi, and Hinglish.
- **Smart OCR & QR**: Integrated Google ML Kit for high-accuracy text recognition and QR code redirection.
- **Visual Document History**: Professional doc-scanner style grid view with thumbnails and previews.
- **Data Persistence**: Offline-first design using Hive with a 30-day auto-retention policy.
- **Robust Authentication**: Complete Login, Register, and Forgot Password flows with validation and loading states.
- **Premium UI/UX**: Animated splash screen, consistent branding, and buttery-smooth transitions.

## 🛠 Tech Stack & Architecture

- **State Management**: [Riverpod](https://riverpod.dev) (Modern, scalable provider pattern).
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router) (Declarative routing).
- **Database**: [Hive](https://hivedb.dev) (Fast, encrypted-ready local storage).
- **Logging**: [Logger](https://pub.dev/packages/logger) (Standardized production logs).
- **Network**: [Dio](https://pub.dev/packages/dio) & [Internet Connection Checker](https://pub.dev/packages/internet_connection_checker).

## 📂 Project Structure (Clean Layered Pattern)

- `lib/core`: App-wide utilities, themes, and common widgets.
- `lib/features`: Feature-based modules (Auth, Scan, Home, etc.).
  - `domain`: Business logic, entities, and repository interfaces.
  - `data`: API implementations, local storage, and concrete repositories.
  - `presentation`: UI screens (Pages) and state management (Providers).

## 🔗 Backend Integration

This project is prepared for a REST or Firebase backend. Look for `// BACKEND INTEGRATION POINT` comments in the codebase to connect your live APIs.

---
Built with ❤️ for teachers across Bharat.
