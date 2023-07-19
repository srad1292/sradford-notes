import 'package:get_it/get_it.dart';
import 'package:sradford_notes/modules/note/note_service.dart';

GetIt serviceLocator = GetIt.instance;

void setupServiceLocator() {
  serviceLocator.registerLazySingleton(() => NoteService());
}