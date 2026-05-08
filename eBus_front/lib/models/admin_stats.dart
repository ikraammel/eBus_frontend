class AdminStatsModel {
  final int totalUtilisateurs;
  final int nouveauxCeMois;
  final int dossiersEnAttente;
  final int dossiersValides;
  final int dossiersRejetes;

  final int abonnementsActifs;
  final int abonnementsEnAttente;
  final int abonnementsExpires;
  final double revenuTotalAbonnements;

  final int totalTickets;
  final double revenuTickets;

  final int reclamationsTotal;
  final int reclamationsOuvertes;
  final int reclamationsResolues;

  final int objetsPerdusTotal;

  final int totalBus;
  final int busActifs;
  final int totalLignes;

  final List<MonthlyCountModel> inscriptionsParMois;
  final Map<String, int> abonnementsParType;
  final Map<String, int> reclamationsParStatut;

  const AdminStatsModel({
    required this.totalUtilisateurs,
    required this.nouveauxCeMois,
    required this.dossiersEnAttente,
    required this.dossiersValides,
    required this.dossiersRejetes,
    required this.abonnementsActifs,
    required this.abonnementsEnAttente,
    required this.abonnementsExpires,
    required this.revenuTotalAbonnements,
    required this.totalTickets,
    required this.revenuTickets,
    required this.reclamationsTotal,
    required this.reclamationsOuvertes,
    required this.reclamationsResolues,
    required this.objetsPerdusTotal,
    required this.totalBus,
    required this.busActifs,
    required this.totalLignes,
    required this.inscriptionsParMois,
    required this.abonnementsParType,
    required this.reclamationsParStatut,
  });

  double get revenuTotal => revenuTotalAbonnements + revenuTickets;

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatsModel(
      totalUtilisateurs:      (json['totalUtilisateurs']      as num?)?.toInt() ?? 0,
      nouveauxCeMois:         (json['nouveauxCeMois']         as num?)?.toInt() ?? 0,
      dossiersEnAttente:      (json['dossiersEnAttente']      as num?)?.toInt() ?? 0,
      dossiersValides:        (json['dossiersValides']        as num?)?.toInt() ?? 0,
      dossiersRejetes:        (json['dossiersRejetes']        as num?)?.toInt() ?? 0,
      abonnementsActifs:      (json['abonnementsActifs']      as num?)?.toInt() ?? 0,
      abonnementsEnAttente:   (json['abonnementsEnAttente']   as num?)?.toInt() ?? 0,
      abonnementsExpires:     (json['abonnementsExpires']     as num?)?.toInt() ?? 0,
      revenuTotalAbonnements: (json['revenuTotalAbonnements'] as num?)?.toDouble() ?? 0.0,
      totalTickets:           (json['totalTickets']           as num?)?.toInt() ?? 0,
      revenuTickets:          (json['revenuTickets']          as num?)?.toDouble() ?? 0.0,
      reclamationsTotal:      (json['reclamationsTotal']      as num?)?.toInt() ?? 0,
      reclamationsOuvertes:   (json['reclamationsOuvertes']   as num?)?.toInt() ?? 0,
      reclamationsResolues:   (json['reclamationsResolues']   as num?)?.toInt() ?? 0,
      objetsPerdusTotal:      (json['objetsPerdusTotal']      as num?)?.toInt() ?? 0,
      totalBus:               (json['totalBus']               as num?)?.toInt() ?? 0,
      busActifs:              (json['busActifs']              as num?)?.toInt() ?? 0,
      totalLignes:            (json['totalLignes']            as num?)?.toInt() ?? 0,
      inscriptionsParMois: (json['inscriptionsParMois'] as List? ?? [])
          .map((e) => MonthlyCountModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      abonnementsParType: (json['abonnementsParType'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, (v as num).toInt())),
      reclamationsParStatut: (json['reclamationsParStatut'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, (v as num).toInt())),
    );
  }
}

class MonthlyCountModel {
  final String mois;
  final int count;
  const MonthlyCountModel({required this.mois, required this.count});

  factory MonthlyCountModel.fromJson(Map<String, dynamic> json) => MonthlyCountModel(
    mois:  json['mois']  as String? ?? '',
    count: (json['count'] as num?)?.toInt() ?? 0,
  );
}