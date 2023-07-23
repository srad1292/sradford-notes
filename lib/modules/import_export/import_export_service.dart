import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sradford_notes/modules/import_export/widgets/email_request_dialog.dart';
import 'package:sradford_notes/modules/note/note_service.dart';
import 'package:sradford_notes/modules/shared/enum/info_dialog_type.dart';
import 'package:sradford_notes/modules/shared/widgets/my_info_dialog.dart';
import 'package:sradford_notes/utils/service_locator.dart';

import '../note/note.dart';
import '../shared/class/result.dart';

class ImportExportService {

  ImportExportService();


  Future<Result> ExportNotes({required BuildContext context, required List<int> noteIds}) async {
    Result result = new Result(succeeded: false, showedDialog: false, dataCount: -1);
    NoteService noteService = serviceLocator.get<NoteService>();
    try {
      // Get notes to export
      List<Note>? notes = await noteService.getSelectedNotes(noteIds: noteIds);
      if(notes == null) { return result; }
      // Create json file using notes
      File? exportFile = await _createExportFile(notes);
      if(exportFile == null) {
        await showMyInfoDialog(context: context, dialogType: InfoDialogType.Warning, body: "Unable to create backup file.");
        result.showedDialog = true;
        return result;
      }
      // Ask for email to send to
      String recipient = await _getRecipientEmail(context);
      if(recipient.isEmpty) {
        await showMyInfoDialog(context: context, dialogType: InfoDialogType.Warning, body: "Must provide a valid email");
        result.showedDialog = true;
        return result;
      }
      // Try to send email
      bool sentEmail = await _sendEmail(exportFile, recipient);
      if(!sentEmail) {
        await showMyInfoDialog(context: context, dialogType: InfoDialogType.Warning, body: "Could not find app to send email through.");
        result.showedDialog = true;
        return result;
      }
      // Return successfully
      result.succeeded = true;
      result.dataCount = notes.length;
      return result;
    } catch(e) {
      print("Export notes error");
      print(e.toString());
      return result;
    }
  }

  Future<File?> _createExportFile(List<Note> data) async {
    try {
      Directory? directory = await getExternalStorageDirectory();
      if ((await directory?.exists() ?? false) == false) {
        return null;
      }
      
      return File("${directory?.path}/sradford-notes-backup.json");
    } on Exception catch (e) {
      print("CreateExportFile error: ");
      print(e.toString());
      return null;
    }
  }

  Future<String> _getRecipientEmail(BuildContext context) async {
    try {
      String? recipient = await showEmailAddressDialog(context: context);
      return (recipient ?? '').trim();
    } on Exception catch (e) {
      print("Get recipient email failed");
      print(e.toString());
      return '';
    }
  }

  Future<bool> _sendEmail(File file, String recipient) async {
    final Email email = Email(
      body: 'You have received these notes exported from sradford-notes',
      subject: 'SradfordNotes backup',
      recipients: [recipient ?? ''],
      cc: [],
      bcc: [],
      attachmentPaths: [file.path],
      isHTML: false,
    );
    try {
      await FlutterEmailSender.send(email);
      return true;
    } catch (e) {
      return false;
    }
  }
}