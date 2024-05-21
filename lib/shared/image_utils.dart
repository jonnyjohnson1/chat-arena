List<int> convertDynamicListToIntList(List<dynamic> dynamicList) {
  // Use map to convert each dynamic item to int
  return dynamicList.map((item) => int.parse(item.toString())).toList();
}

String buildString(List<dynamic> characters) {
  // a poor attempt at handling weird encoding returned from fastapi api
  String result = '';
  for (var char in characters) {
    if (char.runes.any((rune) => rune < 32 || rune > 126)) {
      result += ' '; // Replace weird character with space
    } else {
      result += char;
    }
  }
  return result;
}
