import 'package:flutter/material.dart';

/// Shimmer loading effect for list items
class ShimmerLoading extends StatefulWidget {
  final int itemCount;

  const ShimmerLoading({super.key, this.itemCount = 10});

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Same responsive logic as main grid
        int crossAxisCount = 2;
        double childAspectRatio = 0.80;
        
        if (constraints.maxWidth > 900) {
          crossAxisCount = 4;
          childAspectRatio = 0.75;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 3;
          childAspectRatio = 0.78;
        }
        
        return GridView.builder(
          itemCount: widget.itemCount,
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      colors: const [
                        Color(0xFFEBEBF4),
                        Color(0xFFF4F4F4),
                        Color(0xFFEBEBF4),
                      ],
                      stops: [
                        _controller.value - 0.3,
                        _controller.value,
                        _controller.value + 0.3,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
