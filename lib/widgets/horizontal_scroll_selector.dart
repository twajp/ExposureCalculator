import 'package:flutter/material.dart';

class HorizontalScrollSelector extends StatelessWidget {
  final PageController pageController;
  final Map<String, double> map;
  final int selectedIndex;
  final ValueChanged<int> onPageChanged;

  const HorizontalScrollSelector({
    super.key,
    required this.pageController,
    required this.map,
    required this.selectedIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = map.keys.toList();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 40,
          child: PageView.builder(
            controller: pageController,
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              final isSelected = index == selectedIndex;
              return GestureDetector(
                onTap: () {
                  pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5), // 項目間のスペース
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.onPrimaryContainer,
                    borderRadius: BorderRadius.circular(8), // 角を丸める
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    items[index],
                    style: TextStyle(
                      fontSize: 16,
                      color: isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
