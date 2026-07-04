class PriceGroupOption {
  final int id;
  final String name;

  PriceGroupOption({required this.id, required this.name});

  factory PriceGroupOption.fromMap(Map<String, dynamic> map) {
    return PriceGroupOption(
      id: map['id'] as int,
      name: map['name'] as String,
    );
  }
}
