class Salon {
  final String id;
  final String name;
  final String location;
  final double rating;
  final int reviews;
  final List<String> services;  // Đơn giản hóa: List tên dịch vụ
  final String priceRange;
  final double distance;
  final String openHours;
  final String phone;
  final String description;
  final String imageUrl;
  final double latitude;
  final double longitude;

  const Salon({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.reviews,
    required this.services,
    required this.priceRange,
    required this.distance,
    required this.openHours,
    required this.phone,
    required this.description,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
  });

  factory Salon.fromJson(Map<String, dynamic> json) {
    return Salon(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviews: json['reviews'] ?? 0,
      services: List<String>.from(json['services'] ?? []),
      priceRange: json['priceRange'] ?? '',
      distance: (json['distance'] ?? 0.0).toDouble(),
      openHours: json['openHours'] ?? '',
      phone: json['phone'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'location': location,
    'rating': rating,
    'reviews': reviews,
    'services': services,
    'priceRange': priceRange,
    'distance': distance,
    'openHours': openHours,
    'phone': phone,
    'description': description,
    'imageUrl': imageUrl,
    'latitude': latitude,
    'longitude': longitude,
  };
}