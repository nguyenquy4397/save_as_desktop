import 'dart:io';

import 'package:save_as_desktop/src/save_as_desktop.dart';

class SaveAsMacos extends SaveAsDesktop {
  int count = 0;
  @override
  Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    String? extension,
    bool lockParentWindow = false,
  }) async {
    /// Get path of osascript
    final String executable = await isExecutableOnPath('osascript');

    /// First execute: declare var for handling auto add extension
    List<String> firstExecute = ['-e'];
    String firstCommand = 'property resultFile: \"\"';
    firstExecute.add(firstCommand);

    /// Second execute: show save as dialog and get name from user input
    List<String> secondExecute = ['-e'];
    String fileNameCommand = fileName != null && fileName.isNotEmpty
        ? 'default name \"$fileName\" '
        : '';
    String initialDirCommand =
        initialDirectory != null && initialDirectory.isNotEmpty
            ? 'default location \"$initialDirectory\" '
            : '';
    String secondCommand =
        'set resultFile to (choose file name $fileNameCommand${initialDirCommand}with prompt \"${dialogTitle ?? defaultDialogTitle}\") as text';
    secondExecute.add(secondCommand);

    /// Third execute: handling if file name dont have extension
    List<String> thirdExecute = ['-e'];
    String thirdCommand =
        'if resultFile does not end with \".$extension\" then set resultFile to resultFile & \".$extension\"';
    thirdExecute.add(thirdCommand);

    final String? saveFileResult = await runExecutableWithArguments(
      executable,
      [...firstExecute, ...secondExecute, ...thirdExecute],
    );
    if (saveFileResult == null) {
      return null;
    }
    return resultStringToFilePaths(saveFileResult).first;
  }

  Future<String> isExecutableOnPath(String executable) async {
    final path = await runExecutableWithArguments('which', [executable]);
    if (path == null) {
      throw Exception(
        'Couldn\'t find the executable $executable in the path.',
      );
    }
    return path;
  }

  Future<String?> runExecutableWithArguments(
    String executable,
    List<String> arguments,
  ) async {
    final processResult = await Process.run(executable, arguments);
    final path = processResult.stdout?.toString().trim();
    if (processResult.exitCode != 0 || path == null || path.isEmpty) {
      return null;
    }
    return path;
  }

  List<String> resultStringToFilePaths(String fileSelectionResult) {
    if (fileSelectionResult.trim().isEmpty) {
      return [];
    }

    final paths = fileSelectionResult
        .trim()
        .split(', alias ')
        .map((String path) => path.trim())
        .where((String path) => path.isNotEmpty)
        .toList();

    if (paths.length == 1 && paths.first.startsWith('file ')) {
      // The first token of the first path is "file" in case of the save file
      // dialog
      paths[0] = paths[0].substring(5);
    } else if (paths.isNotEmpty && paths.first.startsWith('alias ')) {
      // The first token of the first path is "alias" in case of the
      // file/directory picker dialog
      paths[0] = paths[0].substring(6);
    }

    return paths.map((String path) {
      final pathElements = path.split(':').where((e) => e.isNotEmpty).toList();
      final volumeName = pathElements[0];
      return ['/Volumes', volumeName, ...pathElements.sublist(1)].join('/');
    }).toList();
  }
}
