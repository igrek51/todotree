import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todotree/services/settings_provider.dart';
import 'package:todotree/util/collections.dart';
import 'package:todotree/util/display.dart';

import 'package:todotree/util/errors.dart';
import 'package:todotree/services/tree_traverser.dart';
import 'package:todotree/model/tree_node.dart';
import 'package:todotree/views/components/ripple_indicator.dart';
import 'package:todotree/views/components/rounded_badge.dart';
import 'package:todotree/views/tree_browser/browser_controller.dart';
import 'package:todotree/views/tree_browser/browser_state.dart';
import 'package:todotree/views/tree_browser/tree_item.dart';

const double _iconButtonInternalSize = 24;
const double _reoderButtonPaddingH = 12;
const double _moreButtonPaddingH = 11;
const double _midButtonPaddingH = 4;
const double _addButtonPaddingH = 4;

class TreeItemRow extends StatelessWidget {
  const TreeItemRow({
    super.key,
    required this.position,
    required this.treeItem,
    required this.rippleIndicatorKey,
    required this.iconButtonPaddingV,
  });

  final int position;
  final TreeNode treeItem;
  final GlobalKey<RippleIndicatorState> rippleIndicatorKey;
  final double iconButtonPaddingV;

  @override
  Widget build(BuildContext context) {
    final browserState = context.watch<BrowserState>();
    final selectionMode = browserState.selectedIndexes.isNotEmpty;
    final isItemSelected = browserState.selectedIndexes.contains(position);
    final browserController = Provider.of<BrowserController>(context, listen: false);

    return Row(
      children: [
        buildLeftIcon(selectionMode, isItemSelected, browserController),
        buildMiddleText(context),
        selectionMode ? null : buildAltActionButton(context, browserController),
        selectionMode ? null : buildAddButton(browserController),
        buildMoreActionButton(context),
      ].filterNotNull(),
    );
  }

  Widget buildLeftIcon(bool selectionMode, bool isItemSelected, BrowserController browserController) {
    if (selectionMode) {
      Widget sizedBoxChild = GestureDetector(
        onLongPress: () {
          safeExecute(() {
            browserController.onLongToggleSelectedNode(position);
          });
        },
        child: Checkbox(
          value: isItemSelected,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onChanged: (bool? value) {
            safeExecute(() {
              browserController.onToggleSelectedNode(position);
            });
          },
        ),
      );
      if (isItemSelected) {
        sizedBoxChild = ReorderableDragStartListener(
          index: position,
          child: sizedBoxChild,
        );
      }
      return SizedBox(
        width: 48,
        child: sizedBoxChild,
      );
    } else {
      return ReorderableDragStartListener(
        index: position,
        child: GestureDetector(
          onLongPress: () {
            safeExecute(() {
              browserController.onToggleSelectedNode(position);
            });
          },
          child: IconButton(
            icon: const Icon(
              Icons.unfold_more,
              size: _iconButtonInternalSize,
              color: Colors.white,
            ),
            padding: EdgeInsets.symmetric(vertical: iconButtonPaddingV, horizontal: _reoderButtonPaddingH),
            constraints: BoxConstraints(),
            style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            onPressed: () {
              safeExecute(() {
                browserController.onToggleSelectedNode(position);
              });
            },
          ),
        ),
      );
    }
  }

  Widget buildMiddleText(BuildContext context) {
    final treeTraverser = Provider.of<TreeTraverser>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final fontSize = switch (settingsProvider.largeFont) {
      true => 18.0,
      false => 16.0,
    };
    final padding = switch (settingsProvider.largeFont) {
      true => const EdgeInsets.symmetric(vertical: 10),
      false => const EdgeInsets.symmetric(vertical: 8),
    };
    final child = switch (true) {
      true when treeItem.isLink => Container(
          padding: padding,
          child: Text(
            treeTraverser.displayLinkName(treeItem),
            style: TextStyle(
              color: Color(0xFFD2D2D2),
              fontSize: fontSize,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      true when treeItem.isLeaf => Container(
          padding: padding,
          child: Text(
            treeItem.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
            ),
          ),
        ),
      _ => Row(
          children: [
            Expanded(
              child: Container(
                padding: padding,
                child: Text(
                  treeItem.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 2),
            RoundedBadge(text: treeItem.size.toString()),
          ],
        )
    };
    return Expanded(child: child);
  }

  Widget buildMoreActionButton(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.more_vert,
        size: _iconButtonInternalSize,
        color: Colors.white,
      ),
      padding: EdgeInsets.symmetric(vertical: iconButtonPaddingV, horizontal: _moreButtonPaddingH),
      constraints: BoxConstraints(),
      style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
      onPressed: () {
        showNodeOptionsDialog(context, treeItem, position);
        var (_, centerY, w, _) = getRenderBoxCoordinates(context);
        final xOffset = w - _moreButtonPaddingH - _iconButtonInternalSize / 2;
        rippleIndicatorKey.currentState?.animate(xOffset, centerY);
      },
    );
  }

  Widget buildAltActionButton(BuildContext context, BrowserController browserController) {
    if (treeItem.isLeaf) {
      return Tooltip(
        message: 'Go inside',
        child: IconButton(
          icon: const Icon(
            Icons.arrow_right,
            size: _iconButtonInternalSize,
            color: Colors.white,
          ),
          padding: EdgeInsets.symmetric(vertical: iconButtonPaddingV, horizontal: _midButtonPaddingH),
          constraints: BoxConstraints(),
          style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          onPressed: () {
            safeExecute(() async {
              var (_, centerY, w, _) = getRenderBoxCoordinates(context);
              await browserController.goIntoNode(treeItem);
              final xOffset = w -
                  _moreButtonPaddingH * 2 -
                  _addButtonPaddingH * 2 -
                  _midButtonPaddingH -
                  _iconButtonInternalSize * 2.5;
              rippleIndicatorKey.currentState?.animate(xOffset, centerY);
            });
          },
        ),
      );
    } else {
      return Tooltip(
        message: 'Edit',
        child: IconButton(
          icon: const Icon(
            Icons.edit,
            size: _iconButtonInternalSize,
            color: Colors.white,
          ),
          padding: EdgeInsets.symmetric(vertical: iconButtonPaddingV, horizontal: _midButtonPaddingH),
          constraints: BoxConstraints(),
          style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          onPressed: () {
            safeExecute(() {
              browserController.editNode(treeItem);
            });
          },
        ),
      );
    }
  }

  Widget buildAddButton(BrowserController browserController) {
    return Tooltip(
      message: 'Add above',
      child: IconButton(
        icon: const Icon(
          Icons.add,
          size: _iconButtonInternalSize,
          color: Colors.white,
        ),
        padding: EdgeInsets.symmetric(vertical: iconButtonPaddingV, horizontal: _addButtonPaddingH),
        constraints: BoxConstraints(),
        style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
        onPressed: () {
          safeExecute(() {
            browserController.addNodeAt(position);
          });
        },
      ),
    );
  }
}