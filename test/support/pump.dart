import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart' show FTheme, FToaster;
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/core/location/client_position_controller.dart';
import 'package:woutalma_keur/app/data/local/cache_status.dart';
import 'package:woutalma_keur/app/data/services/backend_warmup.dart';
import 'package:woutalma_keur/app/l10n/generated/app_l10n.dart';
import 'package:woutalma_keur/app/ui/theme.dart';
import 'package:woutalma_keur/main.dart';

import 'fake_location.dart';
import 'fonts.dart';
import 'recording_feedback_service.dart';

Future<RecordingFeedbackService> pumpWk(
  WidgetTester tester,
  Widget child, {
  RecordingFeedbackService? feedback,
  double textScale = 1,
  Size surfaceSize = const Size(360, 800),
  CacheStatus? cacheStatus,
  ClientPositionController? positions,
  BackendWarmup? warmup,
}) async {
  final service = feedback ?? RecordingFeedbackService();
  if (!_fontsLoaded) {
    await tester.runAsync(loadAppFonts);
    _fontsLoaded = true;
  }
  await tester.binding.setSurfaceSize(surfaceSize);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<InteractionFeedbackService>.value(value: service),
        ChangeNotifierProvider<CacheStatus>.value(
          value: cacheStatus ?? CacheStatus(),
        ),
        ChangeNotifierProvider<ClientPositionController>.value(
          value: positions ?? fakePositions(),
        ),
        ChangeNotifierProvider<BackendWarmup>.value(
          value: warmup ?? BackendWarmup.disabled(),
        ),
      ],
      child: MaterialApp(
        theme: buildTheme(Brightness.light),
        localizationsDelegates: wkLocalizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        builder: (context, app) => FTheme(
          data: buildForuiTheme(Brightness.light),
          child: FToaster(child: app!),
        ),
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: Material(child: child),
          ),
        ),
      ),
    ),
  );
  return service;
}

bool _fontsLoaded = false;
