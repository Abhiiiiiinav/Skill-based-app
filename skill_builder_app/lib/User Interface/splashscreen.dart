import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:skill_builder_app/User%20Interface/colorpallate.dart';

class QuoteModel {
  final String text;
  final String author;

  QuoteModel({required this.text, required this.author});

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      text: json['content'] ?? json['text'] ?? 'Stay motivated!',
      author: json['author'] ?? json['author_name'] ?? 'Unknown',
    );
  }
}

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;

  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  QuoteModel? _currentQuote;
  bool _isLoading = true;
  bool _hasError = false;

  final List<QuoteModel> _fallbackQuotes = [
    QuoteModel(
      text: "The only way to do great work is to love what you do.",
      author: "Steve Jobs",
    ),
    QuoteModel(
      text:
          "Success is not final, failure is not fatal: it is the courage to continue that counts.",
      author: "Winston Churchill",
    ),
    QuoteModel(
      text:
          "The future belongs to those who believe in the beauty of their dreams.",
      author: "Eleanor Roosevelt",
    ),
    QuoteModel(
      text:
          "It is during our darkest moments that we must focus to see the light.",
      author: "Aristotle",
    ),
    QuoteModel(
      text: "Life is what happens to you while you're busy making other plans.",
      author: "John Lennon",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _fetchQuoteAndNavigate();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  Future<void> _fetchQuoteAndNavigate() async {
    try {
      QuoteModel? quote = await _fetchFromAPI();

      if (quote != null) {
        setState(() {
          _currentQuote = quote;
          _isLoading = false;
        });
      } else {
        _useFallbackQuote();
      }
    } catch (e) {
      _useFallbackQuote();
    }

    await Future.delayed(const Duration(milliseconds: 3500));

    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => widget.nextScreen));
    }
  }

  Future<QuoteModel?> _fetchFromAPI() async {
    final List<String> apiUrls = [
      'https://api.quotable.io/random?minLength=50&maxLength=150',
      'https://zenquotes.io/api/random',
      'https://api.adviceslip.com/advice',
    ];

    for (String url in apiUrls) {
      try {
        final response = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (url.contains('quotable.io')) {
            return QuoteModel.fromJson(data);
          } else if (url.contains('zenquotes.io')) {
            final quote = data[0];
            return QuoteModel(
              text: quote['q'] ?? 'Stay motivated!',
              author: quote['a'] ?? 'Unknown',
            );
          } else if (url.contains('adviceslip.com')) {
            return QuoteModel(
              text: data['slip']['advice'] ?? 'Stay motivated!',
              author: 'Advice Slip',
            );
          }
        }
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  void _useFallbackQuote() {
    final random = Random();
    setState(() {
      _currentQuote = _fallbackQuotes[random.nextInt(_fallbackQuotes.length)];
      _isLoading = false;
      _hasError = true;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.deepTeal,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, __) {
                  final opacity = _fadeAnimation.value.clamp(0.0, 1.0);
                  return Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: _pulseAnimation.value,
                      child: const Icon(
                        Icons.psychology_alt,
                        size: 80,
                        color: ColorPalette.aquaMint,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          Text(
                            _currentQuote?.text ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "- ${_currentQuote?.author ?? ''}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
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
}
