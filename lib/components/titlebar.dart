import 'package:flutter/material.dart';

class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: 5,
      child: Container(
        height: 80,
        alignment: Alignment.center,
        color: theme.colorScheme.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(Icons.arrow_back),
              Icon(Icons.save),
              Expanded(
                child: Text('Title'),
              ),
              Icon(Icons.more_vert),
            ],
          ),
        ),
      ),
    );
  }
}