import 'dart:io';

void main() {
  final libDir = Directory('lib/features');
  if (!libDir.existsSync()) return;

  final files = libDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.freezed.dart') && !f.path.endsWith('.g.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    bool modified = false;
    final lines = content.split('\n');

    for (int i = 0; i < lines.length; i++) {
      if (lines[i].startsWith('import ') && lines[i].contains(" '..")) {
        // Regex to catch relative imports that go to core/
        final match = RegExp(r"import\s+'(\.\./)+core/([^']+)'").firstMatch(lines[i]);
        if (match != null) {
          final corePath = match.group(2);
          lines[i] = "import 'package:dhabayih_lmamlaka/core/$corePath';";
          modified = true;
        }
      }
    }

    if (modified) {
      file.writeAsStringSync(lines.join('\n'));
    }
  }
}
