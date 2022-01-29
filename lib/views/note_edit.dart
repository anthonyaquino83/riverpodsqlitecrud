import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpodcrud/models/note.dart';
import 'package:riverpodcrud/providers/notes_provider.dart';
import 'package:riverpodcrud/providers/notes_state.dart';
import 'package:riverpodcrud/providers/validator_provider.dart';
import 'package:riverpodcrud/providers/validator_state.dart';

class NoteEditPage extends StatelessWidget {
  const NoteEditPage({Key? key, this.note}) : super(key: key);
  final Note? note;
  @override
  Widget build(BuildContext context) {
    return NotesEditView(note);
  }
}

class NotesEditView extends ConsumerWidget {
  NotesEditView(
    this.note, {
    Key? key,
  }) : super(key: key);
  final Note? note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<NotesState>(notesProvider,
        (NotesState? previousState, NotesState state) {
      if (state is NotesLoading) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            });
      }
      if (state is NotesSuccess) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(
            content: Text('Operação realizada com sucesso'),
          ));
        // apos a nota ser salva, as notas sao recuperadas novamente e
        // o aplicativo apresenta novamenta a tela de lista de notas
        Navigator.pop(context);
        ref.read(notesProvider.notifier).buscarNotas();
        Navigator.pop(context);
      }
      if (state is NotesFailure) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(
            content: Text('Erro ao atualizar nota'),
          ));
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Nota'),
      ),
      body: _Content(note),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content(this.note, {Key? key}) : super(key: key);
  final Note? note;
  @override
  Widget build(BuildContext context) {
    return _NoteForm(note);
  }
}

class _NoteForm extends StatelessWidget {
  _NoteForm(this.note, {Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();
  final Note? note;
  @override
  Widget build(BuildContext context) {
    if (note == null) {
      _titleController.text = '';
      _contentController.text = '';
    } else {
      _titleController.text = note!.title.toString();
      _contentController.text = note!.content.toString();
    }
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Consumer(builder: (context, ref, child) {
              final state = ref.watch(validatorProvider);
              return TextFormField(
                decoration: InputDecoration(
                  labelText: 'Título',
                ),
                controller: _titleController,
                focusNode: _titleFocusNode,
                textInputAction: TextInputAction.next,
                onEditingComplete: _contentFocusNode.requestFocus,
                onChanged: (text) {
                  ref.read(validatorProvider.notifier).validaForm(
                      _titleController.text, _contentController.text);
                },
                onFieldSubmitted: (String value) {},
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (state is Validating) {
                    if (state.tituloMessage == '') {
                      return null;
                    } else {
                      return state.tituloMessage;
                    }
                  }
                },
              );
            }),
            Consumer(builder: (context, ref, child) {
              final state = ref.watch(validatorProvider);
              return TextFormField(
                decoration: InputDecoration(
                  labelText: 'Conteúdo',
                ),
                controller: _contentController,
                focusNode: _contentFocusNode,
                textInputAction: TextInputAction.done,
                onChanged: (text) {
                  ref.read(validatorProvider.notifier).validaForm(
                      _titleController.text, _contentController.text);
                },
                onFieldSubmitted: (String value) {
                  if (_formKey.currentState!.validate()) {
                    //fechar teclado
                    FocusScope.of(context).unfocus();
                    ref.read(notesProvider.notifier).salvarNota(note?.id,
                        _titleController.text, _contentController.text);
                  }
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (state is Validating) {
                    if (state.conteudoMessage == '') {
                      return null;
                    } else {
                      return state.conteudoMessage;
                    }
                  }
                },
              );
            }),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: Consumer(builder: (context, ref, child) {
                  final state = ref.watch(validatorProvider);
                  return ElevatedButton(
                    onPressed: state is Validated
                        ? () {
                            if (_formKey.currentState!.validate()) {
                              //fechar teclado
                              FocusScope.of(context).unfocus();
                              ref.read(notesProvider.notifier).salvarNota(
                                  note?.id,
                                  _titleController.text,
                                  _contentController.text);
                            }
                          }
                        : null,
                    child: Text('Salvar'),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
