import 'package:chat/models/conversation_settings.dart';
import 'package:flutter/material.dart';

class ConversationSettingsPage extends StatefulWidget {
  final Function onChange;
  final initSettings;
  const ConversationSettingsPage(
      {this.initSettings, required this.onChange, super.key});

  @override
  _ConversationSettingsPageState createState() =>
      _ConversationSettingsPageState();
}

class _ConversationSettingsPageState extends State<ConversationSettingsPage> {
  late ConversationVoiceSettings _settings;
  @override
  void initState() {
    super.initState();
    _settings = widget.initSettings ??
        ConversationVoiceSettings(
          attention: "inclusive",
          tone: "friendly",
          distance: "distant",
          pace: "leisurely",
          depth: "insightful",
          engagement: "engaging",
          messageLength: "brief",
        );
  }

  final List<String> _tones = [
    "friendly",
    "analytical",
    "serious",
    "playful",
    "impassioned",
    "sardonic",
    "mean",
    "self-righteous",
    "pirate"
  ];
  final List<String> _attention = [
    "selfish",
    "inclusive",
    "avoidant",
    "inward",
    "outward"
  ];
  final List<String> _distances = [
    "distant",
    "intimate",
    "close",
    "in confidence",
    "cordial",
    "professional",
    "unfamiliar"
  ];
  final List<String> _paces = [
    "leisurely",
    "slow",
    "steady",
    "measured",
    "moderate",
    "even-paced",
    "hurried",
    "fast",
    "frantic",
    "panicked"
  ];
  final List<String> _depths = [
    "shallow",
    "superficial",
    "basic",
    "single-meaning",
    "straightforward",
    "literal",
    "simple",
    "clear-cut",
    "thoughtful",
    "layered",
    "nuanced",
    "insightful",
    "complex",
    "multifaceted",
    "profound",
    "deep",
    "philosophical",
    "introspective"
  ];
  final List<String> _engagements = [
    "engaging",
    "disinterested",
    "attentive",
    "distracted",
    "curious",
    "supportive",
    "apathetic",
    "argumentative",
    "responsive",
    "aloof",
    "inquisitive",
    "reserved",
    "interactive",
    "passive",
    "empathetic",
    "defensive",
    "collaborative",
    "critical",
    "engrossed",
    "detached"
  ];
  final List<String> _messageLengths = [
    "terse",
    "concise",
    "brief",
    "succinct",
    "short",
    "pithy",
    "to-the-point",
    "matter-of-fact",
    "clear",
    "normal",
    "standard",
    "typical",
    "detailed",
    "elaborate",
    "comprehensive",
    "long-winded"
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDropdown("Attention", _settings.attention, _attention,
              (newValue) {
            setState(() {
              _settings.attention = newValue;
            });
            widget.onChange(_settings);
          }),
          _buildDivier(),
          _buildDropdown("Tone", _settings.tone, _tones, (newValue) {
            setState(() {
              _settings.tone = newValue;
            });
            widget.onChange(_settings);
          }),
          _buildDivier(),
          _buildDropdown("Distance", _settings.distance, _distances,
              (newValue) {
            setState(() {
              _settings.distance = newValue;
            });
            widget.onChange(_settings);
          }),
          _buildDivier(),
          _buildDropdown("Pace", _settings.pace, _paces, (newValue) {
            setState(() {
              _settings.pace = newValue;
            });
            widget.onChange(_settings);
          }),
          _buildDivier(),
          _buildDropdown("Depth", _settings.depth, _depths, (newValue) {
            setState(() {
              _settings.depth = newValue;
            });
            widget.onChange(_settings);
          }),
          _buildDivier(),
          _buildDropdown("Engagement", _settings.engagement, _engagements,
              (newValue) {
            setState(() {
              _settings.engagement = newValue;
            });
            widget.onChange(_settings);
          }),
          _buildDivier(),
          _buildDropdown(
              "Message Length", _settings.messageLength, _messageLengths,
              (newValue) {
            setState(() {
              _settings.messageLength = newValue;
            });
            widget.onChange(_settings);
          }),
        ],
      ),
    );
  }

  Widget _buildDivier() {
    return const Divider(
      height: 1,
      thickness: 1,
    );
  }

  Widget _buildDropdown(String label, String value, List<String> options,
      ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          DropdownButton<String>(
            isDense: true,
            value: value,
            onChanged: (newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
            underline: Container(),
            alignment: Alignment.centerRight,
            items: options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: SizedBox(
                  height: 20,
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
