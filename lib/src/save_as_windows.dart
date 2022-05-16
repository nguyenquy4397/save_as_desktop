import 'dart:io';

import 'package:save_as_desktop/src/save_as_desktop.dart';

class SaveAsWindows extends SaveAsDesktop {
  @override
  Future<String?> saveFile(
      {String? dialogTitle,
      String? fileName,
      String? initialDirectory,
      String? extension,
      bool lockParentWindow = false}) async {
    String command = '''function Save-File([string] \$initialDirectory){

          [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
      
          \$OpenFileDialog = New-Object System.Windows.Forms.SaveFileDialog
          \$OpenFileDialog.Title = "${dialogTitle ?? defaultDialogTitle}"
          \$OpenFileDialog.initialDirectory = "\$initialDirectory"
          \$OpenFileDialog.FileName = "${fileName ?? ''}"
          \$OpenFileDialog.filter = "${extension != null ? '${extension.toUpperCase()} (*.$extension)| *.$extension' : 'All files (*.*)| *.*'}"
          \$result=\$OpenFileDialog.ShowDialog()
          if(\$result -eq "OK") {
          return \$OpenFileDialog.filename
          } else {
          return ""
          }
        }

        \$SaveFile=Save-File ${initialDirectory ?? '\$env:USERPROFILE'}
      
        if (\$SaveFile -ne "")
        {
        echo "\$SaveFile"
        } else {
        echo ""
        }''';

    final processConvertBase64 = await Process.run(
      'Powershell.exe',
      [
        '[System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes(\'$command\'))',
      ],
    );

    final processSave = await Process.run(
      'Powershell.exe',
      [
        '-EncodedCommand',
        processConvertBase64.stdout,
      ],
    );
    final path = processSave.stdout?.toString().trim();
    if (processSave.exitCode != 0 || path == null || path.isEmpty) {
      return null;
    }
    return path;
  }
}
