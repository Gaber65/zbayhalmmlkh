import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyBlocObserver extends BlocObserver {
  /// Helper function لضمان ظهور كل الرسائل
  void logMessage(String message) {
    // debugPrint أفضل من print لأنها تتحكم في طول الرسائل على Web/Desktop
    debugPrint(message);
  }

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    logMessage('DEBUG: onCreate -- ${bloc.runtimeType}');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    logMessage('DEBUG: onChange -- ${bloc.runtimeType}, $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    logMessage('DEBUG: onError -- ${bloc.runtimeType}, $error');
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    logMessage('DEBUG: onClose -- ${bloc.runtimeType}');
  }
}