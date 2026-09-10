import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/haptics/app_haptics.dart';

class AutoPageCarousel extends StatefulWidget {
  const AutoPageCarousel({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.height = 188,
    this.interval = const Duration(seconds: 4),
    this.viewportFraction = 0.94,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double height;
  final Duration interval;
  final double viewportFraction;

  @override
  State<AutoPageCarousel> createState() => _AutoPageCarouselState();
}

class _AutoPageCarouselState extends State<AutoPageCarousel> {
  PageController? _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant AutoPageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemCount != widget.itemCount) {
      _sync();
    }
  }

  void _sync() {
    _timer?.cancel();
    _timer = null;
    _controller?.dispose();
    _controller = null;
    if (widget.itemCount < 2) return;
    _controller = PageController(
      viewportFraction: widget.viewportFraction,
      initialPage: widget.itemCount * 100,
    );
    _timer = Timer.periodic(widget.interval, (_) => _advance());
  }

  void _advance() {
    final controller = _controller;
    if (!mounted || controller == null || !controller.hasClients) return;
    final next = (controller.page ?? 0).round() + 1;
    controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 460),
      curve: Curves.easeOutCubic,
    );
  }

  void _onScroll(ScrollNotification notification) {
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      AppHaptics.light();
      _timer?.cancel();
      _timer = null;
    } else if (notification is ScrollEndNotification &&
        widget.itemCount >= 2 &&
        _timer == null) {
      _timer = Timer.periodic(widget.interval, (_) => _advance());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount <= 0) return const SizedBox.shrink();

    if (widget.itemCount == 1) {
      return SizedBox(
        height: widget.height,
        child: widget.itemBuilder(context, 0),
      );
    }

    final loopCount = widget.itemCount * 1000;
    return SizedBox(
      height: widget.height,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          _onScroll(notification);
          return false;
        },
        child: PageView.builder(
          controller: _controller,
          itemCount: loopCount,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: widget.itemBuilder(context, index % widget.itemCount),
            );
          },
        ),
      ),
    );
  }
}
