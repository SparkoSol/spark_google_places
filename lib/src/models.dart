class PlacesResponse {
  PlacesResponse({
    required this.description,
    required this.placeId,
  });

  factory PlacesResponse.fromJson(Map<String, dynamic> json) {
    return PlacesResponse(
      description: json['description'],
      placeId: json['place_id'],
    );
  }

  final String description;
  final String placeId;
}

class SparkPlaceResponse {
  SparkPlaceResponse({
    required this.longitude,
    required this.latitude,
    required this.address,
  });

  final double latitude;
  final double longitude;
  final String address;
}

class Component {
  static const route = 'route';
  static const locality = 'locality';
  static const administrativeArea = 'administrative_area';
  static const postalCode = 'postal_code';
  static const country = 'country';

  final String component;
  final String value;

  Component(this.component, this.value);

  @override
  String toString() => '$component:$value';
}
