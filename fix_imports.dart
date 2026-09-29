import 'dart:io';

void main() {
  final libDir = Directory('lib');
  final files = libDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.freezed.dart') && !f.path.endsWith('.g.dart') && !f.path.endsWith('.config.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    
    // We map the old paths to the new paths inside the features directory
    final featureMap = {
      'auth': 'shared/auth',
      'splash': 'shared/splash',
      'onboarding': 'shared/onboarding',
      'home': 'user/home',
      'cart': 'user/cart',
      'catalog': 'user/catalog',
      'product': 'user/product',
      'search': 'user/search',
    };

    // Replace absolute package imports: package:dhabayih_lmamlaka/features/auth/...
    for (final entry in featureMap.entries) {
      content = content.replaceAll('package:dhabayih_lmamlaka/features/${entry.key}/', 'package:dhabayih_lmamlaka/features/${entry.value}/');
    }

    // Replace relative imports crossing directories
    // We can just look for any import that contains 'features/X/' and replace it with 'features/Y/'
    for (final entry in featureMap.entries) {
      content = content.replaceAll('features/${entry.key}/', 'features/${entry.value}/');
    }

    // Now the tricky part: What if a file inside 'lib/features/shared/auth/' imports '../../../core/something'?
    // It used to be 'lib/features/auth/', so the import was '../../core/something'
    // Because we moved it one level deeper, we need to add '../' to any relative import that reaches out of the 'shared' or 'user' folder.
    // How to detect if it reaches out?
    // If we are currently inside 'lib/features/shared/' or 'lib/features/user/':
    
    // Check if the current file is inside a moved feature folder
    if (file.path.contains(r'features\shared') || file.path.contains(r'features/shared') ||
        file.path.contains(r'features\user') || file.path.contains(r'features/user')) {
      
      // We process all import lines
      final lines = content.split('\n');
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].startsWith('import ') && lines[i].contains(" '..")) {
            // Check how many levels it goes up.
            // If it escapes 'features/shared/auth/' -> 'features/shared/' -> 'features/' -> 'lib/'
            // It depends on the depth.
            // Let's just resolve the relative path using the OLD file location, then make it an absolute package import!
            
            // Old path was e.g. lib/features/auth/presentation/bloc/auth_bloc.dart
            String oldFilePath = file.path.replaceAll(r'features\shared\', r'features\').replaceAll(r'features/shared/', r'features/').replaceAll(r'features\user\', r'features\').replaceAll(r'features/user/', r'features/');
            
            // Extract the imported relative path
            final match = RegExp(r"import\s+'([^']+)'").firstMatch(lines[i]);
            if (match != null) {
              String relPath = match.group(1)!;
              if (relPath.startsWith('..')) {
                 // Convert old file path to URI
                 Uri oldUri = Uri.file(oldFilePath.replaceAll(r'\', '/'));
                 Uri resolvedUri = oldUri.resolve(relPath);
                 
                 // If the resolved URI is inside 'lib', we can convert it to a package import
                 String resolvedPath = resolvedUri.path;
                 int libIndex = resolvedPath.indexOf('/lib/');
                 if (libIndex != -1) {
                   String packagePath = resolvedPath.substring(libIndex + 5); // after '/lib/'
                   
                   // Now we apply the featureMap to the resolved package path in case it points to a moved feature
                   for (final entry in featureMap.entries) {
                     if (packagePath.startsWith('features/${entry.key}/')) {
                       packagePath = packagePath.replaceFirst('features/${entry.key}/', 'features/${entry.value}/');
                     }
                   }
                   
                   lines[i] = "import 'package:dhabayih_lmamlaka/$packagePath';";
                 }
              }
            }
        }
      }
      content = lines.join('\n');
    }

    file.writeAsStringSync(content);
  }
}
