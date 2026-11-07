# AI exam integration

Register the repository after the app's existing `Provider<ApiClient>`:

```dart
import 'features/ai_exam/ai_exam_providers.dart';

MultiProvider(
  providers: [
    // Existing ApiClient and other providers...
    ...AiExamProviders.providers(),
  ],
  child: /* existing app */,
)
```

Open `const AiExamHubScreen()` from
`presentation/screens/ai_exam_hub_screen.dart`. No named routes are required:
the hub pushes speaking, listening, writing and review screens directly.
Each screen creates and disposes its own ChangeNotifier provider. Shared
registration contains only `AiExamRepository`, so simultaneous routes do not
share drafts, recordings or review details.

**ApiClient additions: none.** The existing `get`, `postSlow` and
`postMultipart` methods already cover every request. AI POSTs use the client's
90-second timeout; multipart uses its existing 90-second default. No package,
manifest, shell or app registration files were changed by this feature.

## Source files

- `ai_exam_strings.dart`: all Vietnamese interface and error copy.
- `ai_exam_providers.dart`: shared dependency registration.
- `data/models/ai_exam.dart`: prompt, question, scoring, answer review and history models.
- `data/ai_exam_repository.dart`: authenticated REST requests and response mapping.
- `data/ai_exam_recorder.dart`: microphone permission, temporary AAC/M4A recording and cleanup.
- `presentation/providers/ai_exam_provider.dart`: independent skill sessions, validation and friendly errors.
- `presentation/providers/ai_review_provider.dart`: history/detail loading states.
- `presentation/screens/`: hub, speaking, listening, writing, history and detail.
- `presentation/widgets/`: exercise state, prompt, AI generating view, structured feedback and audio controls.
- `test/unit/ai_exam/`: model, repository contract and provider state tests.
- `test/widget/ai_exam/`: writing input, word count, submission and feedback test.

## Verified backend contracts

Read from `Controllers/AIExam`, `DTOs/AIExam`, `Services/AIExam`,
`Repositories/AIExam/AIReviewRepository.cs` and the AI/Murf external services.
All routes require a signed-in `STUDENT`. Membership checks can return HTTP
400 with a plain English error rather than 403. The feature maps these to
Vietnamese and never renders raw server error payloads or credentials.

### Speaking

- `POST /api/user/ai-speaking/generate`, no body.
- Response: `{promptId, title, content}`.
- `POST /api/user/ai-speaking/submit`, multipart form:
  `file` (recorded M4A), `promptId` (integer).
- Backend upload limit: 25,000,000 bytes. The UI caps recording at five minutes
  using 64 kbps mono AAC, comfortably below that limit.
- Response: `{transcript, score, fluency, lexicalResource, grammar,
  pronunciation, feedback}`. Scores use IELTS bands, including half bands.

### Listening

- `POST /api/user/ai-listening/generate`, no body.
- Response: `{promptId, title, script, audioUrl, questions:[{questionId,
  type, content, options:[{content}]}]}`. `script` is normally empty on
  generation; the UI reveals the returned transcript only after submission.
- Type 1 is multiple choice; type 2 is text completion with null options.
- Murf requests MP3 URLs (`encodeAsBase64:false`); multiple chunks are joined
  by commas in `audioUrl`. Controls support automatic chunk advancement,
  manual previous/next, play/pause and seek within the current chunk. They
  also accept encoded audio or data URIs if the external service returns one.
- `POST /api/user/ai-listening/submit` JSON:
  `{promptId, answers:[{questionId, answer}]}`. Choice answers are the exact
  **option content**, not letters or IDs.
- Response: `{score, total, script, results:[{questionId, content,
  userAnswer, correctAnswer, isCorrect}]}`. Score is correct answers, not an
  IELTS band. This service does not persist submissions/history.

### Writing

- `POST /api/user/ai-writing/generate`, no body.
- Response: `{promptId, title, content}`.
- `POST /api/user/ai-writing/submit` JSON:
  `{promptId, answerText}`.
- Backend requires **at least 150 words**. The editor displays a live word count
  and disables submission until the minimum is reached.
- Response: `{score, taskResponse, coherence, lexicalResource, grammar,
  feedback, attemptId}`. The current backend always returns `attemptId:0`;
  it is not used as a submission/review ID.

### Feedback and history

Speaking/writing feedback is usually an object with `overall`, skill criteria,
`comment`, `issues`, `suggestions`, `weakPhrases:[{original,suggestion}]` and
`errors:[{original,correction,explanation}]`. Stored feedback is a JSON string;
plain text is also supported. Interface headings are Vietnamese; generated
English exam content and server-authored feedback are displayed verbatim.

Speaking/writing submissions are always saved to the student's own history
(standalone app, no teacher sharing).
and explains its effect. There is no separate save-only endpoint.

- `GET /api/user/review/list` returns a bare array of
  `{submissionId, aireviewId, prompt:{title,content}, scoreOverall, createdAt,
  isTeacherReviewed}`. It does not return `skillType` or listening attempts.
- `GET /api/user/review/{submissionId}` returns
  `{prompt:{title,content}, answer:{transcript,answerText},
  aiReview:{scoreOverall,scoreFluency,scoreLexical,scoreGrammar,
  scorePronunciation,scoreCoherence,feedback}, teacherReview:null|{scoreOverall,
  scoreTask,scoreLexial,scoreGrammar,scorePronunciation,scoreFluency,
  scoreCoherence,feedback}}`.
- Teacher vocabulary is literally spelled `scoreLexial` in the backend query.
  Null criteria remain absent in the UI rather than being shown as zero.

Missing Gemini/Murf/Deepgram configuration, expired membership, authentication,
permissions, timeouts, connectivity and invalid responses produce Vietnamese
errors. Failed grading/generation retains current work for retry. Closing a
speaking route stops capture and cleans up only that session's temporary files.

## Verification

```sh
flutter analyze lib/features/ai_exam test/unit/ai_exam test/widget/ai_exam
flutter test test/unit/ai_exam test/widget/ai_exam
```

Native microphone capture and real audio playback still require device testing.
Live generation/grading requires configured backend service keys and membership.
