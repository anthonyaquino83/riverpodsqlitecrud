import 'package:riverpodcrud/models/note.dart';

abstract class NotesState {
  NotesState();
}

class NotesInitial extends NotesState {
  NotesInitial();
}

class NotesLoading extends NotesState {
  NotesLoading();
}

class NotesLoaded extends NotesState {
  NotesLoaded({
    this.notes,
  });

  final List<Note>? notes;
}

class NotesEmpty extends NotesState {
  NotesEmpty();
}

class NotesFailure extends NotesState {
  NotesFailure();
}

class NotesSuccess extends NotesState {
  NotesSuccess();
}
