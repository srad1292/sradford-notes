import 'package:flutter/material.dart';

Future<bool> showMyConfirmationDialog({required BuildContext context, required String body}) async {
  Widget dialog = _confirmationDialog(context, body);
  print("I created a confirmation dialog");
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        print("Showing dialog");
        return dialog;
      },
      barrierDismissible: false
  )
  .then((value) {
    return value == true;
  });
}

Widget cancelButton(BuildContext context) {
  return TextButton(
    child: Text(
      "Cancel",
      style: TextStyle(
        color: Colors.redAccent,
        // fontWeight: FontWeight.w500,
        // fontSize: 2.2 * SizeConfig.textMultiplier
      ),
    ),
    onPressed: () {
      Navigator.of(context).pop(false);
    },
  );
}

Widget confirmButton(BuildContext context) {
  return TextButton(
    child: Text(
      "Confirm",
    ),
    onPressed: () {
      Navigator.of(context).pop(true);
    },
  );
}

Widget _confirmationDialog(BuildContext context, String body) {
  return AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    // backgroundColor: stmGradientEnd,
    title: Text(
      "Confirmation",
      style: TextStyle(
        color: Colors.black87
      ),
    ),
    content: Text(body),
    actions: [cancelButton(context), confirmButton(context)],
  );
}