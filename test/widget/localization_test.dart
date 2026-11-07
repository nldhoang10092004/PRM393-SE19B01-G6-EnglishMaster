import 'package:english_master/app.dart';
import 'package:english_master/core/l10n/app_strings.dart';
import 'package:english_master/core/network/api_client.dart';
import 'package:english_master/core/storage/token_storage.dart';
import 'package:english_master/features/auth/data/auth_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' show DateFormat;

void main() {
  setUpAll(() => initializeDateFormatting('vi'));

  testWidgets('app uses Vietnamese framework controls and form validation', (
    tester,
  ) async {
    final storage = InMemoryTokenStorage();
    final api = ApiClient(tokenStorage: storage);
    await tester.pumpWidget(
      EnglishMasterApp(
        apiClient: api,
        authRepository: AuthRepository(api: api, storage: storage),
      ),
    );
    await tester.pumpAndSettle();
    final context = tester.element(find.byKey(const Key('login_submit')));
    expect(Localizations.localeOf(context), const Locale('vi'));
    final material = await GlobalMaterialLocalizations.delegate.load(
      const Locale('vi'),
    );
    final cupertino = await GlobalCupertinoLocalizations.delegate.load(
      const Locale('vi'),
    );
    expect(
      MaterialLocalizations.of(context).cancelButtonLabel,
      material.cancelButtonLabel,
    );
    expect(
      CupertinoLocalizations.of(context).cancelButtonLabel,
      cupertino.cancelButtonLabel,
    );
    expect(WidgetsLocalizations.of(context).textDirection, TextDirection.ltr);
    expect(DateFormat.yMd('vi').format(DateTime(2026, 12, 31)), '31/12/2026');
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pump();
    expect(
      find.text(AppStrings.requiredField(AppStrings.emailOrUsername)),
      findsOneWidget,
    );
    expect(
      find.text(AppStrings.requiredField(AppStrings.password)),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
