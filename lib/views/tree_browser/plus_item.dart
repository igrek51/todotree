import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todotree/services/settings_provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:swipe_to/swipe_to.dart';

import 'package:todotree/util/errors.dart';
import 'package:todotree/services/tree_traverser.dart';
import 'package:todotree/services/node_menu_dialog.dart';
import 'package:todotree/views/tree_browser/browser_controller.dart';

class PlusItemWidget extends StatelessWidget {
  const PlusItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final browserController = Provider.of<BrowserController>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final inkwell = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          safeExecute(() {
            browserController.addNodeToTheEnd();
          });
        },
        onLongPress: () {
          safeExecute(() {
            showMoreOptions(context);
          });
        },
        child: SizedBox(
          height: 55,
          child: Center(
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );

    if (settingsProvider.swipeNavigation) {
      return SwipeTo(
        key: UniqueKey(),
        iconOnLeftSwipe: Icons.arrow_back,
        onLeftSwipe: (details) {
          browserController.goBack();
        },
        swipeSensitivity: 5,
        child: inkwell,
      );
    } else if (settingsProvider.slidableActions) {
      return Slidable(
        groupTag: '0',
        key: ValueKey('plus'),
        endActionPane: ActionPane(
          motion: BehindMotion(),
          extentRatio: 0.25,
          openThreshold: 0.2,
          closeThreshold: 0.2,
          children: [
            SlidableAction(
              padding: EdgeInsets.zero,
              onPressed: (BuildContext context) {
                safeExecute(() {
                  showMoreOptions(context);
                });
              },
              backgroundColor: Color.fromARGB(255, 73, 115, 254),
              foregroundColor: Colors.white,
              icon: Icons.more_vert,
            ),
          ],
        ),
        child: inkwell,
      );
    }

    return inkwell;
  }

  void showMoreOptions(BuildContext context) {
    final browserController = Provider.of<BrowserController>(context, listen: false);
    final treeTraverser = Provider.of<TreeTraverser>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NodeMenuDialog.buildForPlus(context);
      },
    ).then((value) {
      if (value != null) {
        final plusPosition = treeTraverser.currentParent.size;
        browserController.runNodeMenuAction(value, position: plusPosition);
      }
    });
  }
}
