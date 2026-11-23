/// Keeps a right-to-left name (Arabic, Hebrew...) from reordering the
/// left-to-right sentence it is placed in, and vice versa.
///
/// Wraps [text] in Unicode First Strong Isolate / Pop Directional Isolate marks
/// only when it contains RTL letters, so plain Latin text is returned unchanged.
String bidiIsolate(String text) {
  if (text.isEmpty || !_rtl.hasMatch(text)) return text;
  return '\u2068$text\u2069';
}

final RegExp _rtl = RegExp(r'[\u0590-\u08FF\uFB1D-\uFDFF\uFE70-\uFEFF]');
