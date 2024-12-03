class Payment {
  int id;
  String dateDebut;
  String dateFin;
  String? datePaiement;
  double montant;
  double reste;
  int? retardPaiement;
  String statutAdherent;

  Payment({
    required this.id,
    required this.dateDebut,
    required this.dateFin,
    this.datePaiement,
    required this.montant,
    required this.reste,
    this.retardPaiement,
    required this.statutAdherent,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      dateDebut: json['dateDebut'],
      dateFin: json['dateFin'],
      datePaiement: json['datePaiement'],
      montant: json['montant'],
      reste: json['reste'],
      retardPaiement: json['retardPaiement'],
      statutAdherent: json['statutAdherent'],
    );
  }
}
