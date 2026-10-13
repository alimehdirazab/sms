# School Management System (SMS) — Flutter Mobile App

A single Flutter app combining **Parent** and **Teacher** flows, starting from a role
selection screen. Built with **BLoC architecture**, a **modular feature-based folder
structure**, **Material 3** design and **rich animations**.

---

## 0. Current Implementation Status

✅ `flutter analyze` → **No issues found (0 errors, 0 warnings, 0 infos)**

All screens, BLoCs, models, repositories and routing described below are implemented and
compiling. API calls are mocked with artificial delays so shimmer/skeleton states are
visible; repositories are structured so they can be swapped for real HTTP clients later.

### Feature coverage

| Area | Status |
|---|---|
| Splash + Role selection (Hero cards) | ✅ |
| Parent login / Teacher login (+ OTP) | ✅ |
| Teacher: Home, Attendance, Marks, Profile shell | ✅ |
| Parent: Home, Marks, Notifications, Profile shell | ✅ |
| **Parent leave applications (multi-type + optional description + attachment)** | ✅ |
| **Parent dashboard progress charts (attendance + marks trend)** | ✅ |
| **Parent academic calendar (month grid + events)** | ✅ |
| **Parent fee payment → school account details → screenshot → pending → verified** | ✅ |
| **Teacher leave applications → sent to Principal (separate web app) for approval** | ✅ |
| **Teacher attendance chart + class average chart** | ✅ |
| **Teacher academic calendar** | ✅ |
| **Teacher full-week class timetable** | ✅ |
| **Teacher late check-in comment prompt** | ✅ |
| **Teacher remarks/comments on student marks** | ✅ |
| Theme extension for semantic status colours | ✅ |

---

## 1. App Flow & Role Selection

- **Launch/Splash**: animated logo (fade + scale), then navigates to Role Selection.
- **Role Selection**: two large Hero-animated cards — “I’m a Parent”, “I’m a Teacher”.
- **Parent Login**: Student ID + Password, mock forgot-password flow.
- **Teacher Login**: Employee ID + Password, with mock OTP verification path.

---

## 2. Teacher Module

Bottom navigation: **Home**, **Attendance**, **Marks**, **Profile**.

### 2.1 Home Tab
- Current date/time + greeting.
- **Check-in / Check-out** toggle with geofence status indicator and animated bouncy button.
- **Late check-in comment**: when checking in after 08:30 a `Late` pill appears and an
  optional comment dialog is shown (`AddLateCheckInComment` event) so the record explains
  the delay.
- **Attendance chart** — bar chart of presence over the last 6 working days.
- **Class average chart** — bar chart of average marks per assigned class.
- Stat cards: *My Attendance %*, *Class Average %*.
- **Academic calendar preview** with a “View All” link.
- Quick actions: *Apply Leave*, *Week View*, *Calendar*.
- Today’s schedule (with a **Full Week** shortcut) and recent attendance history.

### 2.2 Attendance Tab
- Own attendance records (date, check-in, check-out, status), date-range filter,
  pull-to-refresh and shimmer loading, plus an in-line correction request for absences.

### 2.3 Marks Tab
- Classes grid → Subjects → Exams → **Student Marks Entry**.
- Obtained/total inputs with live percentage + grade.
- **Remarks field per student** — free-text comment saved with the marks
  (`StudentMarkModel.teacherRemarks`), displayed to parents in the Parent flow.
- **Save as Draft**; publish action disabled for the teacher role (only admin/superadmin
  can publish) — shown in a disabled state with an explanatory tooltip.
- Import/Export (UI only, mocked).

### 2.4 Profile Tab
- Teacher details (name, employee ID, department, contact, publish rights).
- Quick links: **Weekly Timetable**, **Leave Applications**, **Academic Calendar**.
- Logout with confirmation dialog.

### 2.5 Leave (Teacher) — *new*
- App bar + quick action + profile entry point.
- Summary stats: Pending / Approved / Days Used.
- **Apply Leave** bottom sheet: leave type chips, from/to date pickers, computed day
  count, optional description, optional attachment (mock).
- Submissions are addressed to the **Principal**, who reviews them in the **separate web
  application**; on this app they remain **Pending** until reviewed. Approved/rejected
  entries show the Principal’s remarks.
