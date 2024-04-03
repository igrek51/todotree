import 'package:flutter/material.dart';
import 'package:todotree/model/tree_node.dart';
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

  TreeTraverser treeTraverser;

  EditorController(this.homeState, this.editorState, this.treeTraverser);

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
    treeTraverser.addChildToCurrent(newNode,
        position: editorState.newItemPosition);
    browserController.renderItems();
    homeState.pageView = HomePageView.treeBrowser;
    homeState.notify();
    editorState.editTextController.clear();
    editorState.notify();
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
    final newPos =
        (currentPos + 1).clampMax(editorState.editTextController.text.length);
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
}
