import 'dart:convert' show utf8;
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_storage/shared_storage.dart';
import 'package:todotree/util/logger.dart';

class SafHelper {
  final RegExp safTreeUriRegex = RegExp('^content://com\\.android\\.externalstorage\\.documents/tree/(.*?)%3A(.*)\$');
  final RegExp iOSFileUriRegex = RegExp('^file://(/.*)/$');

  bool get isIOS => Platform.isIOS;
  bool get isAndroid => Platform.isAndroid;

  Future<String?> grantFolderAccess() async {
    if (isIOS) {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory != null) {
        return 'file://$selectedDirectory/';
      }
      return null;
    } else if (isAndroid) {
      return await openDocumentTree();
    }
    return null;
  }

  bool isSafUri(String location) {
    return location.startsWith('content://') || location.startsWith('file://');
  }

  bool isIOSUri(String location) {
    return location.startsWith('file://') && !location.startsWith('content://');
  }

  Future<void> saveFileContent(String content, String folderUri, String filename) async {
    if (isIOSUri(folderUri)) {
      await _saveIOSFile(content, folderUri, filename);
    } else if (isAndroid) {
      await _saveAndroidFile(content, folderUri, filename);
    }
    logger.info('external backup saved');
  }

  Future<void> _saveIOSFile(String content, String folderUri, String filename) async {
    final match = iOSFileUriRegex.firstMatch(folderUri);
    if (match == null) {
      throw Exception('Invalid iOS file URI: $folderUri');
    }
    final folderPath = match.group(1)!;
    final filePath = '$folderPath/$filename';
    final file = File(filePath);
    await file.writeAsString(content);
    logger.debug('iOS file written: $filePath');
  }

  Future<void> _saveAndroidFile(String content, String folderSafUri, String filename) async {
    final folderUri = Uri.parse(folderSafUri);
    final contentBytes = utf8.encode(content);
    
    final (fileExists, fileUri) = await _getChildFileUriAndroid(folderSafUri, folderUri, filename);
    
    if (fileExists) {
      final result = await writeToFileAsBytes(fileUri, bytes: contentBytes);
      if (result != true) {
        throw Exception('Failed to write to SAF file: $fileUri: $result');
      }
      logger.debug('SAF file written: $fileUri');
    } else {
      final doc = await createFileAsBytes(folderUri, mimeType: 'any', displayName: filename, bytes: contentBytes);
      if (doc == null) {
        throw Exception('Failed to create SAF file: $fileUri');
      }
      logger.debug('SAF file created: ${doc.uri}');
    }
  }

  Future<(bool, Uri)> _getChildFileUriAndroid(String folderSafUri, Uri folderUri, String filename) async {
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