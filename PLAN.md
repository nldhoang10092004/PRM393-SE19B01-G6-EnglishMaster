# EnglishMaster Mobile – Plan & status (demo Tue 10/11/2026)

## Scope
Flutter mobile client (student role) for the EasyEnglish API reused from the team's OJT project
(github.com/Thanhtra213/OJT_PROJECT). The API was migrated to PostgreSQL and is deployed separately
at `https://em-api.ondevora.shop` (Docker on an ARM64 VPS behind Cloudflare Tunnel); it is NOT part of
this repo. The report must state that the backend is reused from the team's earlier OJT project.

## Status
| Area | Status |
|---|---|
| Auth (login, OTP sign up, forgot password, refresh token, secure storage) | Done |
| Home, courses, video lessons + progress, streak | Done |
| Flashcards with images, study navigation, saved vocabulary | Done |
| Quizzes incl. Listening (audio) and Reading (passages, images) | Done |
| AI exams: speaking, listening, writing, review history (Vietnamese feedback) | Done |
| Membership plans + PayOS VietQR payment (verified with a real 2,000đ payment) | Done |
| Profile, change password, daily study reminder (local notifications) | Done |
| Vietnamese UI, Material 3 theme | Done |
| Unit + widget tests (91) | Done |
| Release APK, API deployed over HTTPS | Done |
| Performance optimisation evidence (split-per-ABI APK, measurements) | To do |
| Technical report (PDF), slides, demo script + Q&A | To do |

## Course requirements checklist
- [x] Provider state management, layered: UI -> Provider -> Repository -> ApiClient
- [x] Remote API + local storage (secure storage, shared_preferences, cookie jar)
- [x] >= 1 unit test, >= 1 widget test (91 tests)
- [x] Release APK, runs in release mode on the emulator
- [x] Code comments (`///` on public classes and methods)
- [x] HTTPS API; cleartext allowed only for the emulator host (network security config)
- [x] Base URL switchable via `--dart-define=API_BASE_URL=...`

## Demo accounts
`student1` / `Student@123` (active membership), `student2` / `Student@123`.

## Demo-day checklist
- Emulator: Extended controls → Microphone → enable "Virtual microphone uses host audio input".
- Check `https://em-api.ondevora.shop/health` returns 200 before presenting.
- Listening AI audio links (Murf) expire after ~72 h: generate a new exercise during the demo.
