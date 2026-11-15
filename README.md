<p align="center">
  <img src="assets/icon/app_icon.png" width="120" alt="MediPulse icon" />
</p>

<h1 align="center">MediPulse</h1>

<p align="center">
  An offline-first medication tracker and prescription assistant, built with Flutter and Dart 3.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3-02569B?logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3-0175C2?logo=dart" alt="Dart" />
  <img src="https://img.shields.io/badge/state-Riverpod-0E4C4F" alt="Riverpod" />
  <img src="https://img.shields.io/badge/backend-Supabase-3ECF8E?logo=supabase" alt="Supabase" />
</p>

---

<!-- Replace these with your own screen recordings (keep each GIF under ~10 MB) -->
| Dashboard | Medical ID flip | Prescription scan |
|:---:|:---:|:---:|
| `docs/dashboard.gif` | `docs/medical_id.gif` | `docs/scanner.gif` |

## Features

- **Live pulse hero card.** The next dose is shown on a card with an animated ECG line drawn by a `CustomPainter`. It beats at a calm 60 BPM, then speeds up and shifts from teal to peach to coral as the dose time approaches.
- **Hold to log, with a heartbeat.** Long-press the card to log a dose without looking for a small button. A "lub-dub" haptic (heavy impact, 120 ms pause, light impact) confirms it.
- **Paramedic flip.** Tilt the phone sharply and the dashboard flips in 3D (`Matrix4` perspective + `rotateY`) into a high-contrast emergency Medical ID: blood type, severe allergies, active medicines and an emergency contact. It reads only from the device, so it works with no signal.
- **Offline prescription scanner.** Google ML Kit text recognition runs on the device. A rule-based parser pulls out medicine names, doses (`500 mg`, `5 ml`) and frequencies (including the `1-0-1` morning-noon-night pattern).
- **Reminders.** Local notifications for the next three days, refreshed whenever the cabinet or the dose log changes. Doses already logged are skipped.
- **Cabinet, Today and History.** Add, edit, finish and swipe-to-remove medicines (with undo), pill stock that counts down as doses are taken, a low-stock warning, and a day-by-day history with a 7-day summary.
- **Cloud backup that never blocks the app.** Optional Supabase sign-in. Every change is saved on the device first and uploaded in the background. Changes made offline upload automatically when the connection returns.

## Architecture

Feature-first clean architecture. Each feature has its own `domain`, `data` and `presentation` layers. Shared code lives in `core`.

```
lib/
├── core/
│   ├── result/        sealed Result<T> (Success with isFromCache, Failure)
│   ├── sync/          OfflineFirstRepository<T>, Supabase snapshot source
│   ├── router/        go_router + tab shell + onboarding guard
│   ├── services/      HapticService
│   ├── providers/     clock (ticks every 30 s, day-change provider)
│   ├── theme/         colours, spacing, text styles
│   └── widgets/       FlipCard3D, PillIllustration, shared UI
└── features/
    ├── dashboard/     hero card, ECG painter, tilt detector, Medical ID card
    ├── medications/   cabinet, dose schedule, dose logs, history
    ├── scanner/       ML Kit OCR + prescription parser
    ├── reminders/     ReminderScheduler interface (Android + web/test logger)
    ├── auth/          Supabase sign-in, AuthRepository
    ├── sync/          sync coordinator (sign-in pull, reconnect push)
    ├── onboarding/    splash + intro
    └── profile/       Medical ID editor, account
```

### Data flow

```
UI (ConsumerWidget)
   │  ref.watch / ref.read(...notifier)
   ▼
Riverpod AsyncNotifier  ──►  derived providers (today's doses, dashboard summary, history)
   │
   ▼
OfflineFirstRepository<T>
   ├── local:  shared_preferences (always, instant)
   └── remote: Supabase user_data table (when signed in, in the background)
```

### Engineering decisions

- **The device is the source of truth.** Reads and writes never wait for the network. A saved "dirty" flag remembers changes that were not uploaded, so they survive an app restart.
- **One generic sync engine.** `OfflineFirstRepository<T>` serves medicines, dose logs and the Medical ID. Upload jobs are queued, so rapid edits arrive in order, and versioning skips stale uploads.
- **Sealed `Result<T>`.** Repositories return `Success` or `Failure`, and Dart 3's exhaustive `switch` makes the UI handle both.
- **Pure, testable domain logic.** Scheduling, dose state (`upcoming / due / taken / skipped / missed`) and route guards take the time as a parameter instead of reading the clock, so the tests need no mocking.
- **Dart 3 throughout.** Records (`typedef DoseEntry = ({...})`), pattern matching with guards (`null when time.isAfter(now)`), destructuring, enhanced enums, and `abstract interface class` for swappable services.
- **Rendering.** The ECG line repaints inside a `RepaintBoundary`, driven by `CustomPainter(repaint: animation)`, so the 60 fps animation never rebuilds the rest of the card.
- **Safe sign-out.** Sign-out waits until every change is uploaded, then clears the device, so the next person never sees the previous person's data.

**Known trade-off:** sync is last-write-wins per data type. Editing on two offline devices at once keeps whichever syncs last. This is acceptable for a single-user app; a multi-user version would need per-record merging.

## Tech stack

| Area | Packages |
|---|---|
| State | `flutter_riverpod` |
| Navigation | `go_router` (StatefulShellRoute, Riverpod-driven redirect) |
| Backend | `supabase_flutter` (auth + Postgres with Row Level Security) |
| Local storage | `shared_preferences` |
| On-device ML | `google_mlkit_text_recognition`, `image_picker` |
| Device | `flutter_local_notifications`, `sensors_plus`, `connectivity_plus` |
| UI | `google_fonts` (bundled Outfit, no runtime downloads) |

## Getting started

```bash
git clone https://github.com/alihassanbalochdev/medipulse.git
cd medipulse
flutter pub get
flutter run
```

The app runs fully without a backend (local-only mode). To enable cloud backup:

1. Create a Supabase project and run [`supabase/schema.sql`](supabase/schema.sql) in the SQL Editor.
2. Copy `env.json.example` to `env.json` and fill in your project URL and publishable (anon) key.
3. Run with `flutter run --dart-define-from-file=env.json`.

`env.json` is git-ignored. Never commit a `service_role` or secret key.

## Tests

```bash
flutter test
```

Covers the prescription parser, dose scheduling, dose states, reminder planning, route guards, date labels, and the offline-first sync engine (offline fallback, retry after reconnect, ordered uploads, conflict rule).

## Platform notes

- Camera scanning, reminders and tilt-to-flip need a real Android device. On web, reminders are printed to the debug console instead.
- Minimum Android version: 7.0 (API 24).

## Disclaimer

MediPulse is a reminder and record-keeping tool. It does not give medical advice. Always follow your doctor's or pharmacist's instructions, and check scanned prescriptions before relying on them.

## Author

**Ali Hassan Baloch** · Flutter developer
GitHub: [@alihassanbalochdev](https://github.com/alihassanbalochdev) · Portfolio: [alihassanbdev.netlify.app](https://alihassanbdev.netlify.app)

Built with AI assistance (Claude) for design exploration and code generation. Architecture decisions, integration, testing and review by the author.
