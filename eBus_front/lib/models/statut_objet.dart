
enum StatutObjet {
  DISPONIBLE('Disponible'),
  RECUPERE('Récupéré'),
  EN_ATTENTE('En attente'),
  EN_ATTENTE_RECUPERATION('Signalé récupéré');

  final String label;
  const StatutObjet(this.label);
}
extension StatutObjetExt on StatutObjet {

  bool get isDisponible => this == StatutObjet.DISPONIBLE;
  bool get isRecupere => this == StatutObjet.RECUPERE;
  bool get isEnAttente => this == StatutObjet.EN_ATTENTE;
}
