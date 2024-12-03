class Performance {
  final int? id;
  final int? testId;
  final String? evalName;

  Performance({
    this.id,
    this.testId,
    this.evalName,
  });

  factory Performance.fromJson(Map<String, dynamic> json) {
    return Performance(
      id: json['id'],
      testId: json['testId'],
      evalName: json['evalName'],
    );
  }
}

class InformationsSportives {
  final int? id;
  final int totalSession;
  final int totalPresence;
  final Set<Performance>? performances;

  InformationsSportives({
    this.id,
    required this.totalSession,
    required this.totalPresence,
    this.performances,
  });

  factory InformationsSportives.fromJson(Map<String, dynamic> json) {
    return InformationsSportives(
      id: json['id'],
      totalSession: json['totalSession'],
      totalPresence: json['totalPresence'],
      performances: json['performances'] != null
          ? (json['performances'] as List)
              .map((performance) => Performance.fromJson(performance))
              .toSet()
          : {},
    );
  }
}
