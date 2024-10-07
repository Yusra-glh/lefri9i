class Discipline {
  final int id;
  final String nom;
  final String? description;
  final bool protectedDiscipline;
  final int? academieId;

  Discipline({
    required this.id,
    required this.nom,
    this.description,
    required this.protectedDiscipline,
    this.academieId,
  });

  factory Discipline.fromJson(Map<String, dynamic> json) {
    return Discipline(
      id: json['id'],
      nom: json['nom'],
      description: json['description'],
      protectedDiscipline: json['protectedDiscipline'],
      academieId: json['academieId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'protectedDiscipline': protectedDiscipline,
      'academieId': academieId,
    };
  }
}
