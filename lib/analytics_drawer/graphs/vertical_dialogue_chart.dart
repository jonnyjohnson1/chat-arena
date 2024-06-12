import 'package:flutter/material.dart';

class VerticalDialogueChart extends StatefulWidget {
  final String title;
  final bool showTitle;
  final Color userBarColor;
  final Color botBarColor;
  final Map<String, Map<String, int>> data;
  final Map<String, Map<String, String>>? labelConfig;

  const VerticalDialogueChart({
    required this.title,
    this.showTitle = true,
    required this.userBarColor,
    required this.botBarColor,
    required this.data,
    this.labelConfig,
  });

  @override
  _VerticalDialogueChartState createState() => _VerticalDialogueChartState();
}

class _VerticalDialogueChartState extends State<VerticalDialogueChart> {
  late List<String> sortedKeys;
  late bool isFirstSortedMaxToMin;
  late bool isSecondSortedMaxToMin;
  late String firstDataSetKey;
  late String secondDataSetKey;
  late List<String> participants;
  late List<String> pairs;
  late String selectedPair;
  bool useDisplayName = true;

  @override
  void initState() {
    super.initState();
    _initializeState();
    _focusNode.addListener(() {
      setState(() {
        isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void didUpdateWidget(covariant VerticalDialogueChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _initializeState();
    }
  }

  void _initializeState() {
    participants = widget.data.keys.toList();
    if (participants.length >= 2) {
      print(participants);
      pairs = _generatePairs(participants);
      print(pairs);
      print("PAIRS");
      selectedPair = pairs[0];
      _setSelectedPairKeys(selectedPair);

      sortedKeys = _getAllKeys(widget.data);
      isFirstSortedMaxToMin = true;
      isSecondSortedMaxToMin = false;
      _sortKeysByFirstDataSet(isFirstSortedMaxToMin);
    } else {
      pairs = [
        "user & NA"
      ]; // set default other user until another person joins the chat
      selectedPair = pairs[0];
      _setSelectedPairKeys(selectedPair);
      sortedKeys = _getAllKeys(widget.data);

      isFirstSortedMaxToMin = true;
      isSecondSortedMaxToMin = false;
    }
  }

  List<String> _generatePairs(List<String> participants) {
    List<String> pairs = [];
    for (int i = 0; i < participants.length; i++) {
      for (int j = i + 1; j < participants.length; j++) {
        pairs.add('${participants[i]} & ${participants[j]}');
      }
    }
    return pairs;
  }

  void _setSelectedPairKeys(String pair) {
    List<String> keys = pair.split(' & ');
    firstDataSetKey = keys[0];
    secondDataSetKey = keys[1];
  }

  List<String> _getAllKeys(Map<String, Map<String, int>> data) {
    final Map<String, int> firstDataSet = data[firstDataSetKey] ?? {};
    final Map<String, int> secondDataSet = data[secondDataSetKey] ?? {};
    return {...firstDataSet.keys, ...secondDataSet.keys}.toList();
  }

  void _sortKeysByFirstDataSet(bool descending) {
    final Map<String, int> firstDataSet = widget.data[firstDataSetKey] ?? {};
    setState(() {
      sortedKeys.sort((a, b) => descending
          ? (firstDataSet[b] ?? 0).compareTo(firstDataSet[a] ?? 0)
          : (firstDataSet[a] ?? 0).compareTo(firstDataSet[b] ?? 0));
    });
  }

  void _sortKeysBySecondDataSet(bool descending) {
    final Map<String, int> secondDataSet = widget.data[secondDataSetKey] ?? {};
    setState(() {
      sortedKeys.sort((a, b) => descending
          ? (secondDataSet[b] ?? 0).compareTo(secondDataSet[a] ?? 0)
          : (secondDataSet[a] ?? 0).compareTo(secondDataSet[b] ?? 0));
    });
  }

  bool isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final Map<String, int> firstDataSet = widget.data[firstDataSetKey] ?? {};
    final Map<String, int> secondDataSet = widget.data[secondDataSetKey] ?? {};

    int maxValue =
        (firstDataSet.values.toList() + secondDataSet.values.toList())
            .reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        if (widget.showTitle)
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
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    isFirstSortedMaxToMin = !isFirstSortedMaxToMin;
                    _sortKeysByFirstDataSet(isFirstSortedMaxToMin);
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      firstDataSetKey,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
              width: 60,
              child: Focus(
                focusNode: _focusNode,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedPair,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedPair = newValue;
                          _setSelectedPairKeys(newValue);
                          sortedKeys = _getAllKeys(widget.data);
                          _sortKeysByFirstDataSet(isFirstSortedMaxToMin);
                        });
                      }
                    },
                    alignment: Alignment.center,
                    isDense: true,
                    icon: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.arrow_left),
                        Icon(Icons.arrow_right),
                        SizedBox(width: 7)
                      ],
                    ),
                    underline: const SizedBox.shrink(),
                    selectedItemBuilder: (BuildContext context) {
                      return pairs.map<Widget>((String value) {
                        return Container();
                        // isFocused
                        //     ? Text(value.split(' & ').join(' vs '))
                        //     : ;
                      }).toList();
                    },
                    items: pairs.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: SizedBox(
                          width: 250, // Set the width of the popup menu
                          child: Text(value.split(' & ').join(' vs ')),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    isSecondSortedMaxToMin = !isSecondSortedMaxToMin;
                    _sortKeysBySecondDataSet(isSecondSortedMaxToMin);
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      secondDataSetKey,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        _buildBarColumns(sortedKeys, firstDataSet, secondDataSet, maxValue),
      ],
    );
  }

  Widget _buildBarColumns(
      List<String> sortedKeys,
      Map<String, int> firstDataSet,
      Map<String, int> secondDataSet,
      int maxValue) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: sortedKeys.map((key) {
        final displayName = widget.labelConfig?[key]?['display_name'] ?? key;
        final fullName = widget.labelConfig?[key]?['name'] ?? key;

        double firstBarWidthFactor = (firstDataSet[key] ?? 0) / maxValue;
        double secondBarWidthFactor = (secondDataSet[key] ?? 0) / maxValue;
        Color firstColor = (firstDataSet[key] ?? 0) >= (secondDataSet[key] ?? 0)
            ? widget.userBarColor
            : widget.userBarColor.withOpacity(0.5);
        Color secondColor = (secondDataSet[key] ?? 0) > (firstDataSet[key] ?? 0)
            ? widget.botBarColor
            : widget.botBarColor.withOpacity(0.5);

        return Tooltip(
          message: fullName,
          preferBelow: true,
          child: SizedBox(
            height: 15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: FractionallySizedBox(
                          widthFactor: firstBarWidthFactor,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: firstColor,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${firstDataSet[key] ?? 0}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      useDisplayName = !useDisplayName;
                    });
                  },
                  child: SizedBox(
                    width: 35,
                    child: Align(
                      alignment: Alignment.center,
                      child: useDisplayName &&
                              widget.labelConfig?[key]?['display_name'] != null
                          ? Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          : Text(
                              key.length > 7 ? key.substring(0, 8) : key,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                    ),
                  ),
                ),
                Text(
                  '${secondDataSet[key] ?? 0}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: FractionallySizedBox(
                          widthFactor: secondBarWidthFactor,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: secondColor,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                    ],
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
