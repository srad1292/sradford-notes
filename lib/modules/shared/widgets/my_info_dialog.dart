import 'package:flutter/material.dart';
import 'package:sradford_notes/modules/shared/enum/info_dialog_type.dart';

Future<bool> showMyInfoDialog({required BuildContext context, required InfoDialogType dialogType, required String body}) async {
  Widget dialog = _confirmationDialog(context, dialogType, body);
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
      barrierDismissible: false
  )
      .then((value) {
    return value == true;
  });
}

Widget confirmButton(BuildContext context) {
  return TextButton(
    child: Text(
      "Okay",
    ),
    onPressed: () {
      Navigator.of(context).pop(true);
    },
  );
}

Widget _confirmationDialog(BuildContext context, InfoDialogType dialogType, String body) {
  return AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    // backgroundColor: stmGradientEnd,
    title: Text(
      _getTitleText(dialogType),
      style: TextStyle(
          color: Colors.black87
      ),
    ),
    content: Text(body),
    actions: [confirmButton(context)],
  );
}

String _getTitleText(InfoDialogType dialogType) {
  if(dialogType == InfoDialogType.Info) {
    return "Info";
  } else if(dialogType == InfoDialogType.Warning) {
    return "Warning";
  } else if(dialogType == InfoDialogType.Error) {
    return "Error";
  }
  return '';
}