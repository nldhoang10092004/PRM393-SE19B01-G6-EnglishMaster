/// Vietnamese interface copy. API learning content stays unchanged.
class AppStrings {
  AppStrings._();

  static const welcomeBack = 'Chào mừng trở lại!';
  static const mimiWaiting = 'Mimi đang chờ bạn luyện tiếp hôm nay.';
  static const brandInitials = 'EM';
  static const searchCourses = 'Tìm khóa học';
  static const noMatchingCourses = 'Không tìm thấy khóa học phù hợp.';
  static const courseContent = 'Nội dung khóa học';
  static const speaking = 'Nói';
  static const listening = 'Nghe';
  static const writing = 'Viết';
  static const reading = 'Đọc';
  static const all = 'Tất cả';
  static const studying = 'Đang học';
  static const dailyReview = 'Ôn 5 thẻ mỗi ngày';
  static const dailyReviewHint = 'Học thẻ cũng được tính vào chuỗi ngày học.';
  static const todayGoal = 'Mục tiêu hôm nay';
  static const wellDone = 'Làm tốt lắm!';

  /// Label for opening the next available lesson.
  static String continueLesson(String name) => 'Học tiếp: $name';

  // Common
  static const changeAvatar = 'Đổi ảnh đại diện';
  static const choosePhoto = 'Chọn ảnh từ thư viện';
  static const takePhoto = 'Chụp ảnh';
  static const avatarUpdated = 'Đã cập nhật ảnh đại diện';
  static const avatarUploadError = 'Chưa thể cập nhật ảnh. Bạn thử lại nhé!';
  static const photoPickerError =
      'Không thể mở ảnh. Vui lòng kiểm tra quyền truy cập ảnh hoặc máy ảnh.';
  static const viewAll = 'Xem tất cả';
  static const continueLearning = 'Tiếp tục học';
  static const discoverCourses = 'Khám phá khóa học';
  static const accountSettings = 'Cài đặt tài khoản';
  static const correctAnswers = 'Câu đúng';
  static const wrongAnswers = 'Câu sai';
  static const pendingAnswers = 'Chờ chấm';
  static const loadingContent = 'Đang tải nội dung';
  static const unknownInitial = '?';
  static const unavailableValue = '—';
  static const appName = 'EnglishMaster';
  static const empty = 'Chưa có nội dung.';
  static const genericError = 'Đã xảy ra lỗi. Vui lòng thử lại.';
  static const retry = 'Thử lại';
  static const cancel = 'Hủy';
  static const submit = 'Gửi';
  static const saving = 'Đang lưu…';
  static const student = 'Học viên';
  static const notSet = 'Chưa cập nhật';

  /// Builds a greeting line that includes the student's name.
  static String greetingName(String greeting, String name) =>
      '$greeting, $name';
  static const unexpectedError =
      'Đã xảy ra lỗi không mong muốn. Vui lòng thử lại.';

  // Validation
  static const field = 'Trường này';
  static const invalidEmail = 'Vui lòng nhập địa chỉ email hợp lệ';
  static const shortPassword = 'Mật khẩu phải có ít nhất 6 ký tự';
  static const passwordMismatch = 'Mật khẩu xác nhận không khớp';
  static const invalidOtp = 'Mã OTP chỉ được gồm chữ số';
  static const phoneDigits = 'Vui lòng nhập từ 9 đến 11 chữ số';

  /// Error text shown when a required form field is empty.
  static String requiredField(String field) => '$field không được để trống';

  // Network
  static const timeout = 'Máy chủ phản hồi quá lâu. Vui lòng thử lại.';
  static const connectionError =
      'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.';
  static const sessionExpired =
      'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';

  /// Error text for a failed server call, based on the HTTP status.
  static String serverError(int? status) => status == null
      ? genericError
      : 'Đã xảy ra lỗi (mã $status). Vui lòng thử lại.';

