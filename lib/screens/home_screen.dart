import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:provider/provider.dart';
import 'package:first_app/providers/timer_provider.dart';
import 'package:first_app/providers/auth_provider.dart';
import 'package:first_app/services/notification_service.dart';
import 'package:first_app/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
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
    return Stack(
      children: [
        // Background Gradient Container, listen to isRunning only
        Selector<TimerProvider, bool>(
          selector: (context, provider) => provider.isRunning,
          builder: (context, isRunning, child) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isRunning
                      ? [Colors.pink.shade300, Colors.deepOrange.shade500]
                      : [Colors.blueGrey.shade50, Colors.lightBlue.shade200],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
            );
          },
        ),

        Scaffold(
          backgroundColor: Colors.transparent,
          body: FutureBuilder(
            future: AuthService.getUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError || snapshot.data == null || !snapshot.hasData) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacementNamed(context, '/login');
                });
                return SizedBox.shrink();
              }

              final userInfo = snapshot.data!;
              final username = userInfo['username'] ?? 'Unknown';
              final email = userInfo['email'] ?? 'unknown@example.com';

              return SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // User Info Box
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      child: _buildUserInfoBox(username, email),
                    ),

                    // Timer Button with Animation
                    Center(
                      child: Consumer<TimerProvider>(
                        builder: (context, timerProvider, child) {
                          return GestureDetector(
                            onTap: () => _onTimerButtonPressed(timerProvider),
                            child: _buildTimerButton(timerProvider.isRunning),
                          );
                        },
                      ),
                    ),

                    // Timer Info (elapsed time & session)
                    Center(
                      child: Column(
                        children: <Widget>[
                          Selector<TimerProvider, bool>(
                            selector: (context, provider) => provider.isRunning,
                            builder: (context, isRunning, child) {
                              return Text(
                                isRunning ? 'Sedang Fokus...' : 'Siap untuk fokus?',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Color.fromRGBO(255, 255, 255, 0.6),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          Selector<TimerProvider, int>(
                            selector: (context, provider) => provider.elapsedSeconds,
                            builder: (context, elapsedSeconds, child) {
                              return Text(
                                _formatTime(elapsedSeconds),
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(255, 255, 255, 0.6),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          Selector<TimerProvider, int>(
                            selector: (context, provider) => provider.totalSessions,
                            builder: (context, sessions, child) {
                              return Text(
                                'Sesi: $sessions',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color.fromRGBO(255, 255, 255, 0.6),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoBox(String username, String email) {
    return Container(
      decoration: BoxDecoration(
        border: BoxBorder.all(width: 2, color: Colors.white.withAlpha(116)),
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [Colors.white60, Colors.white30],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 6),
            blurRadius: 12,
            color: Colors.white.withAlpha(86),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Text(
              'RM',
              style: TextStyle(color: Colors.red),
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: TextStyle(
                  color: Colors.blueGrey.shade900.withAlpha(116),
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              Text(
                email,
                style: TextStyle(
                  color: Colors.blueGrey.shade900.withAlpha(116),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Spacer(),
          IconButton(
            icon: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 6),
                        blurRadius: 12,
                        color: Colors.black.withAlpha(16),
                      ),
                    ],
                  ),
                  child: Icon(BootstrapIcons.box_arrow_right),
                )
              ],
            ),
            iconSize: 21,
            color: Colors.blueGrey.shade300,
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimerButton(bool isRunning) {
    return Container(
      width: 360,
      height: 360,
      margin: const EdgeInsets.symmetric(vertical: 60),
      padding: const EdgeInsets.all(50),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isRunning
              ? [Colors.red.shade400, Colors.deepOrange.shade400]
              : [Colors.blue.shade300, Colors.lightBlue.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.3, 0.7],
        ),
        boxShadow: [
          BoxShadow(
            color: isRunning ? Colors.red.shade500 : Colors.blue.shade300,
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
            isRunning ? BootstrapIcons.stop : BootstrapIcons.power,
            color: Colors.blue.shade50.withAlpha(200),
          ),
          iconSize: 90,
          style: IconButton.styleFrom(
            padding: const EdgeInsets.only(bottom: 6),
            side: BorderSide(
              width: 3,
              color: Colors.blue.shade50.withAlpha(120),
            ),
          ),
          tooltip: "Mulai Fokus",
          onPressed: null,
        ),
      ),
    );
  }

  void _onTimerButtonPressed(TimerProvider timerProvider) async {
    if (!timerProvider.isRunning) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      timerProvider.startTimer();
      await _notificationService.showNotification(
        title: 'Fokus Dimulai!',
        body: 'Waktunya bekerja tanpa gangguan 💪',
      );
    } else {
      timerProvider.stopTimer();
      await _notificationService.showNotification(
        title: 'Sesi Fokus Selesai',
        body: 'Anda fokus selama ${_formatTime(timerProvider.elapsedSeconds)}! 🎉',
      );
      timerProvider.resetTimer();
    }
  }
}
