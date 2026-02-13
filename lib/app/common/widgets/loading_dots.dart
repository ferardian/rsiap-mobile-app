import 'package:flutter/material.dart';
import '../../../../core/values/colors.dart';

class LoadingDots extends StatefulWidget {
  final Color? color;
  final double size;

  const LoadingDots({Key? key, this.color, this.size = 10.0}) : super(key: key);

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final double start = index * 0.2;
              final double end = start + 0.4;

              double scale = 1.0;
              if (_controller.value >= start && _controller.value < end) {
                // Calculate a sine wave curve for the bounce/scale effect
                double val = (_controller.value - start) / 0.4;
                scale = 1.0 + (0.5 * (1 - (2 * val - 1).abs()));
              } else if (_controller.value < start && _controller.value > end) {
                scale = 1.0;
              }

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: (widget.color ?? AppColors.primary).withOpacity(
                      scale > 1.0 ? 1.0 : 0.6,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
