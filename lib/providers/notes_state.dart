import 'package:equatable/equatable.dart';
import 'package:riverpodcrud/models/note.dart';

abstract class NotesState extends Equatable {
  NotesState();
}

class NotesInitial extends NotesState {
  NotesInitial();

  @override
  List<Object?> get props => [];
}

class NotesLoading extends NotesState {
  NotesLoading();

  @override
  List<Object?> get props => [];
}

class NotesLoaded extends NotesState {
  NotesLoaded({
    this.notes,
  });

  final List<Note>? notes;

  @override
  List<Object?> get props => [notes];
}

class NotesEmpty extends NotesState {
  NotesEmpty();

  @override
  List<Object?> get props => [];
}

class NotesFailure extends NotesState {
  NotesFailure();

  @override
  List<Object?> get props => [];
}

class NotesValidating extends NotesState {
  NotesValidating({
    this.note,
    this.tituloMessage,
    this.conteudoMessage,
  });

  final Note? note;
  final String? tituloMessage;
  final String? conteudoMessage;

  @override
  List<Object?> get props => [tituloMessage, conteudoMessage];
}

class NotesValidated extends NotesState {
  NotesValidated({
    this.note,
  });

  final Note? note;

  @override
  List<Object?> get props => [note];
}

class NotesSuccess extends NotesState {
  NotesSuccess();

  @override
  List<Object?> get props => [];
}
