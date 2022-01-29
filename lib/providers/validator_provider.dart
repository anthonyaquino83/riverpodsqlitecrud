import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpodcrud/providers/validator_state.dart';

final validatorProvider =
    StateNotifierProvider<ValidatorNotifier, ValidatorState>(
        (ref) => ValidatorNotifier());

class ValidatorNotifier extends StateNotifier<ValidatorState> {
  ValidatorNotifier() : super(Validating()) {}

  void validaForm(String titulo, String conteudo) {
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
      state = Validating(
        tituloMessage: stateTituloMessage,
        conteudoMessage: stateConteudoMessage,
      );
    } else {
      state = Validated();
    }
  }
}
