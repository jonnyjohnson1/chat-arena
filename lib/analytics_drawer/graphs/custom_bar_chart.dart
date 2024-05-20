import 'package:flutter/material.dart';

class CustomBarChart extends StatelessWidget {
  final String title;
  final Color barColor;
  final Map<String, int> totalsData;

  const CustomBarChart(
      {required this.title, required this.barColor, required this.totalsData});

  @override
  Widget build(BuildContext context) {
    int maxValue = totalsData.values.reduce((a, b) => a > b ? a : b);
    // Convert map entries to a list and sort the list by value in descending order
    var sortedEntries = totalsData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Create a new map from the sorted list
    var sortedData = Map.fromEntries(sortedEntries);
    double totalWidth = 300;
    double barWidth = 32; //totalWidth / 8.8;

    return Column(
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline),
            ),
          ],
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: sortedData.entries.map((entry) {
              double barHeight = entry.value / maxValue;
              return Tooltip(
                message: entry.key,
                preferBelow: true,
                child: SizedBox(
                  width: barWidth,
                  height: 88,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        entry.value.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Flexible(
                        child: FractionallySizedBox(
                          heightFactor: barHeight,
                          widthFactor:
                              0.8, // Adjust this factor if needed for better bar width appearance
                          child: Container(
                            decoration: BoxDecoration(
                              color: barColor,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.key.length > 3
                            ? entry.key.substring(0, 4)
                            : entry.key,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
