import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpodcrud/models/note.dart';
import 'package:riverpodcrud/providers/notes_provider.dart';
import 'package:riverpodcrud/providers/notes_state.dart';
import 'package:riverpodcrud/views/note_edit.dart';

class NoteListPage extends StatelessWidget {
  const NoteListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DocumentosView();
  }
}

class DocumentosView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riverpod SQLite Crud'),
        actions: <Widget>[
          Consumer(builder: (context, ref, _) {
            // desativar o botao de excluir todas as notas se nao ha notas
            if (state is NotesEmpty) {
              return IconButton(
                onPressed: null,
                icon: Icon(Icons.clear_all),
              );
            } else {
              return IconButton(
                icon: Icon(Icons.clear_all),
                onPressed: () {
                  // excluir todas as notas
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Excluir Todas as Notas'),
                      content: const Text('Confirmar operação?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            ref.read(notesProvider.notifier).excluirNotas();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(const SnackBar(
                                content: Text('Notas excluídas com sucesso'),
                              ));
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          }),
        ],
      ),
      body: _Content(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NoteEditPage(note: null)),
          );
        },
      ),
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notesProvider);
    if (state is NotesInitial) {
      return SizedBox();
    } else if (state is NotesLoading) {
      return Center(child: const CircularProgressIndicator());
    } else if (state is NotesEmpty) {
      return const Center(
        child: Text('Não há notas. Clique no botão abaixo para cadastrar.'),
      );
    } else if (state is NotesLoaded) {
      return _NotesList(state.notes);
    } else {
      return Text('Erro ao buscar notas.');
    }
  }
}

class _NotesList extends StatelessWidget {
  const _NotesList(
    List<Note>? this.notes, {
    Key? key,
  }) : super(key: key);
  final notes;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (final note in notes) ...[
          Padding(
            padding: const EdgeInsets.all(2.5),
            child: ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              title: Text(note.title),
              subtitle: Text(
                '${note.content}',
              ),
              trailing: Wrap(children: <Widget>[
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NoteEditPage(note: note)),
                    );
                  },
                ),
                IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      // excluir nota atraves do id
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Excluir Nota'),
                          content: const Text('Confirmar operação?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                            Consumer(builder: (context, ref, _) {
                              return TextButton(
                                onPressed: () {
                                  ref
                                      .read(notesProvider.notifier)
                                      .excluirNota(note.id);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(const SnackBar(
                                      content:
                                          Text('Nota excluída com sucesso'),
                                    ));
                                },
                                child: const Text('OK'),
                              );
                            }),
                          ],
                        ),
                      );
                    }),
              ]),
            ),
          ),
        ],
      ],
    );
  }
}
