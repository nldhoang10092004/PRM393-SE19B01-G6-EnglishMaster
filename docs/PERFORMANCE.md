# Kết quả tối ưu hiệu năng (EnglishMaster)

Số liệu đo trên **Android emulator** (emulator-5554, x86_64, 1080x2400), gọi API thật
`https://em-api.ondevora.shop`, tài khoản `student1`. Emulator chạy trên CPU máy dev nên
**số tuyệt đối không đại diện cho máy thật**; chỉ so sánh trước/sau cùng phương pháp.
Phương sai giữa các lần chạy khá lớn (xem mục "Lưu ý").

## 1. Phương pháp

| Chỉ số | Cách đo |
| --- | --- |
| Kích thước | `flutter build apk/appbundle --release`, đo byte file đầu ra |
| Cold start | `adb shell am start -W` (TotalTime) sau `am force-stop`, 5 lần, APK release **universal** (cùng loại với baseline), đã đăng nhập |
| Bộ nhớ | `dumpsys meminfo` TOTAL PSS sau kịch bản: Home vuốt lên/xuống 3 lần, tab Flashcards, bộ đầu tiên, vuốt 5 lần |
| Frame timing | `integration_test` + `traceAction` + `TimelineSummary`, **profile mode**, 2 lần mỗi bên; kịch bản: cuộn danh sách khóa học (3 lần), mở bộ Travel Vocabulary, cuộn danh sách thẻ có ảnh (4 lần lên/xuống), học 5 thẻ. Chia 3 trace ngắn (home / cards / study) vì buffer timeline của VM bị tràn khi trace dài; số liệu gộp từ 3 pha (~435 frame/lần) |
| API payload | `GET /api/user/quiz/10`: Cloudflare đã nén Brotli, Dart `HttpClient` tự gửi `Accept-Encoding: gzip`; không cần đổi API |

`dumpsys gfxinfo` không dùng được (Flutter vẽ trên surface riêng, báo 0 frame).

## 2. Bảng trước / sau

| Chỉ số | Trước | Sau | Nhận xét |
| --- | --- | --- | --- |
| APK universal | 63,466,962 B (60.5 MB) | 59,379,787 B (56.6 MB) | -6.4% (có obfuscate) |
| APK arm64-v8a (split) | - | 21,326,313 B (20.3 MB) | -66% so với universal cũ |
| APK armeabi-v7a (split) | - | 18,816,949 B (17.9 MB) | |
| APK x86_64 (split) | - | 22,810,085 B (21.8 MB) | |
| App Bundle (.aab) | - | 58,316,256 B (55.6 MB) | Play Store tải về theo ABI, ~20 MB/thiết bị |
| Cold start TB (5 lần) | 1990 ms (2058, 1882, 2000, 2139, 1871) | 1384 ms (1243, 1140, 1340, 1215, 1982) | -30%; bỏ lần 1982 ms (outlier) còn ~1235 ms |
| Memory PSS sau kịch bản | 81.8 / 81.1 MB | 92.1 / 88.0 / 87.8 MB | **Tệ hơn ~ +8%** |
| Frame build TB | 2.48 / 2.67 ms | 3.16 / 3.26 ms | **Tệ hơn ~ +0.6 ms** |
| Frame build p90 / p99 | 6.3 / 11.1 và 6.4 / 13.8 ms | 7.0 / 13.8 và 8.0 / 12.8 ms | hơi tệ hơn |
| Frame raster TB | 4.60 / 5.42 ms | 5.45 / 4.65 ms | không đổi (trong sai số) |
| Frame raster p90 / p99 | 6.4 / 17.1 và 14.6 / 18.3 ms | 7.5 / 18.1 và 5.9 / 11.2 ms | cải thiện nhẹ (lần 2 tốt rõ), phương sai cao |
| Frame vượt ngân sách (build / raster) | 0 / 15 và 1 / 28 | 1 / 15 và 2 / 1 | raster giảm trung bình 21.5 -> 8 |
| API payload (quiz/10) | 5,265 B -> 1,657 B (Brotli, -69%) | không đổi | server đã nén sẵn |

