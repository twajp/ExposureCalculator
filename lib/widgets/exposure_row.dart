import 'package:flutter/material.dart';
import '../../widgets/horizontal_scroll_selector.dart';

class ExposureRow extends StatelessWidget {
  final String label;
  final PageController pageController;
  final Map<String, double> map;
  final int selectedIndex;
  final Function(int) onPageChanged;
  final bool showSyncButton;
  final bool isSyncEnabled;
  final VoidCallback? onSyncToggle;

  const ExposureRow({
    super.key,
    required this.label,
    required this.pageController,
    required this.map,
    required this.selectedIndex,
    required this.onPageChanged,
    this.showSyncButton = false,
    this.isSyncEnabled = false,
    this.onSyncToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        Row(
          children: [
            Expanded(
              child: HorizontalScrollSelector(
                pageController: pageController,
                map: map,
                selectedIndex: selectedIndex,
                onPageChanged: onPageChanged,
              ),
            ),
            if (showSyncButton && onSyncToggle != null)
              SizedBox(
                width: 24,
                height: 24,
                child: IconButton(
                  padding: const EdgeInsets.only(left: 8),
                  icon: Icon(
                    isSyncEnabled ? Icons.sync : Icons.sync_disabled,
                    color: isSyncEnabled ?  Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                  ),
                  onPressed: onSyncToggle,
                ),
              ),
            if (showSyncButton == false)
              SizedBox(
                width: 24,
                height: 24,
              ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
