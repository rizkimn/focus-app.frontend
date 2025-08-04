import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:provider/provider.dart';
import 'package:first_app/providers/timer_provider.dart';
import 'package:first_app/services/notification_service.dart';

class HomeScreen extends StatefulWidget
{
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin
{
  late AnimationController _animationController;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            timerProvider.isRunning
              ? Colors.pink.shade300
              : Colors.blueGrey.shade50,
            timerProvider.isRunning
              ? Colors.deepOrange.shade500
              : Colors.lightBlue.shade200,
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Scaffold(
        backgroundColor: Color.fromRGBO(0, 0, 0, 0),
        appBar: AppBar(
          actionsPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
          backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
          title: const Row(
            children: <Widget>[
              Icon(BootstrapIcons.activity),
              SizedBox(width: 12),
              Text(
                'FocusApp',
                style: TextStyle(fontSize: 21),
              ),
            ],
          ),
          centerTitle: false,
          actions: <Widget>[
            IconButton(
              icon: const Icon(BootstrapIcons.bell, size: 21),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {},
            ),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () async {
                    if (!timerProvider.isRunning) {
                      _animationController.forward().then((_) {
                        _animationController.reverse();
                      });
                      timerProvider.startTimer();

                      // Show focus started notification
                      await _notificationService.showNotification(
                        title: 'Fokus Dimulai!',
                        body: 'Waktunya bekerja tanpa gangguan 💪',
                      );

                      // _showFocusDialog(context);
                    } else {
                      timerProvider.stopTimer();

                      // Show focus completed notification
                      await _notificationService.showNotification(
                        title: 'Sesi Fokus Selesai',
                        body: 'Anda fokus selama ${_formatTime(timerProvider.elapsedSeconds)}! 🎉',
                      );

                      timerProvider.resetTimer();
                    }
                  },
                  child: Container(
                    width: 360,
                    height: 360,
                    margin: const EdgeInsets.symmetric(vertical: 60),
                    padding: const EdgeInsets.all(50),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          timerProvider.isRunning
                              ? Colors.red.shade400
                              : Colors.blue.shade300,
                          timerProvider.isRunning
                              ? Colors.deepOrange.shade400
                              : Colors.lightBlue.shade300,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: const [0.3, 0.7],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: timerProvider.isRunning
                              ? Colors.red.shade500
                              : Colors.blue.shade300,
                          offset: const Offset(0, 8),
                          blurRadius: 120,
                          spreadRadius: 16,
                        )
                      ],
                      borderRadius: BorderRadius.circular(300),
                    ),
                    child: ScaleTransition(
                      scale: Tween(begin: 1.0, end: 0.9).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: Curves.easeOut,
                        ),
                      ),
                      child: IconButton.outlined(
                        icon: Icon(
                          timerProvider.isRunning
                              ? BootstrapIcons.stop
                              : BootstrapIcons.power,
                          color: Colors.blue.shade50.withAlpha(200),
                        ),
                        iconSize: 90,
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.only(bottom: 6),
                          side: BorderSide(
                              width: 3,
                              color: Colors.blue.shade50.withAlpha(120)),
                        ),
                        tooltip: "Mulai Fokus",
                        onPressed: null,
                      ),
                    ),
                  ),
                ),
              ),
              // const SizedBox(height: 30),
              Center(
                child: Column(
                  children: <Widget>[
                    Text(
                      timerProvider.isRunning
                          ? 'Sedang Fokus...'
                          : 'Siap untuk fokus?',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(255,255,255,0.6),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _formatTime(timerProvider.elapsedSeconds),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(255,255,255,0.6),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Sesi: ${timerProvider.totalSessions}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color.fromRGBO(255,255,255,0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFocusDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.timer, color: Colors.blue),
            SizedBox(width: 10),
            Text('Mode Fokus Aktif'),
          ],
        ),
        content: const Text(
          'Aplikasi akan memantau waktu fokus Anda.\n\n'
          'Tips: Matikan notifikasi dan jauhkan ponsel dari jangkauan!',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Provider.of<TimerProvider>(context, listen: false).stopTimer();

              // Show session canceled notification
              await _notificationService.showNotification(
                title: 'Sesi Dibatalkan',
                body: 'Fokus Anda terhenti sebelum waktunya 😢',
              );

              Navigator.pop(context);
            },
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }
}
