import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
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


  Future<Result> exportNotes({required BuildContext context, required List<int> noteIds}) async {
    Result result = new Result(status: ResultStatus.failed, showedDialog: false, dataCount: -1);
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
        result.status = ResultStatus.cancelled;
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
      result.status = ResultStatus.succeeded;
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
      
      File file = File("${directory?.path}/sradford-notes-backup.json");
      await file.writeAsString(jsonEncode(data));
      return file;
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
      recipients: [recipient],
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

  Future<Result> importNotes({required BuildContext context}) async {
    Result result = new Result(status: ResultStatus.failed, showedDialog: false, dataCount: -1);

    try {
      // Select file
      List<File>? selectedFiles = await _selectBackupFile();
      if(selectedFiles == null) {
        await showMyInfoDialog(context: context, dialogType: InfoDialogType.Error, body: "File picker failed unexpectedly");
        result.showedDialog = true;
        return result;
      } else if(selectedFiles.isEmpty) {
        result.status = ResultStatus.cancelled;
        return result;
      } else if((selectedFiles[0].path).endsWith(".json") == false){
        await showMyInfoDialog(context: context, dialogType: InfoDialogType.Warning, body: "File extension should be .json");
        result.showedDialog = true;
        return result;
      }

      File file = selectedFiles.first;

      // parse file
      List<Note> notes = (await _parseSelectedFile(file) ?? []);
      if(notes.isEmpty) {
        await showMyInfoDialog(
          context: context,
          dialogType: InfoDialogType.Error,
          body: "Data in selected file is not proper format"
        );
        result.showedDialog = true;
        return result;
      }

      // Loop through notes and add each to db
      int savedCount = 0;

      NoteService noteService = serviceLocator.get<NoteService>();

      for(Note note in notes) {
        int insertedId = await noteService.addOrUpdateNote(note);
        if(insertedId > -1) {
          savedCount++;
        }
      }

      result.status = ResultStatus.succeeded;
      result.dataCount = savedCount;
      return result;
    } on Exception catch (e) {
      print("Error in ImportExportService Import Notes");
      print(e.toString());
      return result;
    }
  }

  Future<List<File>?> _selectBackupFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        List<File> files = result.paths.map((path) { return File(path ?? '');}).toList();
        return files;
      } else {
        // User canceled the picker
        return [];
      }
    } catch(e) {
      print("Import Export Service Select Backup File Error");
      print(e.toString());
      return null;
    }

  }

  Future<List<Note>?> _parseSelectedFile(File file) async {
    try {
      var fileData = await file.readAsString();
      List<Note> data = (jsonDecode(fileData) as List).map((e) => Note.fromJson(e)).toList();
      return data;
    } catch(e) {
      return null;
    }
  }
}