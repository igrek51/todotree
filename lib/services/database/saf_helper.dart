import 'package:collection/collection.dart';
import 'package:shared_storage/shared_storage.dart';
import 'package:todotree/util/logger.dart';

class SafHelper {
  // folder URI: content://com.android.externalstorage.documents/tree/1111-2808%3Atodo%2Ftodotree
  // file URI: content://com.android.externalstorage.documents/tree/1111-2808%3Atodo%2Ftodotree/document/1111-2808%3Atodo%2Ftodotree%2Ftodo.yaml

  final RegExp safTreeUriRegex = RegExp('^content://com\\.android\\.externalstorage\\.documents/tree/(.*?)%3A(.*)\$');

  Future<Uri?> grantFolderAccess() async {
    return await openDocumentTree();
  }

  bool isSafUri(String location) {
    return location.startsWith('content://');
  }

  Future<void> saveFileContent(String content, String folderSafUri, String filename) async {
    final folderUri = Uri.parse(folderSafUri);
    final (bool fileExists, Uri fileUri) = await getChildFileUri(folderSafUri, folderUri, filename);

    if (fileExists) {
      final result = await writeToFileAsString(fileUri, content: content);
      if (result != true) {
        throw Exception('Failed to write to SAF file: $fileUri: $result');
      }
      logger.debug('SAF: file written: $fileUri');
    } else {
      final doc = await createFileAsString(folderUri, mimeType: 'any', displayName: filename, content: content);
      if (doc == null) {
        throw Exception('Failed to create SAF file: $fileUri');
      }
      logger.debug('SAF: file created: ${doc.uri}');
    }

    logger.debug('external backup saved to $fileUri');
  }

  Future<(bool, Uri)> getChildFileUri(String folderSafUri, Uri folderUri, String filename) async {
    final match = safTreeUriRegex.firstMatch(folderSafUri);
    if (match != null) {
      String disk = match.group(1) ?? '';
      String folderPath = match.group(2) ?? '';
      if (folderPath.isEmpty) throw Exception('cannot match folder path in SAF URI');
      String fileUriStr = 'content://com.android.externalstorage.documents/tree/$disk%3A$folderPath/document/$disk%3A$folderPath%2F$filename';
      final fileUri = Uri.parse(fileUriStr);
      bool fileExists = await exists(fileUri) ?? false;
      return (fileExists, fileUri);

    } else {
      logger.info('Looking for child document using generic SAF provider');
      List<DocumentFile> docChildren = await listFiles(folderUri, columns: [DocumentFileColumn.id, DocumentFileColumn.displayName]).toList();
      DocumentFile? docChild = docChildren.firstWhereOrNull((e) => e.name == filename);
      if (docChild == null) return (false, folderUri);
      return (true, docChild.uri);
    }
  }
}
