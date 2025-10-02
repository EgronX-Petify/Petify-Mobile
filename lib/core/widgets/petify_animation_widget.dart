import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../constants/app_colors.dart';

class PetifyAnimationWidget extends StatefulWidget {
  final String animationPath;
  final double? size;
  final double borderRadius;

  const PetifyAnimationWidget({
    super.key,
    required this.animationPath,
    this.size,
    this.borderRadius = 20.0,
  });

  @override
  State<PetifyAnimationWidget> createState() => _PetifyAnimationWidgetState();
}

class _PetifyAnimationWidgetState extends State<PetifyAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Match the logo size (120px default)
    final animationSize = widget.size ?? 120;

    return Container(
      width: animationSize,
      height: animationSize,
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Transform.scale(
          scale: 1.2, // Slightly scale up to crop sides and make it more square
          child: Lottie.asset(
            widget.animationPath,
            controller: _controller,
            width: animationSize,
            height: animationSize,
            fit: BoxFit.cover, // Cover to fill the square container properly
            repeat: true,
            animate: true,
            frameRate: FrameRate.max, // Smooth animation
            options: LottieOptions(
              enableMergePaths: true, // Better performance
            ),
            onLoaded: (composition) {
              // Start animation immediately when loaded with faster duration
              _controller
                ..duration = Duration(
                  milliseconds:
                      (composition.duration.inMilliseconds * 0.8)
                          .round(), // 20% faster
                )
                ..forward()
                ..repeat();
            },
          ),
        ),
      ),
    );
  }
}
