/// Vietnamese UI strings of the membership feature.
class MembershipStrings {
  MembershipStrings._();

  static const title = 'Hội viên';
  static const currentMembership = 'Gói hiện tại';
  static const noMembership = 'Chưa có gói';
  static String activeUntil(String date) => 'Còn hiệu lực đến $date';
  static const choosePlan = 'Chọn gói hội viên';
  static const noPlans = 'Hiện chưa có gói hội viên nào.';
  static String duration(int days) => '$days ngày';
  static String perDay(String price) => '≈ $price/ngày';
  static const bestValue = 'Tiết kiệm nhất';
  static const voucherLabel = 'Mã giảm giá';
  static const voucherHint = 'Nhập mã giảm giá (nếu có)';
  static const apply = 'Áp dụng';
  static const removeVoucher = 'Bỏ mã';
  static const selectPlanFirst = 'Hãy chọn một gói trước khi áp dụng mã.';
  static String discount(String amount) => 'Giảm $amount';
  static String finalPrice(String amount) => 'Thành tiền: $amount';
  static const pay = 'Thanh toán';
  static const loadError =
      'Không tải được thông tin hội viên. Vui lòng thử lại.';
  static const voucherError = 'Mã giảm giá không hợp lệ.';
  static const createError = 'Không tạo được đơn thanh toán. Vui lòng thử lại.';
  static const retry = 'Thử lại';

  // Payment screen
  static const paymentTitle = 'Thanh toán';
  static const amount = 'Số tiền';
  static const scanInstruction = 'Mở app ngân hàng, quét mã để thanh toán';
  static const orderDescription = 'Nội dung chuyển khoản';
  static String countdown(String mmss) => 'Mã hết hạn sau $mmss';
  static const openPaymentPage = 'Mở trang thanh toán';
  static const openLinkError = 'Không mở được trang thanh toán.';
  static const iHavePaid = 'Tôi đã thanh toán';
  static const notPaidYet =
      'Chưa nhận được thanh toán. Vui lòng thử lại sau ít giây.';
  static const waiting = 'Đang chờ thanh toán…';
  static const paidTitle = 'Thanh toán thành công';
  static String newExpiry(String date) =>
      'Hội viên của bạn có hiệu lực đến $date';
  static const paidNoExpiry = 'Hội viên của bạn đã được kích hoạt.';
  static const done = 'Hoàn tất';
  static const canceledTitle = 'Thanh toán đã bị huỷ';
  static const canceledBody =
      'Đơn thanh toán đã bị huỷ. Bạn có thể thử lại bất cứ lúc nào.';
  static const expiredTitle = 'Mã thanh toán đã hết hạn';
  static const expiredBody =
      'Nếu bạn đã chuyển tiền, hãy bấm "Tôi đã thanh toán" hoặc liên hệ hỗ trợ. Nếu chưa, hãy tạo đơn mới.';
  static const tryAgain = 'Thử lại';

  // Banner
  static const upgradeBanner = 'Nâng cấp hội viên để mở khoá toàn bộ bài học';
  static const upgrade = 'Nâng cấp';
}