- Pending applications can be withdrawn.

### 2.6 Weekly Timetable — *new*
- Tabbed per weekday (Mon–Sat) with the current day highlighted.
- Each period shows time, subject, class/section, and a **Now** / **Next** badge.

### 2.7 Academic Calendar (Teacher) — *new*
- Month grid with colour-coded event dots, month navigation, and an event list for the
  selected day.

---

## 3. Parent Module

Bottom navigation: **Home**, **Marks**, **Alerts**, **Profile**.

### 3.1 Home Tab
- **Child Switcher** (chips) for multiple children.
- Quick actions: *Apply Leave*, *Pay Fees*, *Calendar*.
- **Snapshot stat cards**: Attendance % and Average % (with grade).
- **Progress Overview card**:
  - Attendance progress bar (colour-coded against the 75% threshold).
  - **Marks trend bar chart** across exams.
- Today’s attendance card, Recent Marks (with grade pills), Upcoming Exams.
- **Academic calendar preview** (3 upcoming events) with “View All”.
- **Fee Due Alert**: real outstanding amount, a **Pay Now** button that opens the fee
  screen, and an inline notice when payments are awaiting verification.

### 3.2 Marks Tab
- Per-child marks overview, subject-wise table, teacher remarks, and `fl_chart` progress
  graph across exams. Report card download (mocked share action).

### 3.3 Notifications Tab
- Date-grouped notifications, swipe to dismiss, tab badge.

### 3.4 Profile Tab
- Child details (name, class, section, RFID, photo), parent contact info.
- Quick links: **Leave Applications**, **Fees & Payments**, **Academic Calendar**.
- Monthly attendance calendar heat map, PTM schedule, change password, logout.

### 3.5 Leave Applications (Parent) — *new*
- Summary stats (Pending / Approved / Days).
- **Apply Leave** bottom sheet with many leave types:
  *Sick, Casual, Emergency, Family Function, Vacation, Medical/Hospital, Sports,
  Exam Related, Half Day, Late Arrival, Other.*
- From/To date pickers with validated ranges and auto-corrected end date.
- **Optional description** (up to 300 chars) and optional supporting-document attachment
  (mock).
- Status pills: **Pending / Approved / Rejected / Cancelled**, with the Principal’s
  remarks shown once reviewed. Pending requests can be cancelled.

### 3.6 Fees & Payments (Parent) — *new*
- Outstanding total + pending-verification stat cards.
- Fee cards with amount, balance, due date and Paid/Due/Overdue badges.
- **Pay Now** opens a two-step payment sheet:
  1. **School account details** (account name/number, IFSC, bank & branch, UPI) with
     copy-to-clipboard buttons.
  2. Amount, optional transaction reference, and a **required screenshot attachment**
     (mock image picker).
- On submit the payment is created with status **Pending** and a message explains it will
  update after verification; the Payment History section shows **Pending → Verified /
  Rejected** with the office’s verification remarks.

### 3.7 Academic Calendar (Parent) — *new*
- Same month grid + event list UI as the teacher calendar, with parent-relevant events
  (exams, PTM, results, holidays, vacations).

---

## 4. UI/UX & Animation Requirements

- **Material 3** `ColorScheme.fromSeed` with light & dark themes.
- **Theme extension**: `AppStatusColors` (`lib/core/theme/app_status_colors.dart`) provides
  semantic `success / warning / danger / info / neutral` colours in both brightnesses, so
  new screens avoid hardcoded literals.
- **Responsive / overflow-safe**: `SafeArea`, ellipsized text, `Wrap` for chip groups,
  `Expanded`/`Flexible` for rows, `SingleChildScrollView` where content may exceed height.
- **Animations**: `go_router` slide+fade page transitions, Hero role cards, shimmer
  skeletons, animated bouncy buttons, animated bar-chart growth (`TweenAnimationBuilder`).
- **States**: every BLoC emits loading / loaded / error; the UI renders shimmer, an error
  widget with retry, and an empty-state widget.

---

## 5. Technical Architecture

### Folder structure

