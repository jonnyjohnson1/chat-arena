import 'package:flutter/material.dart';

class CustomBarChart extends StatefulWidget {
  final String title;
  final Color barColor;
  final Map<String, int> totalsData;
  final Map<String, Map<String, String>>? labelConfig;

  const CustomBarChart({
    required this.title,
    required this.barColor,
    required this.totalsData,
    this.labelConfig,
  });

  @override
  _CustomBarChartState createState() => _CustomBarChartState();
}

class _CustomBarChartState extends State<CustomBarChart> {
  bool useDisplayName = true;

  @override
  Widget build(BuildContext context) {
    int maxValue = widget.totalsData.values.reduce((a, b) => a > b ? a : b);
    // Convert map entries to a list and sort the list by value in descending order
    var sortedEntries = widget.totalsData.entries.toList()
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
                  widget.title,
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
        final displayName =
            widget.labelConfig?[entry.key]?['display_name'] ?? entry.key;
        final fullName = widget.labelConfig?[entry.key]?['name'] ?? entry.key;

        double barHeight = entry.value / maxValue;
        return Tooltip(
          message: fullName,
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
                              color: widget.barColor,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () {
                    setState(() {
                      useDisplayName = !useDisplayName;
                    });
                  },
                  child: Container(
                    // height: 35,
                    child: Align(
                      alignment: Alignment.center,
                      child: useDisplayName &&
                              widget.labelConfig?[entry.key]?['display_name'] !=
                                  null
                          ? Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          : Transform.rotate(
                              angle:
                                  -0.785398, // Rotate by -45 degrees (in radians)
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
                              ),
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
