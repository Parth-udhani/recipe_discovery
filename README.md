Recipe Discovery App

Context-Aware Flutter Application

 1. Overview

This project is a Flutter application built as part of a recruitment assignment to demonstrate real-world mobile development skills including:

* Asynchronous programming
* Clean architecture and state management
* Offline-first data handling
* Context-aware logic (time and location)
* Background notifications
* CI/CD automation

The application helps users discover recipes intelligently based on **time of day**, **user context**, and **previous interactions**, while ensuring usability even without internet connectivity.
___________________________________________________________________________________________________________________________________________________________________
 2. Problem Statement

Users often struggle to decide what to cook or eat. Traditional apps rely only on search. This application improves the experience by:

* Suggesting meals based on time (breakfast, lunch, dinner)
* Adapting to user context
* Providing offline access to previously viewed data
* Engaging users through scheduled notifications

___________________________________________________________________________________________________________________________________________________________________

 3. Features & Functionalities

 3.1 Smart Discovery & Search

  API Integration

* Integrated with TheMealDB API for recipe data
* Handles asynchronous API calls with proper error handling

Time-Based Suggestions

* Morning → Breakfast recipes
* Afternoon → Lunch recipes
* Evening → Dinner recipes

Location-Based Context

* Uses device location to prioritize region-specific recipes (where applicable)
* Gracefully handles permission denial

Search Optimization

* Implements debouncing to avoid excessive API calls
* Improves performance and reduces unnecessary network usage

___________________________________________________________________________________________________________________________________________________________________

### 3.2 Offline-First Experience

Local Persistence

* Favorites are stored locally using Hive database

Caching Strategy

* API responses are cached for reuse
* Previously viewed recipes remain accessible offline

State Resilience

* When network is unavailable:

  * App shows cached recipes
  * No empty or broken UI states
* Ensures consistent user experience

___________________________________________________________________________________________________________________________________________________________________

 3.3 Favorites System

* Users can mark recipes as favorites
* Favorite recipes are:

  * Stored locally
  * Accessible offline
* Includes UI feedback (icon state changes, animations)

___________________________________________________________________________________________________________________________________________________________________
 
 3.4 Notifications System

Scheduled Notifications

* Breakfast → 8:00 AM
* Lunch → 2:00 PM
* Dinner → 7:00 PM

Implementation Details

* Uses `flutter_local_notifications`
* Timezone-aware scheduling
* Supports exact/inexact scheduling depending on device capabilities

Permission Handling

* Requests notification permissions at runtime
* Handles denied permissions without breaking functionality

___________________________________________________________________________________________________________________________________________________________________

 4. Architecture

The application follows Clean Architecture principles with separation of concerns.


lib/
├── core/                # Common utilities, theme, dependency injection
├── features/
│   ├── recipes/         # Recipe feature (data, domain, presentation)
│   ├── favorites/       # Favorites feature
│   ├── notifications/   # Notification logic
└── main.dart


 Layers

Presentation Layer

* Flutter UI
* Bloc for state management

Domain Layer

* Business logic implemented through UseCases

Data Layer

* Repository pattern
* API service + local database (Hive)

---

 5. State Management

* Uses **Bloc (flutter_bloc)** pattern
* Benefits:

  * Predictable state flow
  * Scalable architecture
  * Separation between UI and logic

___________________________________________________________________________________________________________________________________________________________________

 6. UI/UX Implementation

* Shimmer loaders for async operations
* Smooth navigation with Hero animations
* Favorite icon micro-interactions
* Error handling using snackbars and fallback UI
* Offline UI states (no blank screens)

___________________________________________________________________________________________________________________________________________________________________

 7. Notification System Design

* Timezone detection implemented to ensure correct scheduling
* Handles:

  * Device timezone differences
  * Background execution constraints
* Uses inexact scheduling for better compatibility across devices

**Note:**
Due to Android OEM restrictions (e.g., Samsung, Realme), background notifications may require disabling battery optimization for full reliability.

___________________________________________________________________________________________________________________________________________________________________

 8. CI/CD Pipeline

Implemented using GitHub Actions.

 Workflow includes:

1. Run `flutter analyze`
2. Run `flutter test`
3. Build Release APK
4. Upload APK to GitHub Releases

 Workflow file:


.github/workflows/main.yml


 Trigger:


git push origin main


 9. Installation & Setup

git clone https://github.com/Parth-udhani/recipe_discovery.git
cd recipe_discovery
flutter pub get
flutter run

___________________________________________________________________________________________________________________________________________________________________

 10. APK Distribution

The generated APK is available in:

GitHub → Releases section

___________________________________________________________________________________________________________________________________________________________________

 11. Permissions Used

* Notification permission (for scheduled reminders)
* Location permission (for contextual suggestions)
* Storage (for caching data)

___________________________________________________________________________________________________________________________________________________________________

 12. Assignment Requirement Mapping

| Requirement             | Implementation           |
| ----------------------- | ------------------------ |
| API Integration         | Implemented (TheMealDB)  |
| Time-based suggestions  | Implemented              |
| Location-based logic    | Implemented              |
| Search optimization     | Implemented (debouncing) |
| Offline caching         | Implemented              |
| Favorites persistence   | Implemented              |
| Notifications           | Implemented              |
| Permission handling     | Implemented              |
| State management (Bloc) | Implemented              |
| CI/CD pipeline          | Implemented              |

___________________________________________________________________________________________________________________________________________________________________

 13. Limitations

* Background notifications may be delayed on some Android devices
* Exact alarm requires manual permission on certain OEM devices
* Location-based filtering depends on user permission

___________________________________________________________________________________________________________________________________________________________________

 14. Conclusion

This project demonstrates a production-oriented Flutter application with:

* Clean architecture
* Scalable state management
* Offline-first approach
* Real-world notification handling
* Automated CI/CD pipeline

The focus was not just on feature implementation, but also on handling real-world constraints such as network failure, device restrictions, and performance optimization.

___________________________________________________________________________________________________________________________________________________________________

Parth Udhani
Flutter Developer
