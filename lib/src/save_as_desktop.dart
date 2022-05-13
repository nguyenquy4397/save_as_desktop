import 'dart:io';

import 'package:save_as_desktop/src/save_as_macos.dart';
import 'package:save_as_desktop/src/save_as_windows.dart';

enum FileType {
  any,
  media,
  image,
  video,
  audio,
  custom,
}

enum FilePickerStatus {
  picking,
  done,
}

const String defaultDialogTitle = 'Save As';

abstract class SaveAsDesktop {
  SaveAsDesktop();

  factory SaveAsDesktop._setPlatform() {
    if (Platform.isWindows) {
      return SaveAsWindows();
    } else if (Platform.isMacOS) {
      return SaveAsMacos();
    } else {
      throw UnimplementedError(
        'The current platform "${Platform.operatingSystem}" is not supported by this plugin.',
      );
    }
  }

  static SaveAsDesktop get platform => SaveAsDesktop._setPlatform();

  Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    String? extension,
    bool lockParentWindow = false,
  });
}
