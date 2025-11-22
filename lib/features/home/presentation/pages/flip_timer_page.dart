import 'dart:async';
import 'dart:convert'; // For JSON decoding
import 'dart:ui'; // For FontFeature
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http; // Import HTTP
import 'package:sensors_plus/sensors_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:studymate/features/auth/domain/models/quote.dart';

// --- ENUMS ---
enum SessionState { idle, focusing, warning }

class FlipTimerPage extends StatefulWidget {
  const FlipTimerPage({super.key});

  @override
  State<FlipTimerPage> createState() => _FlipTimerPageState();
}

class _FlipTimerPageState extends State<FlipTimerPage> {
  // --- VARIABLES ---
  Timer? _mainTimer;
  Timer? _graceTimer;
  int _focusSeconds = 0;
  int _graceSeconds = 10;
  SessionState _currentState = SessionState.idle;
  StreamSubscription? _accelerometerSubscription;

  // --- UPDATED: FUTURE NOW USES THE MODEL ---
  Future<Quote>? _quoteFuture;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      WakelockPlus.enable();
      _startSensorListener();
    }
  }

  @override
  void dispose() {
    _mainTimer?.cancel();
    _graceTimer?.cancel();
    _accelerometerSubscription?.cancel();
    if (!kIsWeb) {
      WakelockPlus.disable();
    }
    super.dispose();
  }

  // --- SENSOR LOGIC ---
  void _startSensorListener() {
    // On web, we don't use sensors.
    if (kIsWeb) return;

    _accelerometerSubscription = accelerometerEvents.listen((event) {
      // Threshold: -7.5 ensures phone is mostly flat face down
      bool isFaceDown = event.z < -7.5;

      if (isFaceDown) {
        _handleFaceDown();
      } else {
        _handleFaceUp();
      }
    });
  }

  void _handleFaceDown() {
    if (_currentState == SessionState.focusing) return;

    if (_currentState == SessionState.warning) {
      _graceTimer?.cancel();
      setState(() {
        _graceSeconds = 10;
        _currentState = SessionState.focusing;
      });
      _startMainTimer();
    } else if (_currentState == SessionState.idle) {
      setState(() {
        _currentState = SessionState.focusing;
      });
      _startMainTimer();
    }
  }

  void _handleFaceUp() {
    if (_currentState != SessionState.focusing) return;

    _mainTimer?.cancel();
    setState(() {
      _currentState = SessionState.warning;
      _graceSeconds = 10;
    });
    _startGraceTimer();
  }

  // --- WEB MANUAL CONTROLS ---
  void _toggleWebTimer() {
    if (_currentState == SessionState.idle) {
      // Start focusing
      setState(() {
        _currentState = SessionState.focusing;
      });
      _startMainTimer();
    } else if (_currentState == SessionState.focusing) {
      // Pause/Stop (simulate face up)
      _mainTimer?.cancel();
      setState(() {
        _currentState = SessionState.warning;
        _graceSeconds = 10;
      });
      _startGraceTimer();
    } else if (_currentState == SessionState.warning) {
      // Resume (simulate face down)
      _graceTimer?.cancel();
      setState(() {
        _graceSeconds = 10;
        _currentState = SessionState.focusing;
      });
      _startMainTimer();
    }
  }

  // --- TIMER LOGIC ---
  void _startMainTimer() {
    _mainTimer?.cancel();
    _mainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _focusSeconds++);
    });
  }

  void _startGraceTimer() {
    _graceTimer?.cancel();
    _graceTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _graceSeconds--);
        if (_graceSeconds <= 0) _sessionFailed();
      }
    });
  }

  // --- API LOGIC WITH MODEL ---
  Future<Quote> _getRandomQuote() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.quotable.io/random'),
      );

      if (response.statusCode == 200) {
        // 1. Decode JSON
        final Map<String, dynamic> data = jsonDecode(response.body);
        // 2. Return the Model using factory
        return Quote.fromJson(data);
      } else {
        return Quote.fallback();
      }
    } catch (e) {
      debugPrint('Error fetching quote: $e');
      return Quote.fallback();
    }
  }

  // --- END SESSION LOGIC ---
  void _sessionFailed() {
    _graceTimer?.cancel();
    _mainTimer?.cancel();

    // Trigger the API call
    _quoteFuture = _getRandomQuote();

    _showSummaryDialog();

    setState(() {
      _currentState = SessionState.idle;
    });
  }

  void _manualReset() {
    _mainTimer?.cancel();
    _graceTimer?.cancel();
    setState(() {
      _focusSeconds = 0;
      _graceSeconds = 10;
      _currentState = SessionState.idle;
    });
  }

  Future<void> _showSummaryDialog() async {
    int minutes = _focusSeconds ~/ 60;
    int seconds = _focusSeconds % 60;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 50,
              color: Colors.green,
            ),
            const SizedBox(height: 10),
            Text(
              "Session Complete",
              style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "$minutes min $seconds sec",
              style: GoogleFonts.ubuntu(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),

            // --- UPDATED FUTURE BUILDER FOR QUOTE MODEL ---
            FutureBuilder<Quote>(
              future: _quoteFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 60,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const Text("Great job focusing!");
                }

                // Access data directly from the Model
                final quote = snapshot.data?.content ?? "Well done!";
                final author = snapshot.data?.author ?? "Unknown";

                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: 1.0,
                  child: Column(
                    children: [
                      Text(
                        '"$quote"',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.ubuntu(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[800],
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "- $author",
                          style: GoogleFonts.ubuntu(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _manualReset();
            },
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // --- UI BUILD ---
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = _currentState == SessionState.focusing;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      body: Stack(
        children: [
          // LAYER 1: MAIN CONTENT
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
              child: Column(
                children: [
                  const Spacer(flex: 1),
                  // Status Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.grey[100],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isDark
                              ? Icons.nightlight_round
                              : Icons.wb_sunny_rounded,
                          color: isDark ? Colors.amber : Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isDark ? "Deep Focus Mode" : "Ready to Focus",
                          style: GoogleFonts.ubuntu(
                            color: isDark ? Colors.white : Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Timer Circle
                  Container(
                    width: size.width * 0.8,
                    height: size.width * 0.8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.blue[50],
                      border: Border.all(
                        color: isDark
                            ? Colors.blueAccent.withOpacity(0.5)
                            : Colors.blue[100]!,
                        width: 2,
                      ),
                      boxShadow: isDark
                          ? [
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.2),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isDark ? Icons.lock_clock : Icons.touch_app,
                          size: size.width * 0.12,
                          color: isDark ? Colors.white54 : Colors.blue[300],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _formatTime(_focusSeconds),
                          style: GoogleFonts.ubuntu(
                            fontSize: size.width * 0.18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.blue[900],
                            fontFeatures: [const FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Helper Text
                  if (kIsWeb)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ElevatedButton.icon(
                        onPressed: _toggleWebTimer,
                        icon: Icon(
                          _currentState == SessionState.focusing
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                        label: Text(
                          _currentState == SessionState.focusing
                              ? "Pause Focus"
                              : "Start Focus",
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      ),
                    )
                  else
                    Text(
                      isDark
                          ? "Keep phone face down"
                          : "Flip phone face down to start",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.ubuntu(
                        fontSize: 16,
                        color: isDark ? Colors.white54 : Colors.grey[500],
                      ),
                    ),

                  const Spacer(flex: 2),

                  // Reset Button
                  if (_currentState == SessionState.idle && _focusSeconds > 0)
                    TextButton.icon(
                      onPressed: _manualReset,
                      icon: const Icon(Icons.refresh),
                      label: const Text("Reset Counter"),
                      style: TextButton.styleFrom(foregroundColor: Colors.grey),
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // LAYER 2: WARNING OVERLAY
          if (_currentState == SessionState.warning)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              color: const Color(0xFFD32F2F), // Material Red 700
              width: size.width,
              height: size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.warning_rounded,
                    color: Colors.white,
                    size: 80,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Don't give up!",
                    style: GoogleFonts.ubuntu(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    kIsWeb
                        ? "Resume focus to continue"
                        : "Put the phone back down",
                    style: GoogleFonts.ubuntu(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 50),
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Text(
                      "$_graceSeconds",
                      style: GoogleFonts.ubuntu(
                        color: Colors.white,
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (kIsWeb)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: ElevatedButton(
                        onPressed: _toggleWebTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                        ),
                        child: const Text(
                          "Resume Focus",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
