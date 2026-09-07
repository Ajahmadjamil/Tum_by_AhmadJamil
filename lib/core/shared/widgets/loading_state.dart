import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../theme/app_colors.dart';

/// Full-screen "Thinking" state shown while recipes are being generated.
///
/// Progress climbs 0 → 99% over ~[averageDuration], holds at 99 until
/// [isComplete], then finishes 99 → 100 and calls [onFinished].
class LoadingState extends StatefulWidget {
  const LoadingState({
    super.key,
    this.isComplete = false,
    this.onFinished,
    this.averageDuration = const Duration(minutes: 1),
  });

  /// True once the generate API has returned (success or error).
  final bool isComplete;

  /// Called after the 99 → 100 finish animation completes.
  final VoidCallback? onFinished;

  /// Typical time to reach 99%. Defaults to 1 minute.
  final Duration averageDuration;

  @override
  State<LoadingState> createState() => _LoadingStateState();
}

class _LoadingStateState extends State<LoadingState>
    with TickerProviderStateMixin {
  static const _statusLabels = [
    'ANALYZING FLAVORS',
    'BALANCING SPICES',
    'CRAFTING YOUR MENU',
    'PLATING IDEAS',
  ];

  static const double _holdAt = 0.99;

  /// Chef plays for the first half of the progress, the dish for the second.
  static const _chefAsset = 'assets/lottie/Chef.json';
  static const _dishAsset = 'assets/lottie/dish.json';
  static const double _dishStartsAt = 0.5;

  late final AnimationController _steamController;
  late final AnimationController _progressController;
  late final AnimationController _finishController;
  late final Animation<double> _progressCurve;
  late final Timer _statusTimer;

  int _statusIndex = 0;
  bool _finishStarted = false;
  bool _finishNotified = false;
  double _progressAtFinishStart = _holdAt;

  @override
  void initState() {
    super.initState();
    _steamController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // Warm the dish composition so the swap at 50% does not flash.
    AssetLottie(_dishAsset).load().ignore();

    // Ease-out climb so early progress feels snappy and the last stretch
    // crawls toward 99% — closer to a real ~1 minute generate.
    _progressController = AnimationController(
      vsync: this,
      duration: widget.averageDuration,
    );
    _progressCurve = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    );
    _progressController.forward();

    _finishController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    _statusTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      setState(() {
        _statusIndex = (_statusIndex + 1) % _statusLabels.length;
      });
    });

    if (widget.isComplete) {
      _startFinish();
    }
  }

  @override
  void didUpdateWidget(covariant LoadingState oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isComplete && !oldWidget.isComplete) {
      _startFinish();
    }
  }

  double get _climbProgress =>
      (_progressCurve.value * _holdAt).clamp(0.0, _holdAt);

  void _startFinish() {
    if (_finishStarted) return;
    _finishStarted = true;
    _progressAtFinishStart = _climbProgress;
    // Faster finish when the API returns early so we don't linger mid-bar.
    final remaining = 1.0 - _progressAtFinishStart;
    _finishController.duration = Duration(
      milliseconds: (280 + remaining * 700).round().clamp(280, 900),
    );

    _finishController.forward(from: 0).whenComplete(() async {
      if (!mounted || _finishNotified) return;
      await Future<void>.delayed(const Duration(milliseconds: 280));
      if (!mounted || _finishNotified) return;
      _finishNotified = true;
      widget.onFinished?.call();
    });
  }

  double get _displayProgress {
    if (!_finishStarted) return _climbProgress;
    final t = Curves.easeOutCubic.transform(_finishController.value);
    return (_progressAtFinishStart + (1.0 - _progressAtFinishStart) * t)
        .clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _statusTimer.cancel();
    _steamController.dispose();
    _progressController.dispose();
    _finishController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF7F5F0);
    const ink = Color(0xFF2C241B);
    const muted = Color(0xFF8A8178);
    const steam = Color(0xFFB8A99A);

    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const Spacer(flex: 2),
              AnimatedBuilder(
                animation: _steamController,
                builder: (context, child) {
                  return Opacity(
                    opacity: 0.55 + (_steamController.value * 0.45),
                    child: Transform.translate(
                      offset: Offset(0, -4 * _steamController.value),
                      child: child,
                    ),
                  );
                },
                child: const _SteamRow(color: steam),
              ),
              const SizedBox(height: 20),
              AnimatedBuilder(
                animation: Listenable.merge([
                  _progressController,
                  _finishController,
                ]),
                builder: (context, _) {
                  final showDish = _displayProgress >= _dishStartsAt;
                  return SizedBox(
                    height: 350,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 450),
                      child: ClipRRect(
                        key: ValueKey(showDish ? 'dish' : 'chef'),
                        borderRadius: BorderRadius.circular(20),
                        child: Lottie.asset(
                          showDish ? _dishAsset : _chefAsset,
                          fit: BoxFit.contain,
                          repeat: true,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              Text(
                'Finding the perfect recipe from your ingredients...',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                  color: ink,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Our chef is currently curating a masterpiece tailored just for you.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                  color: muted,
                ),
              ),
              const Spacer(flex: 3),
              AnimatedBuilder(
                animation: Listenable.merge([
                  _progressController,
                  _finishController,
                ]),
                builder: (context, _) {
                  final progress = _displayProgress;
                  final percent = (progress * 100).floor().clamp(0, 100);

                  return Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4,
                          backgroundColor: const Color(0xFFE6E1DA),
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                percent >= 100
                                    ? 'READY TO SERVE'
                                    : _statusLabels[_statusIndex],
                                key: ValueKey(
                                  percent >= 100 ? 'ready' : _statusIndex,
                                ),
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w600,
                                  color: muted,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            '$percent %',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w600,
                              color: muted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _SteamRow extends StatelessWidget {
  const _SteamRow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SteamPuff(color: color.withValues(alpha: 0.95), width: 28),
        const SizedBox(width: 10),
        _SteamPuff(color: color.withValues(alpha: 0.7), width: 34),
        const SizedBox(width: 10),
        _SteamPuff(color: color.withValues(alpha: 0.45), width: 28),
      ],
    );
  }
}

class _SteamPuff extends StatelessWidget {
  const _SteamPuff({required this.color, required this.width});

  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, 14),
      painter: _SteamPainter(color: color),
    );
  }
}

class _SteamPainter extends CustomPainter {
  _SteamPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.55);
    path.cubicTo(
      size.width * 0.2,
      size.height * 0.05,
      size.width * 0.35,
      size.height * 1.05,
      size.width * 0.55,
      size.height * 0.45,
    );
    path.cubicTo(
      size.width * 0.7,
      size.height * 0.05,
      size.width * 0.85,
      size.height * 0.95,
      size.width,
      size.height * 0.4,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SteamPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

