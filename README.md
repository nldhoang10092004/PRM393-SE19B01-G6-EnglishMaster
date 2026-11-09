# EnglishMaster (PRM393 – SE19B01 – Group 6)

Ứng dụng di động Flutter giúp học viên học tiếng Anh: khóa học có video bài giảng, thẻ ghi nhớ (flashcard)
có ảnh, bài kiểm tra Listening/Reading, luyện thi Nói – Nghe – Đọc – Viết được AI chấm điểm, chuỗi ngày học,
nhắc học hằng ngày và mua gói hội viên qua mã QR (PayOS).

Backend REST API được tái sử dụng từ project OJT trước đây của nhóm (EasyEnglish API), đã được chuyển
sang PostgreSQL và triển khai riêng; mã nguồn API **không** nằm trong repository này.

## Tính năng

| Nhóm | Chức năng |
|---|---|
| Tài khoản | Đăng nhập, đăng ký bằng OTP email, quên mật khẩu, tự làm mới phiên (refresh token), đăng xuất |
| Trang chủ | Lời chào theo buổi, thẻ chuỗi ngày học, lối tắt luyện thi AI, danh sách khóa học |
| Khóa học | Chi tiết khóa học, chương – bài học, đánh giá, bài kiểm tra của khóa |
| Video | Phát video, lưu và tiếp tục tiến độ xem, đánh dấu hoàn thành |
| Thẻ ghi nhớ | Bộ thẻ có ảnh và phiên âm, học lật thẻ, qua lại giữa các thẻ, tiến độ đã thuộc, lịch sử |
| Từ vựng | Lưu từ từ thẻ, tìm kiếm, vuốt để xoá có hoàn tác |
| Bài kiểm tra | Bài hệ thống và bài của khóa; Listening có audio, Reading có đoạn văn và ảnh; chấm điểm, lịch sử |
| Luyện thi AI | Nói (ghi âm → Deepgram → Gemini chấm), Nghe (Gemini soạn đề + Murf đọc), Đọc (Gemini viết bài đọc + trắc nghiệm, server chấm), Viết (Gemini chấm band IELTS), lịch sử chấm bài; nhận xét bằng tiếng Việt |
| Hội viên | Chọn gói, mã giảm giá, thanh toán bằng VietQR (PayOS), tự kiểm tra trạng thái thanh toán |
| Hồ sơ | Xem/sửa thông tin, đổi ảnh đại diện, đổi mật khẩu, trạng thái hội viên, cài đặt nhắc học (local notification) |
| Giao diện | Hệ thiết kế "Khối màu tươi", chế độ sáng/tối; responsive cho điện thoại, điện thoại gập và tablet (NavigationRail từ 600dp) |

## Công nghệ

- **Flutter 3.47 / Dart 3.13**, Material 3, giao diện tiếng Việt (`flutter_localizations`, `intl`).
- **State management:** Provider (`ChangeNotifier`), kiến trúc Screen → Provider → Repository → ApiClient.
- **Mạng:** Dio + cookie jar (refresh token HttpOnly), tự refresh khi gặp 401.
- **Lưu trữ local:** `flutter_secure_storage` (token), `shared_preferences` (cài đặt nhắc học), cookie jar.
- **Media:** `video_player` + `chewie`, `audioplayers`, `record` (ghi âm), `qr_flutter`.
- **Thông báo:** `flutter_local_notifications` + `timezone`.
- **Kiểm thử:** `flutter_test`, `mocktail` (unit + widget test, repository giả).

Backend (triển khai riêng): ASP.NET Core 10, EF Core + PostgreSQL, Docker trên VPS ARM64, HTTPS qua
Cloudflare Tunnel; tích hợp Gemini, Deepgram, Murf, PayOS, Gmail SMTP, Cloudflare R2.

## Chạy ứng dụng

```bash
flutter pub get
flutter run                                   # dùng API đã triển khai: https://em-api.ondevora.shop
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5213   # dùng API chạy trên máy (emulator)
```

Tài khoản demo: `student1` / `Student@123` (có gói hội viên), `student2` / `Student@123`.

> Emulator: để ghi âm Luyện nói, bật **Extended controls → Microphone → "Virtual microphone uses host
> audio input"** (tự tắt mỗi lần khởi động lại emulator).

## Kiểm thử và build

```bash
flutter analyze
flutter test
flutter build apk --release
flutter build apk --release --split-per-abi   # APK nhỏ hơn cho từng kiến trúc CPU
```

## Cấu trúc thư mục

```
lib/
  main.dart, app.dart      khởi tạo service, MultiProvider, MaterialApp, AuthGate
  core/                    config, l10n (AppStrings), layout (responsive), network (ApiClient), router, storage, theme, utils, widgets
  features/<feature>/      data/ (models, repository) + presentation/ (providers, screens, widgets)
test/
  unit/                    model, repository, provider
  widget/                  màn hình với repository giả, bố cục ở 5 kích thước màn
integration_test/          benchmark frame timing (chạy cùng test_driver/perf_driver.dart)
```

## Hiệu năng

Đo trên Android emulator (x86_64, 1080x2400) với API thật, so sánh trước/sau tối ưu cùng phương pháp:

| Chỉ số | Trước | Sau |
|---|---|---|
| APK universal | 60.5 MB | 56.6 MB (-6.4%, có obfuscate) |
| APK arm64-v8a (split) | - | 20.3 MB |
| Cold start (TB 5 lần) | 1990 ms | 1384 ms (-30%) |
| Frame raster vượt ngân sách (TB) | 21.5 | 8 |

Đã làm: ảnh mạng giải mã đúng kích thước hiển thị và cache đĩa (`cached_network_image`), precache ảnh thẻ kế tiếp,
giảm rebuild bằng `context.select`, danh sách dùng builder và `const`, bật lint hiệu năng, build `--obfuscate
--split-per-abi`, khởi tạo song song trong `main()`. Đánh đổi: bộ nhớ tăng khoảng 8% do cache ảnh.

```bash
flutter drive --no-dds --profile --driver=test_driver/perf_driver.dart   --target=integration_test/perf_scroll_test.dart -d emulator-5554
```
