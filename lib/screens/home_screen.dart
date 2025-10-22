
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:random_quote_generator_intern/model/quote.dart';
import '../services/quote_service.dart';
import '../widgets/quote_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<Quote> _quotes = [];
  Quote? _current;
  final Random _rng = Random();

  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    final loaded = await QuoteService.loadQuotes();
    if (!mounted) return;
    setState(() {
      _quotes = loaded;
      if (_quotes.isNotEmpty) {
        _current = _quotes[_rng.nextInt(_quotes.length)];
      }
    });
   
    if (_current != null) {
      _controller.forward();
    }
  }

  
  Future<void> _showNewQuote() async {
    if (_quotes.isEmpty || _current == null) return;

    final old = _current!;
    Quote next = old;

  
    if (_quotes.length > 1) {
      while (next.text == old.text) {
        next = _quotes[_rng.nextInt(_quotes.length)];
      }
    }

    try {
    
      await _controller.reverse();
    } catch (_) {
  
    }

    if (!mounted) return;
    setState(() => _current = next);

    try {
      await _controller.forward();
    } catch (_) {
   
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   
    final mq = MediaQuery.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _current == null
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.format_quote_rounded,
                              color: Colors.white70),
                          const SizedBox(width: 10),
                          Text(
                            'Random Quote',
                            style: GoogleFonts.lora(
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: _showNewQuote,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.autorenew,
                                      color: Colors.white, size: 18),
                                  SizedBox(width: 6),
                                  Text('New', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Center(
                          child: SlideTransition(
                            position: _slideAnim,
                            child: FadeTransition(
                              opacity: _fadeAnim,
                              child: QuoteCard(
                                quote: _current!,
                                onNewQuote: _showNewQuote,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'Made with ❤ — Random Quote Generator',
                        style: GoogleFonts.inter(
                          textStyle: TextStyle(
                            color: Colors.white.withOpacity(0.65),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}