import 'dart:math';

import 'package:flutter/material.dart';

import 'package:todotree/model/tree_node.dart';
import 'package:todotree/services/clipboard_manager.dart';
import 'package:todotree/services/info_service.dart';
import 'package:todotree/util/numbers.dart';
import 'package:todotree/views/editor/editor_state.dart';
import 'package:todotree/services/tree_traverser.dart';
import 'package:todotree/views/home/home_state.dart';
import 'package:todotree/views/tree_browser/browser_controller.dart';

class EditorController {
  HomeState homeState;
  EditorState editorState;

  late BrowserController browserController;

  ClipboardManager clipboardManager;
  TreeTraverser treeTraverser;

  EditorController(this.homeState, this.editorState, this.treeTraverser, this.clipboardManager);

  void saveNode() {
    if (editorState.editedNode != null) {
      saveEditedNode();
    } else if (editorState.newItemPosition != null) {
      saveNewNode();
    }
    treeTraverser.unsavedChanges = true;
  }

  void saveEditedNode() {
    final newName = editorState.editTextController.text.trim();
    if (editorState.editedNode == null) return;
    if (newName.isEmpty) {
      browserController.removeOneNode(editorState.editedNode!);
      cancelEdit();
      return InfoService.info('Blank node has been deleted.');
    }
    editorState.editedNode?.name = newName;
    treeTraverser.focusNode = editorState.editedNode;
    browserController.renderItems();
    homeState.pageView = HomePageView.treeBrowser;
    homeState.notify();
    editorState.editTextController.clear();
    editorState.notify();
  }

  void saveNewNode() {
    final newName = editorState.editTextController.text.trim();
    if (newName.isEmpty) {
      cancelEdit();
      return InfoService.info('Blank node has been dropped.');
    }
    final newNode = TreeNode.textNode(newName);
    treeTraverser.addChildToCurrent(newNode, position: editorState.newItemPosition);
    browserController.renderItems();
    homeState.pageView = HomePageView.treeBrowser;
    homeState.notify();
    editorState.editTextController.clear();
    editorState.notify();
  }

  void saveAndAddNext() {
    final newName = editorState.editTextController.text.trim();
    if (newName.isEmpty) {
      cancelEdit();
      return InfoService.info('Blank node has been dropped.');
    }
  }

  void addNodeAt(int position) {
    if (position < 0) position = treeTraverser.currentParent.size; // last
    if (position > treeTraverser.currentParent.size) {
      position = treeTraverser.currentParent.size;
    }
    editorState.newItemPosition = position;
    editorState.editedNode = null;
    editorState.numericKeyboard = false;
    editorState.editTextController.text = '';
    editorState.notify();
    homeState.pageView = HomePageView.itemEditor;
    homeState.notify();
  }

  void editNode(TreeNode node) {
    editorState.newItemPosition = null;
    editorState.editedNode = node;
    editorState.numericKeyboard = false;
    editorState.editTextController.text = node.name;
    editorState.notify();
    homeState.pageView = HomePageView.itemEditor;
    homeState.notify();
  }

  void cancelEdit() {
    treeTraverser.focusNode = editorState.editedNode;
    browserController.renderItems();
    homeState.pageView = HomePageView.treeBrowser;
    homeState.notify();
    editorState.editTextController.clear();
    editorState.notify();
  }

  void jumpCursorToStart() {
    editorState.editTextController.selection = TextSelection.fromPosition(
      TextPosition(offset: 0),
    );
    editorState.textEditFocus.requestFocus();
  }

  void jumpCursorToEnd() {
    editorState.editTextController.selection = TextSelection.fromPosition(
      TextPosition(offset: editorState.editTextController.text.length),
    );
    editorState.textEditFocus.requestFocus();
  }

  void moveCursorLeft() {
    final currentPos = editorState.editTextController.selection.baseOffset;
    final newPos = (currentPos - 1).clampMin(0);
    editorState.editTextController.selection = TextSelection.fromPosition(
      TextPosition(offset: newPos),
    );
    editorState.textEditFocus.requestFocus();
  }

