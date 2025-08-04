import 'dart:async';
import 'package:flutter/foundation.dart';

class TimerProvider with ChangeNotifier {
  bool _isRunning = false;
  int _elapsedSeconds = 0;
  int _totalSessions = 0;
  Timer? _timer;

  bool get isRunning => _isRunning;
  int get elapsedSeconds => _elapsedSeconds;
  int get totalSessions => _totalSessions;

  void startTimer() {
    if (_isRunning) return;

    _isRunning = true;
    _elapsedSeconds = 0;
    _totalSessions++;

    // Start the timer directly in the provider
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      notifyListeners();
    });

    notifyListeners();
  }

  void stopTimer() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  void resetTimer() {
    _timer?.cancel();
    _isRunning = false;
    _elapsedSeconds = 0;
    notifyListeners();
  }

  // Clean up the timer when provider is disposed
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
