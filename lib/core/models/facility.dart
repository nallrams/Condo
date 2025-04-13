class Facility {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double hourlyRate;
  final int maxCapacity;
  final List<String> amenities;
  final List<String> rules;
  final Map<String, dynamic>? operatingHours;
  final bool isActive;

  Facility({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.hourlyRate,
    required this.maxCapacity,
    required this.amenities,
    required this.rules,
    this.operatingHours,
    this.isActive = true,
  });

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      hourlyRate: json['hourlyRate'].toDouble(),
      maxCapacity: json['maxCapacity'],
      amenities: List<String>.from(json['amenities']),
      rules: List<String>.from(json['rules']),
      operatingHours: json['operatingHours'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'hourlyRate': hourlyRate,
      'maxCapacity': maxCapacity,
      'amenities': amenities,
      'rules': rules,
      'operatingHours': operatingHours,
      'isActive': isActive,
    };
  }

  Facility copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    double? hourlyRate,
    int? maxCapacity,
    List<String>? amenities,
    List<String>? rules,
    Map<String, dynamic>? operatingHours,
    bool? isActive,
  }) {
    return Facility(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      amenities: amenities ?? this.amenities,
      rules: rules ?? this.rules,
      operatingHours: operatingHours ?? this.operatingHours,
      isActive: isActive ?? this.isActive,
    );
  }
}
