import 'package:flutter/foundation.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/async_view.dart';
import '../../data/course_repository.dart';
import '../../data/models/course_summary.dart';

/// State of the course list shown on the home dashboard.
class CourseListProvider extends ChangeNotifier {
  CourseListProvider(this._repository);

  final CourseRepository _repository;

  ViewStatus _status = ViewStatus.idle;
  List<CourseSummary> _courses = const [];
  String? _error;

  /// Loading status of the course list.
  ViewStatus get status => _status;
  /// Courses loaded for the list screen.
  List<CourseSummary> get courses => _courses;
  /// Last error message, or null.
  String? get error => _error;

  /// Loads the courses. Keeps the old list visible while refreshing
  /// (pull-to-refresh) and only shows the error state when nothing is loaded.
  Future<void> load() async {
    if (_courses.isEmpty) {
      _status = ViewStatus.loading;
      notifyListeners();
    }
    try {
      _courses = await _repository.fetchCourses();
      _error = null;
      _status = ViewStatus.success;
    } on ApiException catch (e) {
      _error = e.message;
      if (_courses.isEmpty) _status = ViewStatus.error;
    } catch (e) {
      _error = AppStrings.unexpectedError;
      if (_courses.isEmpty) _status = ViewStatus.error;
    }
    notifyListeners();
  }
}
