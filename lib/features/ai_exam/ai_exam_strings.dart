/// Vietnamese interface copy shared only by the AI exam feature.
class AiExamStrings {
  AiExamStrings._();

  static const hub = 'Luyện thi với AI';
  static const intro = 'Chọn kỹ năng để nhận đề và góp ý từ AI.';
  static const speaking = 'Luyện nói';
  static const listening = 'Luyện nghe';
  static const writing = 'Luyện viết';
  static const speakingDescription = 'Nhận đề, ghi âm và cải thiện bài nói.';
  static const listeningDescription = 'Nghe hội thoại và trả lời câu hỏi.';
  static const writingDescription = 'Viết bài luận và nhận góp ý chi tiết.';
  static const history = 'Lịch sử chấm bài';
  static const historyDescription =
      'Xem lại bài đã gửi và nhận xét của giáo viên.';
  static const historyNote =
      'Lịch sử chỉ lưu bài nói và bài viết đã chọn gửi cho giáo viên. Bài nghe không được lưu.';
  static const review = 'Chi tiết chấm bài';
  static const generate = 'Tạo đề mới';
  static const generating = 'Đang tạo đề…';
  static const submit = 'Nộp bài chấm điểm';
  static const submitting = 'AI đang chấm bài…';
  static const retry = 'Thử lại';
  static const prompt = 'Đề bài';
  static const answer = 'Bài làm của bạn';
  static const writingHint = 'Nhập bài viết bằng tiếng Anh…';
  static const minimumWords = 'Bài viết cần ít nhất 150 từ để chấm điểm.';
  static const sendToTeacher = 'Gửi cho giáo viên và lưu vào lịch sử';
  static const teacherNote =
      'Khi bật, bài làm và nhận xét AI sẽ được lưu để giáo viên xem.';
  static const result = 'Kết quả chấm bài';
  static const feedback = 'Nhận xét';
  static const aiReview = 'Nhận xét của AI';
  static const teacherReview = 'Nhận xét của giáo viên';
  static const teacherPending = 'Đang chờ giáo viên nhận xét';
  static const teacherReviewed = 'Giáo viên đã nhận xét';
  static const noFeedback = 'Chưa có nhận xét chi tiết.';
  static const noHistory = 'Bạn chưa có bài chấm nào trong lịch sử.';
  static const noAnswer = 'Chưa trả lời';
  static const overall = 'Điểm tổng';
  static const taskResponse = 'Đáp ứng yêu cầu đề';
  static const coherence = 'Mạch lạc và liên kết';
  static const lexical = 'Vốn từ vựng';
  static const grammar = 'Ngữ pháp';
  static const fluency = 'Độ trôi chảy';
  static const pronunciation = 'Phát âm';
  static const transcript = 'Nội dung nhận diện từ bản ghi âm';
  static const script = 'Nội dung bài nghe';
  static const startRecording = 'Bắt đầu ghi âm';
  static const stopRecording = 'Dừng ghi âm';
  static const recordAgain = 'Ghi âm lại';
  static const recordingHint = 'Trả lời bằng tiếng Anh. Bản ghi tối đa 5 phút.';
  static const microphoneDenied =
      'Bạn cần cấp quyền micro trong cài đặt để ghi âm bài nói.';
  static const recordingError =
      'Không thể ghi âm. Hãy kiểm tra micro và thử lại.';
  static const recordingRequired = 'Hãy ghi âm câu trả lời trước khi nộp bài.';
  static const play = 'Phát âm thanh';
  static const pause = 'Tạm dừng';
  static const seek = 'Vị trí phát';
  static const previousAudio = 'Đoạn trước';
  static const nextAudio = 'Đoạn tiếp';
  static const audioError =
      'Không phát được âm thanh. Hãy kiểm tra kết nối và thử lại.';
  static const answerHint = 'Nhập câu trả lời';
  static const incompleteAnswers =
      'Hãy trả lời tất cả câu hỏi trước khi nộp bài.';
  static const correct = 'Đúng';
  static const incorrect = 'Chưa đúng';
  static const membershipRequired =
      'Bạn cần gói thành viên còn hiệu lực để luyện thi với AI.';
  static const configurationError =
      'Dịch vụ AI chưa sẵn sàng. Vui lòng liên hệ quản trị viên để kiểm tra cấu hình dịch vụ.';
  static const sessionExpired =
      'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
  static const forbidden =
      'Tài khoản của bạn chưa được cấp quyền sử dụng tính năng này.';
  static const networkError =
      'Không thể kết nối máy chủ. Hãy kiểm tra mạng và thử lại.';
  static const timeoutError =
      'AI phản hồi lâu hơn dự kiến. Vui lòng thử lại sau.';
  static const genericError =
      'Chưa thực hiện được yêu cầu. Bài làm của bạn vẫn được giữ, hãy thử lại.';
  static const invalidResponse =
      'Máy chủ trả về dữ liệu chưa đầy đủ. Vui lòng thử lại.';
  static const notFound = 'Không tìm thấy bài chấm này. Hãy tải lại lịch sử.';
  static const transcriptionError =
      'Chưa nhận diện được lời nói. Hãy ghi âm rõ hơn và thử lại.';
  static const overallComment = 'Nhận xét chung';
  static const comment = 'Nhận xét';
  static const issues = 'Điểm cần cải thiện';
  static const suggestions = 'Gợi ý cải thiện';
  static const original = 'Nội dung ban đầu';
  static const correction = 'Cách sửa';
  static const explanation = 'Giải thích';
  static const errors = 'Lỗi cần sửa';
  static const weakPhrases = 'Cụm từ cần cải thiện';

  static String wordCount(int count) => '$count từ';
  static String question(int number) => 'Câu $number';
  static String listeningScore(int score, int total) =>
      'Đúng $score/$total câu';
  static String yourAnswer(String value) => 'Bạn trả lời: $value';
  static String correctAnswer(String value) => 'Đáp án đúng: $value';
  static String audioPart(int index, int total) => 'Đoạn $index/$total';
  static String level(int percent) => 'Mức âm thanh: $percent%';

  /// Uses Vietnamese headings even when AI feedback keys are in English.
  static String feedbackLabel(String key) => switch (key.toLowerCase()) {
    'overall' => overallComment,
    'taskresponse' || 'task' => taskResponse,
    'coherence' => coherence,
    'lexical' || 'lexicalresource' => lexical,
    'grammar' => grammar,
    'fluency' => fluency,
    'pronunciation' => pronunciation,
    'comment' => comment,
    'issues' => issues,
    'suggestions' || 'suggestion' => suggestions,
    'original' => original,
    'correction' => correction,
    'explanation' => explanation,
    'errors' => errors,
    'weakphrases' => weakPhrases,
    _ => feedback,
  };
}