```
lib/
├── main.dart
├── core/
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── app_status_colors.dart          # ThemeExtension (semantic colours)
│   ├── routes/app_router.dart
│   ├── utils/                              # date_formatter, mock_delay
│   └── widgets/                            # animated_button, error_widget, shimmer_loading
└── features/
    ├── auth/
    │   ├── bloc/auth_bloc.dart
    │   ├── models/
    │   │   ├── user_model.dart
    │   │   ├── attendance_model.dart
    │   │   ├── marks_model.dart
    │   │   ├── notification_model.dart
    │   │   ├── leave_model.dart            # NEW
    │   │   ├── fee_model.dart              # NEW
    │   │   └── academic_calendar_model.dart # NEW
    │   └── screens/                        # splash, parent_login, teacher_login
    ├── role_selection/
    ├── shared/widgets/                     # stat_card, progress_charts, academic_calendar_view
    ├── parent/
    │   ├── bloc/                           # parent_bloc, mock_parent_repository
    │   ├── home/
    │   ├── marks/
    │   ├── notifications/
    │   ├── profile/
    │   ├── leave/                          # NEW
    │   ├── fees/                           # NEW
    │   └── calendar/                       # NEW
    └── teacher/
        ├── bloc/                           # teacher_bloc, mock_teacher_repository
        ├── home/
        ├── attendance/
        ├── marks/                          # incl. remarks entry
        ├── profile/
        ├── leave/                          # NEW
        ├── calendar/                       # NEW
        └── schedule/                       # NEW (weekly timetable)
```

### Navigation

`go_router` with `StatefulShellRoute.indexedStack` for bottom-nav persistence. New
sub-routes (`leave`, `fees`, `calendar`, `schedule`) hang off the `home` branch and use
`parentNavigatorKey: _rootNavigatorKey` so they push full-screen over the shell.

`RouteNames` additions: `parentLeave`, `parentFees`, `parentCalendar`, `teacherLeave`,
`teacherCalendar`, `teacherWeeklySchedule`.

### Key events (new)

**ParentBloc**: `LoadLeaveApplications`, `SubmitLeaveApplication`,
`CancelLeaveApplication`, `LoadFees`, `SubmitFeePayment`, `LoadAcademicCalendar`,
`LoadStudentAnalytics`.

**TeacherBloc**: `LoadTeacherLeaveApplications`, `SubmitTeacherLeaveApplication`,
`CancelTeacherLeaveApplication`, `LoadTeacherWeeklySchedule`, `LoadTeacherCalendar`,
`LoadTeacherAnalytics`, `AddLateCheckInComment`.

### Dependencies (`pubspec.yaml`)

```yaml
flutter_bloc, go_router, equatable, shimmer, lottie, fl_chart, intl,
dio, geolocator, camera, google_ml_kit, flutter_local_notifications,
path_provider, share_plus, font_awesome_flutter
```

> **Deviation from the original spec**: `fl_chart` drives the Marks progress graph, while
> the new compact dashboard charts use a dependency-free custom `MiniBarChart` widget for
> consistent styling and zero extra weight.

### Theme colours

No hardcoded status colours in new code — read them via
`AppStatusColors.of(context)` (with a safe `light` fallback if the extension is absent).

---

## 6. Data & Mock Behaviour

- Repositories return mock data with artificial delays (`MockDelay.simulate`), making
  shimmer/skeleton states visible.
- Leave submissions and fee payments are kept in an in-memory session store, so newly
  created entries remain visible while the app runs and start in a **Pending** state.
- School bank account details come from `MockParentRepository.getSchoolAccount()`.
- `getStudentAnalytics` (parent) and `getTeacherAnalytics` (teacher) derive chart data
  from the mocked attendance and marks so the dashboards stay consistent.

---

## 7. Running the Project

```bash
flutter pub get
flutter analyze     # expected: No issues found!
flutter run
```

**Demo credentials** (any non-empty credentials succeed):

| Role | ID | Password |
|---|---|---|
| Parent | `p1` | `parent` |
| Teacher | `t1` | `teacher` |

Teacher OTP flow accepts any 6-digit code.

---

## 8. Notes / Follow-ups

- Camera, geolocation, notifications, ML Kit face detection and file picking are mocked;
  wire up the real plugins when backend endpoints are available.
- The **Principal approval** UI lives in the separate web application; this app only
  submits and displays the resulting status.
- `dio` is present as a dependency but unused until real endpoints replace the mock
  repositories.
