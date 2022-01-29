abstract class ValidatorState {
  ValidatorState();
}

class Validating extends ValidatorState {
  Validating({
    this.tituloMessage,
    this.conteudoMessage,
  });

  final String? tituloMessage;
  final String? conteudoMessage;
}

class Validated extends ValidatorState {
  Validated();
}
