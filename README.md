You are a senior Flutter developer building a School Management System mobile app. The app combines both Parent and Teacher flows in a single Flutter application, starting with a role selection screen. Use **BLoC architecture**, **modular feature-based folder structure**, **Material 3 design**, and **rich animations** (page transitions, hero, shimmer loading, Lottie where suitable). The UI must be **pixel-perfect**, **fully responsive**, and **never overflow** (no RenderFlex overflow errors). Use `go_router` for navigation, `flutter_bloc` for state management, and clean coding practices. API calls can be mocked, but structure the app ready for real endpoints later.

I have an existing Flutter project. You will generate **all required screens, blocs, models, and routing** for the Parent and Teacher modules. After generating every file, run `flutter analyze` internally, and if any errors exist, provide corrected code. The final deliverable must compile with zero analysis errors, zero overflow warnings, and zero best-practice violations.

Here are the detailed specifications. Add missing sensible features where noted.

## 1. App Flow & Role Selection
- **Launch Screen**: Animated splash with school logo, then navigate to Role Selection.
- **Role Selection Screen**: Two large cards – “I’m a Parent” and “I’m a Teacher” – with Hero animations. Tapping navigates to the respective login screen.
- **Parent Login**: Student ID + Password. Forgot password flow (mock). No registration; admin creates accounts.
- **Teacher Login**: Employee ID + Password. Option for OTP verification (mock). No registration.

## 2. Teacher Module (after login)
Bottom navigation with 4 tabs: **Home**, **Attendance**, **Marks**, **Profile**.

### 2.1 Home Tab
- Current date/time, greeting.
- **Check‑in / Check‑out** button (toggles state). When pressed:
  - Request GPS (use mock location if simulator).
  - Show geofence status (green if inside school zone, red if outside).
  - Trigger face verification (mock – show camera preview frame and simulate success/failure).
  - Animated check mark (Lottie) on success.
- Today’s schedule: list of classes with time and subject (mock data).
- Recent attendance history card.

### 2.2 Attendance Tab
- List of own attendance records (date, check‑in time, check‑out time, status).
- Filter by date range.
- Pull-to-refresh, shimmer while loading.

### 2.3 Marks Tab
- **Classes List**: grid of assigned classes (fetch from API/mock).
- Tap a class → **Subjects List** for that class.
- Tap a subject → **Exam List** (e.g., Mid‑Term, Final).
- Tap an exam → **Student Marks Entry Screen**:
  - List of students (profile pic, name, roll no.).
  - For each student, input fields for **obtained marks** and **total marks** (auto‑calculate percentage, grade).
  - **Save as Draft** button (saves locally/server with status “Draft”).
  - Status indicator for each mark entry (Draft / Published).
  - App bar action to **publish marks** (only if authorized – mock teacher as “teacher” role, cannot publish; superadmin button hidden, but show disabled state).
- **Import/Export Excel** option (UI only, button triggers share/file picker, mocked).

### 2.4 Profile Tab
- Teacher details (name, employee ID, photo, department).
- Logout button with confirmation dialog.

### Added Missing Features (Teacher)
- In-app notification bell on app bar (shows count of announcements/absent alerts).
- Quick attendance correction request (if check‑in failed, raise a request – mock).
- View students’ overall attendance (for class teacher role).

## 3. Parent Module (after login)
Bottom navigation with 4 tabs: **Home**, **Marks**, **Notifications**, **Profile**.

### 3.1 Home Tab
- **Child Switcher**: If multiple children, horizontal scrollable chips to select. Each child’s data shown below.
- **Today’s Attendance**: status (Present/Absent/Late) with time stamp, animated icon.
- **Recent Marks**: mini report card with latest exam total, percentage, grade.
- **Upcoming Exams** list (subject, date).
- **Fee Due Alert** (mock: “₹5000 due by 25 June” with pay button – UI only).

### 3.2 Marks Tab
- Per‑child marks overview (switch child at top).
- **Subject‑wise Marks Table**: exam, subject, obtained, total, percentage, grade.
- **Report Card Generation**: button to “Download Report Card” (generates PDF – mock share action).
- **Progress Graph**: line chart of percentage across exams (use `fl_chart` package).

### 3.3 Notifications Tab
- List of push notifications (absence alerts, result declared, events).
- Grouped by date, swipe to dismiss, badge on tab icon.

### 3.4 Profile Tab
- Child details (name, class, section, RFID card ID, photo).
- Parent contact info.
- Change password, logout.

### Added Missing Features (Parent)
- Attendance calendar view (monthly heat map).
- Teacher’s remarks display on marks screen.
- PTM (Parent‑Teacher Meeting) schedule.

## 4. UI/UX & Animation Requirements
- **Material 3**: Use `ColorScheme` with seed color, dynamic theming.
- **Responsive**: All screens wrapped in `SafeArea`, use `LayoutBuilder` or `MediaQuery` to avoid overflow. Text overflow handled with ellipsis. `SingleChildScrollView` where content may exceed height.
- **Animations**:
  - Page transitions: `go_router` with `CustomTransitionPage` (slide up/fade).
  - Hero animation on role selection cards → login screen.
  - Shimmer loading on lists.
  - Lottie for success/error (check‑in success, attendance marked).
  - Bouncy check‑in/out button.
  - Animated list items when marks saved.
- **States**: Every BLoC must emit `loading`, `loaded`, `error` states; UI handles each with shimmer/skeleton, error widget with retry, empty state.

## 5. Technical Architecture
- **Folder structure**:
lib/
├── core/
│   ├── theme/
│   ├── routes/
│   ├── utils/
│   └── widgets/
├── features/
│   ├── auth/
│   │   ├── bloc/
│   │   ├── screens/
│   │   └── models/
│   ├── role_selection/
│   ├── teacher/
│   │   ├── home/
│   │   ├── attendance/
│   │   ├── marks/
│   │   ├── profile/
│   │   └── bloc/
│   ├── parent/
│   │   ├── home/
│   │   ├── marks/
│   │   ├── notifications/
│   │   ├── profile/
│   │   └── bloc/
│   └── shared/
│       └── widgets/
└── main.dart

- Use `equatable` for states/events. Use `freezed` optionally (if you prefer).
- `go_router` with `StatefulShellRoute.indexedStack` for bottom navigation persistence.
- Dummy repositories returning mock data with artificial delay (2 seconds) to show shimmer.
- Packages to use (add to pubspec):
```yaml
flutter_bloc
go_router
equatable
dio (mock)
shimmer
lottie
fl_chart
intl
camera (mock)
geolocator (mock)
flutter_local_notifications (mock)
google_ml_kit (face detection mock)

No hardcoded colors: Use theme extension.

6. Copilot Analysis Command
After you output each screen/BLoC file, run an internal simulation of flutter analyze on the entire generated code. If any analysis error, warning, or overflow risk is detected, fix it immediately and provide the corrected version. State “Analysis passed with 0 issues” at the end of each file.

7. Deliverables
Generate the complete code for:

main.dart with app initialization, theme, and GoRouter setup.

Role Selection Screen + Splash.

Parent Login & Teacher Login screens.

Teacher Bottom Navigation Shell, Home, Attendance, Marks, Profile screens with BLoCs.

Parent Bottom Navigation Shell, Home, Marks, Notifications, Profile screens with BLoCs.

All shared widgets (shimmer list, error widget, animated button, etc.).

Mock models and repositories.

Ensure the code is ready to copy‑paste into my existing project and run on the first try.

Start generating now.