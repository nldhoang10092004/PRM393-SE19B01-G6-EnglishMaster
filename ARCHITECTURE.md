# EnglishMaster – Architecture & coding conventions

## Layers
```
Screen (Widget)  ->  Provider (ChangeNotifier)  ->  Repository  ->  ApiClient (Dio)  ->  EasyEnglish REST API
                                   \-> local storage (secure storage / shared_preferences)
```
* **Screens** only render state and call provider methods. No HTTP, no JSON.
* **Providers** hold UI state (`ViewStatus status`, data, `String? error`) and call repositories.
  Catch `ApiException` and expose `error`; never let exceptions reach widgets.
* **Repositories** call `ApiClient` and map JSON to models. One repository per feature.
* **Models** are immutable classes with `factory X.fromJson(Map<String, dynamic>)`, using the
  tolerant helpers in `core/utils/json_utils.dart` (`json.asInt('courseID')`, case-insensitive).

## Folder structure (feature-first)
```
lib/
  main.dart                 entry point: builds services, runApp
  app.dart                  MultiProvider + MaterialApp + AuthGate
  core/
    config/                 AppConfig (API_BASE_URL via --dart-define, default = deployed HTTPS API)
    l10n/                   AppStrings: every Vietnamese UI string, grouped by feature
    network/                ApiClient (auth header, cookie, refresh, multipart, slow AI calls), ApiException
    router/                 AppRoutes (named routes)
    storage/                TokenStorage (secure storage, in-memory for tests)
    theme/                  AppTheme (Material 3, shared button/card/input shapes)
    utils/                  json helpers, validators, formatters
    widgets/                shared widgets (AsyncView, MessageView)
  features/
    auth/  home/  course/  video/  streak/  flashcard/  vocabulary/
    quiz/  profile/  notifications/  membership/  ai_exam/
  features/<feature>/
    <feature>_providers.dart  static providers() registered in app.dart
    data/
      models/               <name>.dart
      <feature>_repository.dart
    presentation/
      providers/            <feature>_provider.dart
      screens/              <name>_screen.dart
      widgets/              widgets used only by this feature
test/
  unit/                     repositories, providers, models, validators
  widget/                   screens with fake repositories
```

## Rules
* File names `snake_case.dart`, classes `PascalCase`, one public widget per file.
* Every public class and non-trivial method has a `///` doc comment (course requirement).
* UI text in Vietnamese, always through `AppStrings` (or a feature `*Strings` class); learning
  content from the API stays as-is. Use `Theme.of(context)` colors, no hard-coded colors.
* Long-running AI calls show `AiGeneratingView`; media players live in the provider, not in lazy lists.
* Loading / error / empty states through `AsyncView`.
* Lists: `ListView.builder` / `GridView.builder`; `const` constructors wherever possible.
* Pull-to-refresh (`RefreshIndicator`) on list screens.
* A feature never imports another feature's `data/` internals except models it genuinely shares.
* Shared files (`app.dart`, `core/router/app_routes.dart`, `home_shell.dart`) are edited only by the
  integrator; feature tasks list the routes/providers they need in their report.
* `flutter analyze` must be clean and `flutter test` green before handing work over.