  // Auth
  static const email = 'Email';
  static const password = 'Mật khẩu';
  static const username = 'Tên đăng nhập';
  static const emailOrUsername = 'Email hoặc tên đăng nhập';
  static const confirmPassword = 'Xác nhận mật khẩu';
  static const otp = 'Mã OTP';
  static const otpCode = 'Mã OTP';
  static const forgotPassword = 'Quên mật khẩu';
  static const forgotPasswordLink = 'Quên mật khẩu?';
  static const resetSent =
      'Nếu email đã được đăng ký, bạn sẽ nhận được liên kết đặt lại mật khẩu.';
  static const resetHint =
      'Nhập email tài khoản để nhận liên kết đặt lại mật khẩu.';
  static const sendReset = 'Gửi liên kết đặt lại';
  static const tagline = 'Học tiếng Anh mỗi ngày';
  static const login = 'Đăng nhập';
  static const signupPrompt = 'Chưa có tài khoản? Đăng ký';
  static const otpSent = 'Đã gửi mã OTP. Bạn hãy kiểm tra hộp thư nhé.';
  static const register = 'Đăng ký';
  static const createAccount = 'Đăng ký';
  static const resend = 'Gửi lại';
  static const sendOtp = 'Gửi mã OTP';

  /// Message shown when a feature is limited to student accounts.
  static String studentOnly(String? role) =>
      'Ứng dụng dành cho học viên. Vui lòng dùng trang web cho tài khoản ${switch (role?.toUpperCase()) {
        'ADMIN' => 'quản trị viên',
        'TEACHER' => 'giáo viên',
        _ => 'có vai trò khác',
      }}.';

  // Course
  static const course = 'Khóa học';
  static const chapters = 'Chương';
  static const reviews = 'Đánh giá';
  static const noReviews = 'Chưa có đánh giá';
  static const otherLessons = 'Bài học khác';
  static const noLessons = 'Chưa có bài học.';
  static const free = 'Miễn phí';
  static const reviewThanks = 'Cảm ơn bạn đã đánh giá!';
  static const writeReview = 'Viết đánh giá';
  static const firstReview = 'Hãy là người đầu tiên đánh giá khóa học này.';
  static const rateCourse = 'Đánh giá khóa học';
  static const reviewHint = 'Chia sẻ trải nghiệm của bạn (không bắt buộc)';
  static const invalidCourse =
      'Không thể đọc dữ liệu khóa học. Vui lòng thử lại.';

  /// Label naming the teacher of a course.
  static String teacherBy(String name) => 'Giảng viên: $name';

  /// Summary of the average course rating and the rating count.
  static String ratingSummary(double average, int total) =>
      '${average.toStringAsFixed(1)} ($total)';

  /// Count label for lessons.
  static String lessonCount(int count) => '$count bài học';

  /// Count label for star ratings.
  static String starCount(int count) => '$count sao';

  // Flashcard
  static const flashcardSet = 'Bộ thẻ ghi nhớ';
  static const studySet = 'Học bộ thẻ';
  static const noCards = 'Bộ thẻ này chưa có thẻ ghi nhớ.';
  static const studyHistory = 'Lịch sử học';
  static const noStudyHistory = 'Chưa có lịch sử học.';
  static const mastered = 'Đã thuộc';
  static const reviewed = 'Đã ôn tập';
  static const flashcards = 'Thẻ ghi nhớ';
  static const noSets = 'Chưa có bộ thẻ ghi nhớ.';
  static const study = 'Học thẻ';
  static const saveVocabulary = 'Lưu vào từ vựng';
  static const savedVocabulary = 'Đã lưu vào từ vựng';
  static const saveWordError = 'Không thể lưu từ vựng.';
  static const setComplete = 'Bạn đã học xong bộ thẻ!';
  static const backToSet = 'Về bộ thẻ';
  static const emptySet = 'Bộ thẻ này chưa có thẻ ghi nhớ.';
  static const flipCard = 'Lật thẻ ghi nhớ';
  static const tapToFlip = 'Chạm để lật thẻ';
  static const again = 'Học lại';
  static const gotIt = 'Đã thuộc';
  static const previousCard = 'Thẻ trước';
  static const nextCard = 'Thẻ sau';
  static const studyUnmastered = 'Học tiếp thẻ chưa thuộc';
  static const masteredBadge = 'Đã thuộc';

  /// Flashcard position label, such as card 3 of 11.
  static String cardPosition(int current, int total) => 'Thẻ $current/$total';

  /// Study summary showing mastered cards out of the total and the review count.
  static String studySummaryTotal(int mastered, int total, int reviews) =>
      'Đã thuộc $mastered/$total thẻ · $reviews lượt ôn trong phiên này.';
  static const openToStudy = 'Mở để học';
  static const detailsUnavailable = 'Không thể tải thông tin';
  static const progressUnavailable = 'Không thể tải tiến độ';
  static const loadingDetails = 'Đang tải thông tin';
  static const historyLoadError = 'Không thể tải lịch sử học.';
  static const flashcardsLoadError = 'Không thể tải thẻ ghi nhớ.';
  static const progressError = 'Không thể tải tiến độ học.';
  static const setLoadError = 'Không thể tải bộ thẻ này.';
  static const recordLearningError =
      'Không thể lưu kết quả học. Vui lòng thử lại.';

  /// Progress label showing mastered cards out of the total.
  static String masteredTotal(int count, int total) =>
      'Đã thuộc $count / $total thẻ';

  /// Study summary showing the card count and the review count.
  static String studySummary(int count, int reviews) =>
      'Đã thuộc $count thẻ sau $reviews lượt ôn tập.';

  /// Progress label showing studied and remaining card counts.
  static String studyProgress(int count, int remaining) =>
      'Đã thuộc $count thẻ · Còn $remaining thẻ';

  /// Count label for flashcards.
  static String cardCount(int count) => '$count thẻ';

  /// Label showing how many flashcards are mastered.
  static String masteredCount(int count) => 'Đã thuộc $count thẻ';

  /// One learning-history line combining an action and its date.
  static String historyEntry(String action, String date) => '$action · $date';

  // Home
  static const allCourses = 'Tất cả khóa học';
  static const noCourses = 'Chưa có khóa học.';
  static const home = 'Trang chủ';
  static const morning = 'Chào buổi sáng';
  static const afternoon = 'Chào buổi chiều';
  static const evening = 'Chào buổi tối';
  static const readyToLearn = 'Bạn đã sẵn sàng học điều mới chưa?';

  // Notifications
  static const reminderChannel = 'Nhắc nhở học tập';
  static const reminderDescription = 'Nhắc bạn luyện tiếng Anh mỗi ngày';
  static const practiceTime = 'Đến giờ luyện tiếng Anh rồi!';
  static const dailyReminderBody =
      'Học vài phút hôm nay để duy trì chuỗi ngày học nhé.';
  static const startStreak = 'Bắt đầu chuỗi ngày học';
  static const studyMinutes = 'Dành vài phút học hôm nay nhé.';
  static const studyReminder = 'Nhắc nhở học tập';
  static const dailyReminder = 'Nhắc hằng ngày';
  static const dailyReminderHint = 'Nhận lời nhắc học mỗi ngày';
  static const reminderTime = 'Giờ nhắc học';
  static const sendTest = 'Gửi thông báo thử';
  static const permissionDenied =
      'Chưa được cấp quyền thông báo. Bạn hãy bật quyền trong cài đặt hệ thống.';
  static const testReminder = 'Đây là thông báo nhắc học thử.';

  /// Reminder text encouraging the student to keep the study streak.
  static String keepStreak(int days) => 'Giữ chuỗi $days ngày học của bạn nhé!';
  static const reminderUpdateError =
      'Không thể cập nhật lời nhắc. Vui lòng thử lại.';
  static const notificationShowError =
      'Không thể hiển thị thông báo. Vui lòng thử lại.';

  // Profile
  static const profile = 'Hồ sơ';
  static const avatarError = 'Không thể tải ảnh đại diện.';
  static const membershipStatusError = 'Không thể tải trạng thái gói hội viên.';
  static const statsError = 'Không thể tải thống kê học tập.';
  static const profileLoadError = 'Không thể tải hồ sơ của bạn.';
  static const saveChangesError = 'Không thể lưu thay đổi. Vui lòng thử lại.';
  static const passwordChanged = 'Đã đổi mật khẩu';
  static const changePassword = 'Đổi mật khẩu';
  static const currentPassword = 'Mật khẩu hiện tại';
  static const newPassword = 'Mật khẩu mới';
  static const confirmNewPassword = 'Xác nhận mật khẩu mới';
  static const showPasswords = 'Hiện mật khẩu';
  static const profileUpdated = 'Đã cập nhật hồ sơ';
  static const editProfile = 'Chỉnh sửa hồ sơ';
  static const fullName = 'Họ và tên';
  static const phone = 'Số điện thoại';
  static const address = 'Địa chỉ';
  static const dateOfBirth = 'Ngày sinh';
  static const cannotClearProfile =
      'Bạn chưa thể xóa số điện thoại, địa chỉ và ngày sinh đã lưu.';
  static const saveChanges = 'Lưu thay đổi';
  static const dayStreak = 'Chuỗi ngày học';
  static const attempts = 'Lượt làm bài';
  static const words = 'Từ vựng';
  static const membershipUnavailable = 'Không thể tải gói hội viên';
  static const activeMembership = 'Hội viên đang hoạt động';
  static const noMembership = 'Chưa có gói hội viên còn hiệu lực';
  static const quizMembershipRequired =
      'Cần có gói hội viên để làm bài kiểm tra của khóa học.';
  static const manageReminders = 'Cài đặt giờ nhắc học và thông báo';
  static const logout = 'Đăng xuất';

  /// Label showing the membership expiry date.
  static String membershipExpires(String date) => 'Hết hạn: $date';

  // Quiz
  static const quiz = 'Bài kiểm tra';
  static const quizzes = 'Bài kiểm tra';
  static const invalidAttempt =
      'Không thể nhận mã lượt làm bài hợp lệ từ máy chủ.';
  static const quizzesLoadError = 'Không thể tải bài kiểm tra.';
  static const quizHistoryLoadError = 'Không thể tải lịch sử làm bài kiểm tra.';
  static const quizLoadError = 'Không thể tải bài kiểm tra này.';
  static const quizStartError = 'Không thể bắt đầu bài kiểm tra này.';
  static const quizSubmitError =
      'Không thể nộp bài. Câu trả lời của bạn vẫn được giữ lại.';
  static const quizDetail = 'Chi tiết bài kiểm tra';
  static const reviewBeforeSubmit =
      'Bạn có thể xem lại các câu trả lời trước khi nộp bài.';
  static const quizNoQuestions = 'Bài kiểm tra này chưa có câu hỏi.';
  static const starting = 'Đang bắt đầu…';
  static const startQuiz = 'Bắt đầu làm bài';
  static const resumeQuiz = 'Tiếp tục làm bài';
  static const quizHistory = 'Lịch sử làm bài kiểm tra';
  static const systemQuizzes = 'Bài kiểm tra hệ thống';
  static const attemptHistory = 'Lịch sử làm bài';
  static const quizResult = 'Kết quả bài kiểm tra';
  static const pendingScoreHint =
      'Điểm cuối cùng có thể thay đổi sau khi câu trả lời tự luận được chấm.';
  static const reviewAnswers = 'Xem lại đáp án';
  static const unanswered = 'Chưa trả lời';
  static const backToQuizzes = 'Về danh sách bài kiểm tra';
  static const confirmSubmit = 'Nộp bài kiểm tra?';
  static const keepReviewing = 'Tiếp tục xem lại';
  static const confirmLeave = 'Rời bài kiểm tra?';
  static const leaveQuizHint =
      'Bài làm của bạn sẽ chưa hoàn thành. Bạn có thể tiếp tục từ trang chi tiết khi bài kiểm tra vẫn còn mở.';
  static const stay = 'Ở lại';
  static const leave = 'Rời đi';
  static const noQuestions = 'Chưa có câu hỏi.';
  static const yourAnswer = 'Câu trả lời của bạn';
  static const noOptions = 'Câu hỏi này chưa có lựa chọn trả lời.';
  static const previous = 'Câu trước';
  static const submitting = 'Đang nộp bài…';
  static const submitQuiz = 'Nộp bài kiểm tra';
  static const next = 'Tiếp theo';
  static const audioUnavailable = 'Thiết bị này không hỗ trợ phát âm thanh.';
  static const audioPlaybackError = 'Không thể phát âm thanh.';
  static const imageUnavailable = 'Không thể tải hình ảnh.';
  static const close = 'Đóng';
  static const loadingAudio = 'Đang tải âm thanh…';
  static const pauseAudio = 'Tạm dừng âm thanh';
  static const playAudio = 'Phát âm thanh';
  static const attachmentUnavailable = 'Không có đường dẫn tệp đính kèm.';
  static const noQuizzes = 'Chưa có bài kiểm tra.';
  static const listeningQuiz = 'Bài kiểm tra nghe';
  static const practiceQuiz = 'Bài kiểm tra luyện tập';
  static const noAttempts = 'Chưa có lượt làm bài kiểm tra.';
  static const refreshQuizzes = 'Tải lại bài kiểm tra';

  /// Count label for quiz questions.
  static String questionCount(int count) => '$count câu hỏi';

  /// Formats a quiz score as a percentage string.
  static String percentage(num score, {int decimals = 1}) =>
      '${score.toStringAsFixed(decimals)}%';

  /// Label showing how many quiz answers are correct.
  static String correctCount(int count, int total) => 'Đúng $count/$total câu';

  /// Label showing wrong answers and answers pending grading.
  static String pendingCount(int wrong, int pending) =>
      '$wrong câu sai · $pending câu chờ chấm';

  /// Review text comparing the student's answer with the correction.
  static String answerReview(String answer, String correction) =>
      'Câu trả lời của bạn: $answer${correction.isEmpty ? '' : '\nĐáp án đúng: $correction'}';

  /// Confirmation text showing how many questions were answered.
  static String submitSummary(int answered, int total) =>
      'Đã trả lời $answered/$total câu. Câu chưa trả lời sẽ được tính là sai.';

  /// Progress label for the current quiz question.
  static String questionProgress(int current, int total) =>
      'Câu $current/$total';

  /// Label showing the best quiz score.
  static String bestScore(num score) =>
      'Cao nhất: ${score.toStringAsFixed(0)}%';

  /// Title for a quiz identified by its id.
  static String quizNumber(int id) => 'Bài kiểm tra #$id';

  /// Localized label for a quiz attempt status.
  static String attemptStatus(String status) => switch (status.toUpperCase()) {
    'IN_PROGRESS' || 'STARTED' => 'Đang làm bài',
    'COMPLETED' || 'GRADED' => 'Đã chấm điểm',
    'SUBMITTED' => 'Đã nộp bài',
    'PENDING_REVIEW' => 'Chờ chấm',
    'ABANDONED' => 'Chưa hoàn thành',
    _ => 'Chưa rõ trạng thái',
  };

  /// Summary line combining an attempt status and its date.
  static String attemptSummary(String status, String date) =>
      '${attemptStatus(status)}\n$date';
  static const answerSeparator = ' / ';

  // Streak
  static const loadingStreak = 'Đang tải chuỗi ngày học…';
  static const streakUnavailable = 'Không thể tải chuỗi ngày học';
  static const studyToday = 'Học hôm nay để duy trì chuỗi ngày học nhé!';
  static const studiedToday = 'Bạn đã học hôm nay rồi. Giỏi lắm!';

  /// Label for the number of consecutive study days.
  static String streakDays(int days) => '$days ngày liên tiếp';

  // Video
  static const playbackSpeed = 'Tốc độ phát';
  static const subtitles = 'Phụ đề';
  static const videoQuality = 'Chất lượng video';
  static const invalidVideoResponse =
      'Không thể đọc dữ liệu bài học. Vui lòng thử lại.';
  static const videoMembershipRequired =
      'Bạn cần có gói hội viên để xem bài học này.';
  static const noVideoSource = 'Bài học này chưa có video để phát.';
  static const invalidVideoAddress = 'Đường dẫn video không hợp lệ';
  static const videoPlaybackError =
      'Không thể phát video. Đường dẫn có thể không hợp lệ hoặc không truy cập được.';
  static const lessonCompleted = 'Đã đánh dấu bài học hoàn thành';
  static const progressSaveError = 'Không thể lưu tiến độ. Vui lòng thử lại.';
  static const lesson = 'Bài học';
  static const freePreview = 'Xem trước miễn phí';
  static const completed = 'Đã hoàn thành';
  static const markCompleted = 'Đánh dấu hoàn thành';

  // Vocabulary
  static const vocabularyLoadError = 'Không thể tải từ vựng đã lưu.';
  static const vocabularyUpdateError = 'Không thể cập nhật từ vựng đã lưu.';
  static const vocabulary = 'Từ vựng đã lưu';
  static const searchWords = 'Tìm từ vựng';
  static const noMatchingWords =
      'Không tìm thấy từ phù hợp. Bạn có thể lưu thẻ khi học.';
  static const deleteWordError = 'Không thể xóa từ vựng.';
  static const undo = 'Hoàn tác';
  static const restoreWordError = 'Không thể khôi phục từ vựng.';

  /// Confirmation text shown after a word is removed.
  static String wordRemoved(String word) => 'Đã xóa $word';

  /// Detail text combining a word's meaning and example.
  static String wordDetails(String meaning, String example) =>
      '$meaning${example.isEmpty ? '' : '\n$example'}';

  // Home - AI practice shortcut
  static const aiPracticeTitle = 'Luyện thi cùng AI';
  static const aiPracticeSubtitle = 'Nói, nghe, viết và nhận chấm điểm ngay';
}
