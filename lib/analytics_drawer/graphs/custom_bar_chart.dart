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
    double barWidth = 29;

    return LayoutBuilder(
      builder: (context, constraints) {
        bool needsScrolling =
            sortedData.length * barWidth > constraints.maxWidth;

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
            needsScrolling
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _buildBarRow(sortedData, maxValue, barWidth),
                  )
                : _buildBarRow(sortedData, maxValue, barWidth),
          ],
        );
      },
    );
  }

  Widget _buildBarRow(
      Map<String, int> sortedData, int maxValue, double barWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: sortedData.entries.map((entry) {
        double barHeight = entry.value / maxValue;
        return Tooltip(
          message: entry.key,
          preferBelow: true,
          child: SizedBox(
            width: barWidth,
            child: Column(
              children: [
                const SizedBox(height: 4),
                SizedBox(
                  height: 94,
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
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 35,
                  child: Align(
                    alignment: Alignment.center,
                    child: Transform.rotate(
                      angle: -0.785398, // Rotate by -45 degrees (in radians)
                      child: Text(
                        entry.key.length > 7
                            ? entry.key.substring(0, 8)
                            : entry.key,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                        // textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