  void moveCursorRight() {
    final currentPos = editorState.editTextController.selection.extentOffset;
    final newPos = (currentPos + 1).clampMax(editorState.editTextController.text.length);
    editorState.editTextController.selection = TextSelection.fromPosition(
      TextPosition(offset: newPos),
    );
    editorState.textEditFocus.requestFocus();
  }

  void selectAll() {
    var selection = editorState.editTextController.selection;
    var len = editorState.editTextController.text.length;
    if (selection.baseOffset == 0 && selection.extentOffset == len) {
      // already selected all
      editorState.editTextController.selection = TextSelection.fromPosition(
        TextPosition(offset: editorState.editTextController.text.length),
      );
    } else {
      editorState.editTextController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: len,
      );
    }
    editorState.textEditFocus.requestFocus();
  }

  void copyToClipboard() {
    final selection = editorState.editTextController.selection;
    if (selection.baseOffset == selection.extentOffset) {
      return InfoService.info('No selection to copy.');
    }
    final minSelection = min(selection.baseOffset, selection.extentOffset);
    final maxSelection = max(selection.baseOffset, selection.extentOffset);
    final selectedText = editorState.editTextController.text.substring(
      minSelection,
      maxSelection,
    );
    clipboardManager.copyAsText(selectedText);
  }

  Future<void> pasteFromClipboard() async {
    final clipboardText = await clipboardManager.readSystemClipboard();
    if (clipboardText == null) {
      return InfoService.info('Clipboard is empty.');
    }
    final selection = editorState.editTextController.selection;
    final minSelection = min(selection.baseOffset, selection.extentOffset);
    final maxSelection = max(selection.baseOffset, selection.extentOffset);
    final textBefore = editorState.editTextController.text.substring(0, minSelection);
    final textAfter = editorState.editTextController.text.substring(maxSelection);
    final finalText = textBefore + clipboardText + textAfter;

    editorState.editTextController.text = finalText;
    editorState.editTextController.selection = TextSelection.fromPosition(
      TextPosition(offset: textBefore.length + clipboardText.length),
    );
    editorState.textEditFocus.requestFocus();
    InfoService.info('Clipboard pasted.');
  }

  void keyBackspace() {
    final selection = editorState.editTextController.selection;
    final minSelection = min(selection.baseOffset, selection.extentOffset);
    final maxSelection = max(selection.baseOffset, selection.extentOffset);
    final textBefore = editorState.editTextController.text.substring(0, minSelection);
    final textAfter = editorState.editTextController.text.substring(maxSelection);

    String finalText;
    if (minSelection == maxSelection) {
      finalText = textBefore.substring(0, (minSelection - 1).clampMin(0)) + textAfter;
    } else {
      finalText = textBefore + textAfter;
    }
    editorState.editTextController.text = finalText;
    editorState.editTextController.selection = TextSelection.fromPosition(
      TextPosition(offset: finalText.length - textAfter.length),
    );
    editorState.textEditFocus.requestFocus();
  }

  void keyDelete() {
    final selection = editorState.editTextController.selection;
    final minSelection = min(selection.baseOffset, selection.extentOffset);
    final maxSelection = max(selection.baseOffset, selection.extentOffset);
    final textBefore = editorState.editTextController.text.substring(0, minSelection);
    final textAfter = editorState.editTextController.text.substring(maxSelection);

    String finalText;
    if (minSelection == maxSelection && textAfter.isNotEmpty) {
      finalText = textBefore + textAfter.substring(1);
    } else {
      finalText = textBefore + textAfter;
    }
    editorState.editTextController.text = finalText;
    editorState.editTextController.selection = TextSelection.fromPosition(
      TextPosition(offset: textBefore.length),
    );
    editorState.textEditFocus.requestFocus();
  }

  void toggleNumericKeyboard() {
    editorState.numericKeyboard = !editorState.numericKeyboard;
    editorState.notify();
  }
}
