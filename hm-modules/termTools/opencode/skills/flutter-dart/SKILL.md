---
name: flutter-dart
description: Use when writing, fixing, or reviewing Flutter/Dart code, or handling flutter analyze, flutter test, build_runner failures.
---

# Flutter/Dart dev cycle (analyze + test + build_runner)

Distilled from official `flutter/agent-plugins` + `dart-lang/skills` and
VeryGoodVentures plugin (`very_good_analysis`, `bloc`, `green-gate` loop).

## 1. Full cycle (every change)

```
1. Explore → read feature folder + existing widget/unit tests first
2. Implement → respect feature-first layout (see §3)
3. Fix loop → pub get → build_runner → analyze → test
4. Verify → all four gates below green
```

## 2. QA gates (in this order)

```bash
flutter pub get                                       # deps
dart run build_runner build --delete-conflicting-outputs  # codegen (only if models/freezed/riverpod changed)
flutter analyze                                       # lint+type gate — fix every error before proceeding
flutter test                                          # test gate (add --coverage for release work)
```

Release preflight additionally: version bump in `pubspec.yaml`, `flutter build apk --release`
(or `ipa`), confirm artifact under `build/app/outputs/`.

## 3. Rules

- Layout: `lib/features/<name>/{data,domain,presentation/}` + barrel `feature.dart`.
- State: one manager (Bloc **or** Riverpod per project — never mix). No business logic in widgets.
- Models: `freezed` + `json_serializable`; never hand-edit `*.g.dart` / `*.freezed.dart`.
- Navigation: GoRouter named routes; DI via `get_it`/`injectable` where the project uses it.
- Tests: unit (`mocktail`, `blocTest` for Bloc) + widget (`pumpApp`) for new behavior;
  bugfix needs a reproducing test first. Never commit with `flutter analyze` errors.
- Lints: `very_good_analysis` (or repo's `analysis_options.yaml`) is the law; fix, don't suppress.
