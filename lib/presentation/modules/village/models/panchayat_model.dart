class Panchayat {
  final String id;
  final String name;
  final String description;
  final String category; // temple, school, hospital, etc.
  final String? state;
  final String? district;
  final String? taluka;
  final String city;
  final String village;
  final String address;
  final String contactNumber;
  final String email;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  Panchayat({
    required this.id,
    required this.name,
    this.description = '',
    required this.category,
    this.state,
    this.district,
    this.taluka,
    required this.city,
    required this.village,
    this.address = '',
    this.contactNumber = '',
    this.email = '',
    this.imageUrl = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Convert Panchayat to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'category': category,
        'state': state,
        'district': district,
        'taluka': taluka,
        'city': city,
        'village': village,
        'address': address,
        'contactNumber': contactNumber,
        'email': email,
        'imageUrl': imageUrl,
        'latitude': latitude,
        'longitude': longitude,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  // Create Panchayat from JSON
  factory Panchayat.fromJson(Map<String, dynamic> json) => Panchayat(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        category: json['category'] ?? '',
        state: json['state'] ?? '',
        district: json['district'] ?? '',
        taluka: json['taluka'] ?? '',
        city: json['city'] ?? '',
        village: json['village'] ?? '',
        address: json['address'] ?? '',
        contactNumber: json['contactNumber'] ?? '',
        email: json['email'] ?? '',
        imageUrl: json['imageUrl'] ?? '',
        latitude: (json['latitude'] ?? 0.0).toDouble(),
        longitude: (json['longitude'] ?? 0.0).toDouble(),
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      );
}

// List of categories for Panchayat
List<String> panchayatCategories = [
  'Temple',
  'School',
  'Hospital',
  'Panchayat Office',
  'Community Hall',
  'Park',
  'Playground',
  'Library',
  'Post Office',
  'Bank',
  'ATM',
  'Market',
  'Other',
];