Mỗi ô "a và b" là hai lần chạy. Số liệu frame gốc (TimelineSummary) nằm trong [`docs/perf/`](perf/):
`baseline_1/2`, `after_1/2` (mỗi lần 3 pha home/cards/study), script gộp `perf/agg.py`.
Phân tích kích thước arm64 tạo lại bằng `flutter build apk --release --target-platform android-arm64 --analyze-size`.

## 3. Các tối ưu đã làm và lý do

1. **Ảnh mạng giải mã đúng kích thước hiển thị** (`AppNetworkImage`, `core/widgets/app_network_image.dart`):
   `memCacheWidth/Height` = kích thước logic x devicePixelRatio, áp dụng cho thumbnail flashcard (56 px),
   ảnh thẻ học (180 px), ảnh trong quiz, avatar. Giảm bộ nhớ bitmap và công raster cho ảnh lớn.
2. **Disk cache bền vững** bằng `cached_network_image`: ảnh không tải lại sau khi mở lại app / cuộn lại; có
   placeholder và error widget như cũ.
3. **`precacheImage` cho thẻ kế tiếp** trong màn học: vuốt sang thẻ mới hiện ảnh ngay.
4. **Giảm rebuild**: `HomeScreen` chỉ `context.select` hai trường streak thay vì watch cả provider.
   Các danh sách dài đã dùng `ListView.builder` / `GridView.builder` / `SliverList` (các `ListView(children)` còn lại
   chỉ chứa 1-2 widget trạng thái rỗng). Item dùng `const` ở mọi nơi có thể.
5. **Lint**: bật `prefer_const_constructors`, `prefer_const_literals_to_create_immutables`,
   `prefer_const_declarations`, `avoid_unnecessary_containers`, `sized_box_for_whitespace`,
   `use_build_context_synchronously`; `dart fix --apply` + sửa tay; `flutter analyze` sạch.
6. **Build**: `--obfuscate --split-debug-info=build/symbols` (giảm kích thước code Dart),
   `--split-per-abi` và App Bundle. R8/minify bật mặc định ở bản release của Flutter
   (có `build/app/outputs/mapping/release/mapping.txt`).
7. **Khởi động**: `main()` chạy song song `initializeDateFormatting` và `getApplicationDocumentsDirectory`
   (`.wait` trên record). `NotificationService` vốn đã khởi tạo lười (lazy), không chạy trước frame đầu.
   Luồng khôi phục token / `AuthGate` không đổi.

## 4. Lưu ý trung thực

- Cold start nhanh hơn rõ (-30%) nhưng một phần do phương sai emulator (mỗi bên 1 outlier) và
  obfuscate/song song hóa init; không tách riêng được đóng góp từng thay đổi.
- Memory và frame build **tệ hơn**: thêm `cached_network_image` (cache manager, sqflite) và `LayoutBuilder`
  trong mỗi ảnh làm tăng PSS ~6-10 MB và thời gian build ~0.6 ms/frame. Đổi lại ảnh được cache đĩa.
  Ảnh API hiện nhỏ nên lợi ích giải mã đúng cỡ khó thấy trên số đo; lợi ích rõ khi ảnh gốc lớn.
- Frame timing chỉ có 2 lần/bên, p99 và số frame vượt ngân sách dao động mạnh; coi là xu hướng, không phải kết luận thống kê.
- Số PSS baseline đo 2 lần, sau tối ưu đo 3 lần.
- Không đo trên máy thật.

## 5. Cách tái hiện

```bash
# Frame timing (profile mode; --no-dds bắt buộc trên emulator)
flutter drive --no-dds --profile --driver=test_driver/perf_driver.dart \
  --target=integration_test/perf_scroll_test.dart -d emulator-5554
# kết quả: build/home|cards|study.timeline_summary.json

# Build
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/symbols
flutter build apk --release --obfuscate --split-debug-info=build/symbols
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
flutter build apk --release --target-platform android-arm64 --analyze-size

# Cold start (lặp 5 lần) và bộ nhớ
adb shell am force-stop com.se19b01g6.english_master
adb shell am start -W -n com.se19b01g6.english_master/.MainActivity
adb shell dumpsys meminfo com.se19b01g6.english_master | grep "TOTAL PSS"
```

Tài liệu kiểm tra: `flutter analyze` (No issues found), `flutter test` (91 test đều qua; test tích hợp nằm riêng ở `integration_test/`).
