import 'package:chat/theming/theming_config.dart';
import 'package:flutter/material.dart';

class CustomChip extends StatelessWidget {
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomChip({
    Key? key,
    required this.index,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        hoverColor: Colors.blue.withOpacity(0.2),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: isSelected
                ? informationColor
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [BoxShadow(color: informationColor, blurRadius: 4)]
                : [const BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          child: Center(
            child: Text(
              "${(index + 1)}",
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
