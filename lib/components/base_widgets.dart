import 'package:flutter/material.dart';

class scrollBar extends StatelessWidget {
  final ScrollController scrollController;

  const scrollBar({super.key, required this.scrollController});

  void _scrollToTop() {
    scrollController.animateTo(
      0.0,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  void _scrollUp() {
    const double scrollAmount = 300.0; // Adjust this value as needed
    final double currentScroll = scrollController.position.pixels;
    final double targetScroll = currentScroll - scrollAmount;

    scrollController.animateTo(
      targetScroll < 0 ? 0 : targetScroll,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  void _scrollDown() {
    const double scrollAmount = 300.0; // Adjust this value as needed
    final double maxScroll = scrollController.position.maxScrollExtent;
    final double currentScroll = scrollController.position.pixels;
    final double targetScroll = currentScroll + scrollAmount;

    scrollController.animateTo(
      targetScroll > maxScroll ? maxScroll : targetScroll,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _scrollUp,
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(30)),
              child: const Center(
                child: Icon(Icons.arrow_upward, size: 36, color: Colors.white),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: _scrollDown,
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(30)),
              child: const Center(
                child:
                    Icon(Icons.arrow_downward, size: 36, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
