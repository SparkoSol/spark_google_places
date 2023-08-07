import 'package:dio/dio.dart';
import 'package:spark_google_places/src/models.dart';

typedef SparkLatLng = (double, double);

class RestService {
  static final _client = Dio();
  static final _baseUrl = 'https://maps.googleapis.com/maps/api';
  static var _apiKey = '';
  static num? _radius;
  static List<String>? _types;
  static List<Component>? _components;
  static bool? _strictBounds;
  static String? _region;

  static set apiKey(String value) => _apiKey = value;

  static set radius(num? value) => _radius = value;

  static set types(List<String>? value) => _types = value;

  static set components(List<Component>? value) => _components = value;

  static set strictBounds(bool? value) => _strictBounds = value;

  static set region(String? value) => _region = value;

  static Future<List<PlacesResponse>> searchPlaces(String input) async {
    try {
      final queryParams = <String, dynamic>{
        r'input': input,
        r'key': _apiKey,
      };
      if (_radius != null) {
        queryParams[r'radius'] = _radius;
      }
      if (_types != null) {
        queryParams[r'types'] = _types!.join('|');
      }
      if (_strictBounds != null) {
        queryParams[r'strictbounds'] = _strictBounds;
      }
      if (_region != null) {
        queryParams[r'region'] = _region;
      }
      if (_components != null) {
        queryParams[r'components'] =
            _components!.map((e) => e.toString()).join('|');
      }
      final result = await _client.get(
        '$_baseUrl/place/autocomplete/json',
        queryParameters: queryParams,
      );
      if (result.statusCode != 200) {
        throw 'Sorry, There Seems to be an Issue with Your Internet Connection';
      }
      Map<String, dynamic> data = result.data;
      if (data.containsKey('error_message')) {
        String errorMessage = data['error_message'] ?? '';
        if (errorMessage.isNotEmpty) {
          throw errorMessage;
        }
      }
      String status = data['status'];
      if (status == 'ZERO_RESULTS') throw 'Unable to locate any places.';
      if (status != 'OK') throw status;
      List predictions = data['predictions'];
      return predictions
          .map<PlacesResponse>((e) => PlacesResponse.fromJson(e))
          .toList();
    } catch (_) {
      rethrow;
    }
  }

  static Future<SparkLatLng> getLatLng(String place) async {
    try {
      final result = await _client.get(
        '$_baseUrl/place/details/json?place_id=$place&key=$_apiKey',
      );
      if (result.statusCode != 200) {
        throw 'Sorry, There Seems to be an Issue with Your Internet Connection';
      }
      Map<String, dynamic> data = result.data;
      if (data.containsKey('error_message')) {
        String errorMessage = data['error_message'] ?? '';
        if (errorMessage.isNotEmpty) {
          throw errorMessage;
        }
      }
      String status = data['status'];
      if (status == 'ZERO_RESULTS') throw 'Unable to locate any places.';
      if (status != 'OK') throw status;
      final location = data['result']['geometry']['location'];
      return (
      location['lat'] as double,
      location['lng'] as double,
      );
    } catch (_) {
      rethrow;
    }
  }
}
