# Study Planner (SwiftUI)

This directory contains Swift source files and guidance to create a SwiftUI iOS app in Xcode that tracks units, assignments, grades, and deadlines.

## Project setup (Xcode)
1. In Xcode, create a new **App** project named `StudyPlanner` using **SwiftUI** and **Swift**. Check **Use Core Data** to include the data model and persistence stack.
2. Set the **Bundle Identifier** to your reverse-DNS value (e.g., `com.example.studyplanner`) in the project **Signing & Capabilities** tab.
3. Set the **Deployment Target** to iOS 17 or later.
4. Configure **App Icons** with an **App Icon** asset set in the asset catalog (1024×1024 square source).
5. If you need sync, enable **iCloud** with **CloudKit** in the target capabilities; otherwise Core Data is local-only.

Copy the Swift files in this folder into the new project, preserving folder groups.

## Features covered
- Dashboard for progress and upcoming deadlines
- Unit list and details with assignment breakdowns
- Assignment detail view with status, grades, and submission links
- Deadline management with pickers, local notifications, and optional calendar export
- Forms for adding/editing units and assignments, grade entry, and preference storage
- Weighted progress calculations and at-risk highlighting
- Search, filter, and sorting for units/assignments
- User defaults for notification lead times and display options
- Sample unit and UI tests for core calculations and reminders

## Running & testing
Run the app in the iOS Simulator. Execute tests with **Product → Test** (⌘U). Ensure you accept notification permissions on first launch to allow reminders.

## Release preparation
- Add App Store screenshots that demonstrate dashboard, unit detail, assignment detail, and forms.
- Include privacy policy text noting notification scheduling and optional calendar export.
- Distribute via TestFlight from Xcode Organizer once a build passes App Store Connect validation.
