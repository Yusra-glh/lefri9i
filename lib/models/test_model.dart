class Test {
  final int id;
  final String testName;
  final List<Category> categories;
  final DateTime creationDate;

  Test({
    required this.id,
    required this.testName,
    required this.categories,
    required this.creationDate,
  });

  factory Test.fromJson(Map<String, dynamic> json) {
    return Test(
      id: json['id'],
      testName: json['testName'],
      categories: (json['categories'] as List)
          .map((categoryJson) => Category.fromJson(categoryJson))
          .toList(),
      creationDate: DateTime.parse(json['creationDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'testName': testName,
      'categories': categories.map((category) => category.toJson()).toList(),
      'creationDate': creationDate.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Test{id: $id, categories: ${categories.map((c) => c.toString()).toList()}}';
  }
}

class Category {
  final int id;
  final String categorieName;
  final List<KPI> kpis;

  Category({
    required this.id,
    required this.categorieName,
    required this.kpis,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      categorieName: json['categorieName'],
      kpis: (json['kpis'] as List)
          .map((kpiJson) => KPI.fromJson(kpiJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categorieName': categorieName,
      'kpis': kpis.map((kpi) => kpi.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'Category{id: $id, categorieName: $categorieName, kpis: ${kpis.map((k) => k.toString()).toList()}}';
  }
}

class KPI {
  int id;
  String kpiType;
  int? value;
  String? comment;

  KPI({
    required this.id,
    required this.kpiType,
    this.value,
    this.comment,
  });

  factory KPI.fromJson(Map<String, dynamic> json) {
    return KPI(
      id: json['id'],
      kpiType: json['kpiType'],
      comment: json['comment'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kpiType': kpiType,
      'comment': comment,
      'value': value,
    };
  }

  @override
  String toString() {
    return 'KPI{id: $id ,kpiType: $kpiType, value: $value, comment: $comment}';
  }
}
