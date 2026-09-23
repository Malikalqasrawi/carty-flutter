import 'package:flutter/material.dart';

import '../core/theme.dart';

/// The  [-]  2  [+]  control used on product cards, details and the cart.
class QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool compact;

  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 18.0 : 22.0;
    final constraints = compact
        ? const BoxConstraints(minWidth: 32, minHeight: 32)
        : const BoxConstraints(minWidth: 44, minHeight: 44);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: constraints,
            color: Colors.black,
            iconSize: iconSize,
            onPressed: onDecrement,
            icon: Icon(quantity == 1 ? Icons.delete_outline : Icons.remove),
          ),
          // AnimatedSwitcher makes the number slide when it changes.
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Text(
              '$quantity',
              key: ValueKey(quantity),
              style: TextStyle(
                fontSize: compact ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: constraints,
            color: Colors.black,
            iconSize: iconSize,
            onPressed: onIncrement,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
