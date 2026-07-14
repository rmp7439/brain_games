import 'package:flutter/material.dart';

class PageIndicator extends StatelessWidget {
  final PageController pageController;
  final int pageCount;

  const PageIndicator({
    super.key,
    required this.pageController,
    this.pageCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: pageController,
      builder: (context, child) {
        final page = pageController.hasClients ? (pageController.page ?? 0.0) : 0.0;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(pageCount, (index) {
            return Padding(
              padding: EdgeInsets.only(right: index < pageCount - 1 ? 8.0 : 0.0),
              child: _buildDot(context, page, index),
            );
          }),
        );
      },
    );
  }

  Widget _buildDot(BuildContext context, double currentPage, int index) {
    final isActive = (currentPage.round() == index);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}