import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todotree/settings/settings_provider.dart';
import 'package:todotree/util/collections.dart';
import 'package:todotree/util/display.dart';

import 'package:todotree/util/errors.dart';
import 'package:todotree/services/tree_traverser.dart';
import 'package:todotree/node_model/tree_node.dart';
import 'package:todotree/components/ripple_indicator.dart';
import 'package:todotree/components/rounded_badge.dart';
import 'package:todotree/tree_browser/browser_controller.dart';
import 'package:todotree/tree_browser/browser_state.dart';

const double _iconButtonInternalSize = 24;
const double _reoderButtonPaddingH = 12;
const double _moreButtonPaddingH = 14;
const double _altButtonPaddingH = 10;
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
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final browserState = context.watch<BrowserState>();
    final selectionMode = browserState.selectedIndexes.isNotEmpty;
    final isItemSelected = browserState.selectedIndexes.contains(position);
    final browserController = Provider.of<BrowserController>(context, listen: false);
    final showAlt = settingsProvider.showAltNodeButton && !selectionMode;
    final showAdd = settingsProvider.showAddNodeButton && !selectionMode;

    return Row(
      children: [
        buildLeftIcon(selectionMode, isItemSelected, browserController),
        buildMiddleText(context),
        showAlt ? buildAltActionButton(context, browserController) : null,
        showAdd ? buildAddButton(browserController) : null,
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
    final textStyle = switch (true) {
      true when treeItem.isLink => TextStyle(
          color: Color(0xFFD2D2D2),
          fontSize: fontSize,
          decoration: TextDecoration.underline,
        ),
      true when !treeItem.isLeaf => TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      _ => TextStyle(
          color: Colors.white,
          fontSize: fontSize,
        ),
    };
    String textContent = switch (treeItem.isLink) {
      true => treeTraverser.displayLinkName(treeItem),
      false => treeItem.name,
    };
    Container textContainer = Container(
      padding: padding,
      child: Text(
        textContent,
        style: textStyle,
      ),
    );
    int childrenSize = switch (treeItem.isLink) {
      true => treeTraverser.linkChildrenSize(treeItem),
      false => treeItem.size,
    };
    final child = switch (true) {
      true when childrenSize == 0 => textContainer,
      _ => Row(
          children: [
            Expanded(child: textContainer),
            SizedBox(width: 2),
            RoundedBadge(text: childrenSize.toString()),
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
        final browserController = Provider.of<BrowserController>(context, listen: false);
        safeExecute(() {
          browserController.showItemOptionsDialog(treeItem, position);
        });
        var (_, centerY, w, _) = getRenderBoxCoordinates(context);
        final xOffset = w - _moreButtonPaddingH - _iconButtonInternalSize / 2;
        rippleIndicatorKey.currentState?.animate(xOffset, centerY);
      },
    );
  }

  Widget buildAltActionButton(BuildContext context, BrowserController browserController) {
    String tooltipMessage = switch (treeItem.isLeaf) {
      true => 'Go inside',
      false => 'Edit',
    };
    Icon icon = switch (treeItem.isLeaf) {
      true => const Icon(
          Icons.arrow_right,
          size: _iconButtonInternalSize,
          color: Colors.white,
        ),
      false => const Icon(
          Icons.edit,
          size: _iconButtonInternalSize,
          color: Colors.white,
        ),
    };
    final onPressed = switch (treeItem.isLeaf) {
      true => () async {
          var (_, centerY, w, _) = getRenderBoxCoordinates(context);
          await browserController.goIntoNode(treeItem);
          final xOffset =
              w - _moreButtonPaddingH * 2 - _addButtonPaddingH * 2 - _altButtonPaddingH - _iconButtonInternalSize * 2.5;
          rippleIndicatorKey.currentState?.animate(xOffset, centerY);
        },
      false => () {
          browserController.editNode(treeItem);
        },
    };
    return Tooltip(
      message: tooltipMessage,
      child: IconButton(
        icon: icon,
        padding: EdgeInsets.symmetric(vertical: iconButtonPaddingV, horizontal: _altButtonPaddingH),
        constraints: BoxConstraints(),
        style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
        onPressed: () {
          safeExecute(onPressed);
        },
      ),
    );
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
