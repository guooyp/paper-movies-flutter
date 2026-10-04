import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

/// Single place for unexpected errors. Swap debugPrint for a crash reporter.
class AppBlocObserver extends BlocObserver {
  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    debugPrint('${bloc.runtimeType} error: $error\n$stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}
