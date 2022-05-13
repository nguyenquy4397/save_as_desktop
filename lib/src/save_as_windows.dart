import 'package:save_as_desktop/src/save_as_desktop.dart';

class SaveAsWindows extends SaveAsDesktop {
  @override
  Future<String?> saveFile(
      {String? dialogTitle,
      String? fileName,
      String? initialDirectory,
      String? extension,
      bool lockParentWindow = false}) {
    // TODO: implement saveFile
    throw UnimplementedError();
  }
}
