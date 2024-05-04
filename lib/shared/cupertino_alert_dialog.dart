import 'package:flutter/cupertino.dart';

// This shows a CupertinoModalPopup which hosts a CupertinoAlertDialog.
void _showCupertinoAlertDialog(BuildContext context) {
  showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: const Text(
          'Delete model will delete the all files with model config, and delete the entry in list. Clear model will keep the model config only, and keep the entry in list for future re-downloading.'),
      // content: ,
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          /// This parameter indicates this action is the default,
          /// and turns the action's text to bold text.
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context, "delete");
          },
          child: const Text('Delete Model'),
        ),
        CupertinoDialogAction(
          /// This parameter indicates the action would perform
          /// a destructive action such as deletion, and turns
          /// the action's text color to red.
          isDestructiveAction: false,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Clear Data'),
        ),
        CupertinoDialogAction(
          /// This parameter indicates the action would perform
          /// a destructive action such as deletion, and turns
          /// the action's text color to red.
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}
