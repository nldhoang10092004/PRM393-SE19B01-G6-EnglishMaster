# EnglishMaster Mobile – Plan (demo Tue 10/11/2026)

## Scope
Flutter mobile client (student role) for the EasyEnglish API reused from the team's OJT project
(github.com/Thanhtra213/OJT_PROJECT). The API is deployed separately and is NOT part of this repo.
The report must state that the backend is reused from the team's earlier OJT project.

### Core features (each ~10% of the project score)
1. Auth: login, register, refresh token, logout (`/api/auth/*`), token in secure storage
2. Course list + detail + rating/feedback (`/api/user/course`)
3. Video lesson + progress (`/api/public/video`, `/api/user/video/progress`)
4. Flashcard sets + learn progress (`/api/flashcard/*`)
5. Quiz: start, submit, history (`/api/user/quiz/*`, `/api/attempts`)
6. Saved vocabulary (`/api/user/vocabulary`)
7. Profile + change password (`/api/user/profile/*`)
8. Streak + dashboard (`/api/student/streak`)
9. Local notifications (daily study reminder) + local cache (Module 9/10)
10. State management: Provider (+ repository layer)

Out of the core demo unless keys are provided: AI speaking/writing/quiz (Gemini, Deepgram, Murf),
PayOS payment, email OTP, Google login.

### Course requirements checklist
- [ ] Provider state management, layered: UI -> Provider -> Repository -> ApiClient
- [ ] Remote API + local storage (secure storage, shared_preferences/sqflite cache)
- [ ] >= 1 unit test, >= 1 widget test (aim for more)
- [ ] Release APK, run in release mode on device
- [ ] Code comments
- [ ] Release manifest has INTERNET permission; HTTPS (or network security config)
- [ ] Base URL switchable via `--dart-define=API_BASE_URL=...`

## Tracks
| Track | Owner | Output |
|---|---|---|
| A. Flutter skeleton: architecture, theme, routing, ApiClient, auth, models | Claude | `lib/core`, `lib/features/auth` |
| B. API migration to Postgres + Docker deploy files (separate folder, outside this repo) | Codex | `D:\Study\FA26\PRM393\EnglishMaster_API` |
| C. Feature modules: flashcard, quiz, vocabulary, profile | Codex | `lib/features/<name>` |
| D. Feature modules: course, video, streak, notifications | Claude | `lib/features/<name>` |
| E. Tests (unit + widget) | Codex | `test/` |
| F. Technical report draft (7 sections) | Codex | `docs/report.md` |
| G. Review, integration, release APK, demo script + Q&A | Claude | `docs/demo-script.md` |

## Timeline
- Sat 7/11: restore OJT `.bak` locally, run API, capture real JSON contract. Track A done. Track B started.
- Sun 8/11: Tracks C + D + B finished; deploy API to VPS (after user approval).
- Mon 9/11: Tests, release APK on device, report + demo script, freeze code by evening.
- Tue 10/11: present.

## Postgres migration pitfalls (Track B)
- Raw SQL with `[Answer]`/`[Option]` brackets in `QuizRepository` -> rewrite with `ExecuteDeleteAsync`.
- `HasFilter("([GoogleSub] ...")` bracket syntax; view `vUserHasActiveMembership` must be recreated.
- SQL Server defaults/types (`getdate()`, `newid()`, `nvarchar`, `datetime2`).
- Npgsql + `DateTime.Now`: enable `Npgsql.EnableLegacyTimestampBehavior` or switch to UTC.
- After data copy, reset identity sequences with `setval`.
- EF Core 8 -> Npgsql.EntityFrameworkCore.PostgreSQL 8.x.
- Secrets (JWT key, connection string, API keys) via environment variables, never committed.
- Fallback: SQL Server in Docker on VPS (no code change) or local API + tunnel.
