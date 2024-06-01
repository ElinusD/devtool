import 'dart:io';
import 'package:devtool/utils/common.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

Future<void> loadPasswords(
    Directory directory, Map<String, Map<String, String>> dataPasswords) async {
  try {
    List<FileSystemEntity> entitiesFiles = directory.listSync();
    for (var entity2 in entitiesFiles) {
      File file = File(entity2.path);
      Map<String, dynamic> jsonData = {};

      String jsonContent = await file.readAsString();
      if (jsonContent.isNotEmpty) {
        jsonData = parseJson(jsonContent);
      }

      dataPasswords[entity2.path.split('\\').last] = {
        'title': jsonData['title'],
        'login': jsonData['login'],
        'password': jsonData['password'],
        'url': jsonData['url'],
        'comment': jsonData['comment']
      };
    }
  } catch (e) {
    print('Error reading JSON files: $e');
  }
}

Future<void> loadFilesList(List<String> filesList) async {
  try {
    Directory docPasDirectory = Directory('');
    if (Platform.isWindows) {
      docPasDirectory = Directory('./src/pass');
    } else if (Platform.isMacOS) {
      Directory docDirectory = await getApplicationDocumentsDirectory();
      String docDirectoryPath = docDirectory.path;
      docPasDirectory = Directory('$docDirectoryPath/pass');
    } else {
      print('Running on an unknown platform');
      exit(1);
    }

    // Check if the pass directory exists
    bool directoryExists = await docPasDirectory.exists();

    if (!directoryExists) {
      await docPasDirectory.create(recursive: true);
    } else {
      print('Directory pass already exists.');
    }

    List<FileSystemEntity> entitiesFiles = docPasDirectory.listSync();
    for (var entity in entitiesFiles) {
      filesList.add(path.basename(entity.path));
    }
    filesList.sort();
  } catch (e) {
    print('Error reading files list: $e');
  }
}

Future<void> loadDocsFilesList(
    Map<String, List<String>> docsDirectoriesAndFilesList) async {
  try {
    List<FileSystemEntity> entitiesFiles =
        Directory('./src/data/docs').listSync();
    for (var entity1 in entitiesFiles) {
      List<FileSystemEntity> filesList =
          Directory('./src/data/docs/${entity1.path.split('\\').last}')
              .listSync();
      docsDirectoriesAndFilesList[entity1.path.split('\\').last] = [];
      for (var entity2 in filesList) {
        docsDirectoriesAndFilesList[entity1.path.split('\\').last]
            ?.add(entity2.path.split('\\').last);
      }
    }
  } catch (e) {
    print('Error reading files list');
  }
}

Future<String> loadDocFileContent(String dirName, String fileName) async {
  try {
    File file = File('./src/data/docs/$dirName/$fileName');
    return file.readAsStringSync();
  } catch (e) {
    print('Error reading file: $e');
    return 'Error loading content';
  }
}
