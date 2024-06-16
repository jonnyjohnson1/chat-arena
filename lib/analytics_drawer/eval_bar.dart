import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TopicEvalBar extends StatefulWidget {
  // final Color userBarColor;
  // final Color botBarColor;
  final Map<String, Map<String, int>> data;
  const TopicEvalBar(
      {
      //   required this.userBarColor,
      // required this.botBarColor,
      required this.data,
      super.key});

  @override
  State<TopicEvalBar> createState() => _TopicEvalBarState();
}

class _TopicEvalBarState extends State<TopicEvalBar> {
  late List<String> participants;
  late List<String> sortedKeys;
  late bool isFirstSortedMaxToMin;
  late bool isSecondSortedMaxToMin;
  late String firstDataSetKey;
  late String secondDataSetKey;
  late List<String> pairs;
  late String selectedPair;

  bool isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _getParticipants();
    _focusNode.addListener(() {
      setState(() {
        isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void didUpdateWidget(covariant TopicEvalBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      debugPrint(widget.data.toString());
      _getParticipants();
    }
  }

  void _getParticipants() {
    participants = widget.data.keys.toList();
    if (participants.length >= 2) {
      pairs = _generatePairs(participants);
      selectedPair = pairs[0];
      _setSelectedPairKeys(selectedPair);

      sortedKeys = _getAllKeys(widget.data);
      isFirstSortedMaxToMin = true;
      isSecondSortedMaxToMin = false;
      _sortKeysByFirstDataSet(isFirstSortedMaxToMin);
    } else if (participants.length == 1) {
      String participant = participants.first;
      pairs = [
        "$participant & NA"
      ]; // set default other user until another person joins the chat
      selectedPair = pairs[0];
      _setSelectedPairKeys(selectedPair);
      sortedKeys = _getAllKeys(widget.data);

      isFirstSortedMaxToMin = true;
      isSecondSortedMaxToMin = false;
    }
  }

  Map<String, Map<String, int>> dummyData = {
    "jonny": {"present_score": 240},
    "ChatBot": {"present_score": 180},
    "tony": {"present_score": 195},
  };

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 220,
          child: Row(children: [
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
                    Tooltip(
                      message: firstDataSetKey.isEmpty ? null : firstDataSetKey,
                      preferBelow: false,
                      child: Text(
                        firstDataSetKey,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
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
                    Tooltip(
                      message:
                          secondDataSetKey.isEmpty ? null : secondDataSetKey,
                      preferBelow: false,
                      child: Text(
                        secondDataSetKey,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${dummyData[firstDataSetKey]!['present_score']!}"),
            const SizedBox(
              width: 5,
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 180,
                  height: 30,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(7)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey[200]!,
                            offset: const Offset(0, 0),
                            blurRadius: 1,
                            spreadRadius: 2)
                      ],
                      border: Border.all(
                          color: const Color.fromARGB(255, 169, 111, 223))),
                ),
                SizedBox(
                  width: 180,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: dummyData[firstDataSetKey]![
                              'present_score']!, // user 1 score,
                          child: Container(),
                        ),
                        Container(
                            width: 2,
                            height: 35,
                            color: const Color.fromARGB(255, 113, 49, 174)),
                        Expanded(
                            flex: dummyData[secondDataSetKey]![
                                'present_score']!, // user 2 score,
                            child: Container(
                              height: 28,
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 239, 225, 251),
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(7),
                                    topRight: Radius.circular(7)),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              width: 5,
            ),
            Text("${dummyData[secondDataSetKey]!['present_score']!}"),
          ],
        ),
      ],
    );
  }
}
