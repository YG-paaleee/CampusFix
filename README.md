# CampusFix

CampusFix is a Flutter web-based campus maintenance request and issue tracking system.

## Main Users

- Student
- Maintenance Staff
- Admin

## Core Features

- Students submit maintenance reports.
- Maintenance staff update repair status.
- Admins review and assign reports.

## Firebase Setup

The app has Firebase Firestore support for student reports, but it will keep using local mock data until Firebase is configured.

1. Create a Firebase project.
2. Add a Web app inside the Firebase project.
3. Enable Cloud Firestore.
4. Enable Firebase Authentication.
5. In Authentication > Sign-in method, enable Email/Password.
6. Copy the web Firebase config values.
7. Replace the `REPLACE_ME` values in `lib/firebase_options.dart`.

Firestore collections:

- `reports`
- `students`

Student document path:

- `students/{uid}`

Student document fields:

- `uid`
- `studentId`
- `displayName`
- `email`
- `role`
- `createdAt`

Student account rule:

- Student ID format: `2023-8-0099`
- School email format: `202380099@psu.palawan.edu.ph`
- The app generates the school email from the student ID during signup.
- Login accepts either the student ID or the school email.
- For local Firebase Auth testing, add both `localhost` and `127.0.0.1` in Firebase Authentication > Settings > Authorized domains, then use `http://localhost:5173`.

Report document fields:

- `studentUid`
- `studentId`
- `reportId`
- `submittedAt`
- `title`
- `location`
- `category`
- `urgency`
- `status`
- `description`

Report IDs are generated from Firestore document IDs when Firebase is enabled, so two students do not receive the same visible report ID.

## Initial Structure

- `lib/screens/student` - student pages
- `lib/screens/staff` - maintenance staff pages
- `lib/screens/admin` - admin pages
- `lib/models` - shared data models
- `lib/services` - shared backend/service logic
- `lib/widgets` - reusable UI widgets
