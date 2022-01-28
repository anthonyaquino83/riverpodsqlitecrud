import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpodcrud/db/database_provider.dart';
import 'package:riverpodcrud/models/note.dart';
import 'package:riverpodcrud/providers/notes_state.dart';

final databaseProvider = Provider((ref) => DatabaseProvider.instance);

final notesProvider = StateNotifierProvider<NotesNotifier, NotesState>(
    (ref) => NotesNotifier(ref));

class NotesNotifier extends StateNotifier<NotesState> {
  NotesNotifier(this.ref)
      : _databaseProvider = ref.watch(databaseProvider),
        super(NotesInitial()) {
    buscarNotas();
  }
  final Ref ref;
  final DatabaseProvider _databaseProvider;

  Future<void> buscarNotas() async {
    state = NotesLoading();
    try {
      // a linha abaixo simula tempo de processamento no servidor e
      // serve para testar o circular indicator
      await Future.delayed(const Duration(seconds: 2));

      final notes = await _databaseProvider.buscarNotas();
      if (notes.isEmpty) {
        state = NotesEmpty();
      } else {
        state = NotesLoaded(
          notes: notes,
        );
      }
    } catch (e) {
      state = NotesFailure();
      throw Exception();
    }
  }

  void validaForm(String titulo, String conteudo) {
    Note editNote = Note(title: titulo, content: conteudo);
    String stateTituloMessage = '';
    String stateConteudoMessage = '';
    bool formInvalid;

    formInvalid = false;
    if (titulo == '') {
      formInvalid = true;
      stateTituloMessage = 'Preencha o título';
    } else {
      stateTituloMessage = '';
    }
    if (conteudo == '') {
      formInvalid = true;
      stateConteudoMessage = 'Preencha o conteúdo';
    } else {
      stateConteudoMessage = '';
    }

    if (formInvalid == true) {
      state = NotesValidating(
        note: editNote,
        tituloMessage: stateTituloMessage,
        conteudoMessage: stateConteudoMessage,
      );
    } else {
      state = NotesValidated(
        note: editNote,
      );
    }
  }

  Future<void> salvarNota(int? id, String titulo, String conteudo) async {
    Note editNote = Note(id: id, title: titulo, content: conteudo);
    state = NotesLoading();
    try {
      // a linha abaixo simula tempo de processamento no servidor e
      // serve para testar o circular indicator
      await Future.delayed(const Duration(seconds: 2));
      if (id == null) {
        editNote = await _databaseProvider.save(editNote);
      } else {
        editNote = await _databaseProvider.update(editNote);
      }
      state = NotesSuccess();
    } on Exception {
      state = NotesFailure();
    }
  }

  //excluir nota atraves um id
  Future<void> excluirNota(id) async {
    state = NotesLoading();
    // a linha abaixo simula tempo de processamento no servidor e
    // serve para testar o circular indicator
    await Future.delayed(const Duration(seconds: 2));
    try {
      await _databaseProvider.delete(id);
      buscarNotas();
    } on Exception {
      state = NotesFailure();
    }
  }

  //excluir todas as notas
  Future<void> excluirNotas() async {
    state = NotesLoading();
    // a linha abaixo simula tempo de processamento no servidor e
    // serve para testar o circular indicator
    await Future.delayed(const Duration(seconds: 2));
    try {
      await _databaseProvider.deleteAll();
      state = NotesEmpty();
    } on Exception {
      state = NotesFailure();
    }
  }
}
