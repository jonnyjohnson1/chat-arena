import 'package:chat/models/spacy_size.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SpacyModelSelector extends StatefulWidget {
  final void Function(SpacyModel) onSelected;

  const SpacyModelSelector({required this.onSelected, Key? key})
      : super(key: key);

  @override
  _SpacyModelSelectorState createState() => _SpacyModelSelectorState();
}

class _SpacyModelSelectorState extends State<SpacyModelSelector> {
  SpacyModel _selectedModel = SpacyModel.trf;

  final Map<SpacyModel, String> _modelDescriptions = {
    SpacyModel.small: "en_core_web_sm\n\n"
        "Latest: 3.7.1\n"
        "Installation: python -m spacy download en_core_web_sm\n"
        "Components: tok2vec, tagger, parser, senter, ner, attribute_ruler, lemmatizer.\n"
        "Language: English\n"
        "Type: CORE (Vocabulary, syntax, entities)\n"
        "Genre: WEB (written text: blogs, news, comments)\n"
        "Size: 12 MB\n"
        "Pipeline: tok2vec, tagger, parser, attribute_ruler, lemmatizer, ner\n"
        "Vectors: 0 keys, 0 unique vectors (0 dimensions)\n"
        "Download Link: en_core_web_sm-3.7.1-py3-none-any.whl\n"
        "Sources: OntoNotes 5, ClearNLP Constituent-to-Dependency Conversion, WordNet 3.0\n"
        "Author: Explosion\n"
        "License: MIT",
    SpacyModel.med: "en_core_web_md\n\n"
        "Latest: 3.7.1\n"
        "Installation: python -m spacy download en_core_web_md\n"
        "Components: tok2vec, tagger, parser, senter, ner, attribute_ruler, lemmatizer.\n"
        "Language: English\n"
        "Type: CORE (Vocabulary, syntax, entities, vectors)\n"
        "Genre: WEB (written text: blogs, news, comments)\n"
        "Size: 40 MB\n"
        "Pipeline: tok2vec, tagger, parser, attribute_ruler, lemmatizer, ner\n"
        "Vectors: 514k keys, 20k unique vectors (300 dimensions)\n"
        "Download Link: en_core_web_md-3.7.1-py3-none-any.whl\n"
        "Sources: OntoNotes 5, ClearNLP Constituent-to-Dependency Conversion, WordNet 3.0, Explosion Vectors (OSCAR 2109 + Wikipedia + OpenSubtitles + WMT News Crawl)\n"
        "Author: Explosion\n"
        "License: MIT",
    SpacyModel.large: "en_core_web_lg\n\n"
        "Latest: 3.7.1\n"
        "Installation: python -m spacy download en_core_web_lg\n"
        "Components: tok2vec, tagger, parser, senter, ner, attribute_ruler, lemmatizer.\n"
        "Language: English\n"
        "Type: CORE (Vocabulary, syntax, entities, vectors)\n"
        "Genre: WEB (written text: blogs, news, comments)\n"
        "Size: 560 MB\n"
        "Pipeline: tok2vec, tagger, parser, attribute_ruler, lemmatizer, ner\n"
        "Vectors: 514k keys, 514k unique vectors (300 dimensions)\n"
        "Download Link: en_core_web_lg-3.7.1-py3-none-any.whl\n"
        "Sources: OntoNotes 5, ClearNLP Constituent-to-Dependency Conversion, WordNet 3.0, Explosion Vectors (OSCAR 2109 + Wikipedia + OpenSubtitles + WMT News Crawl)\n"
        "Author: Explosion\n"
        "License: MIT",
    SpacyModel.trf: "en_core_web_trf\n\n"
        "Latest: 3.7.3\n"
        "Installation: python -m spacy download en_core_web_trf\n"
        "Components: transformer, tagger, parser, ner, attribute_ruler, lemmatizer.\n"
        "Language: English\n"
        "Type: CORE (Vocabulary, syntax, entities)\n"
        "Genre: WEB (written text: blogs, news, comments)\n"
        "Size: 436 MB\n"
        "Pipeline: transformer, tagger, parser, attribute_ruler, lemmatizer, ner\n"
        "Vectors: 0 keys, 0 unique vectors (0 dimensions)\n"
        "Download Link: en_core_web_trf-3.7.3-py3-none-any.whl\n"
        "Sources: OntoNotes 5, ClearNLP Constituent-to-Dependency Conversion, WordNet 3.0, roberta-base\n"
        "Author: Explosion\n"
        "License: MIT",
  };

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = TextStyle(
        color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(.74));
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(getSpacyModelString(_selectedModel)),
                    content: SingleChildScrollView(
                      child: Text(_modelDescriptions[_selectedModel]!),
                    ),
                    actions: [
                      TextButton(
                        child: const Text("Close"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    getSpacyModelString(_selectedModel),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _getCoreFeatures(_selectedModel),
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Select model size (this can be changed later)",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: SpacyModel.values.map((SpacyModel model) {
            return ChoiceChip(
              label: Text(getSimpleSpacyModelString(model), style: textStyle),
              selected: _selectedModel == model,
              onSelected: (bool selected) {
                setState(() {
                  _selectedModel = model;
                });
                widget.onSelected(_selectedModel);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getCoreFeatures(SpacyModel model) {
    switch (model) {
      case SpacyModel.small:
        return "Size: 12 MB\nComponents: tok2vec, tagger, parser, senter, ner.\n"
            "Recommended for: Simple CPU environments.";
      case SpacyModel.med:
        return "Size: 40 MB\nComponents: tok2vec, tagger, parser, senter, ner.\n"
            "Recommended for: Standard CPU environments.";
      case SpacyModel.large:
        return "Size: 560 MB\nComponents: tok2vec, tagger, parser, senter, ner.\n"
            "Recommended for: Advanced CPU environments.";
      case SpacyModel.trf:
        return "Size: 436 MB\nComponents: transformer, tagger, parser, ner.\n"
            "Recommended for: Environments with a GPU.";
      default:
        return "Size: 12 MB\nComponents: tok2vec, tagger, parser, senter, ner.\n"
            "Recommended for: Simple CPU environments.";
    }
  }
}
