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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 30,
          child: PageView.builder(
            controller: pageController,
            scrollDirection: Axis.horizontal,
            itemCount: map.keys.toList().length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              final isSelected = index == selectedIndex;
              return AnimatedContainer(
                duration: Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.grey[300],
                ),
                child: Center(
                  child: Text(
                    map.keys.toList()[index],
                    style: TextStyle(
                      fontSize: 16,
                      color: isSelected ? Colors.white : Colors.black,
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
