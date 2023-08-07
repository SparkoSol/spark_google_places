import 'package:flutter/material.dart';
import 'package:spark_google_places/src/models.dart';
import 'package:spark_google_places/src/rest_service.dart';
import 'package:spark_google_places/src/view.dart';

typedef ResultWidgetBuilder = Widget Function(PlacesResponse);

class SparkGooglePlaces {
  SparkGooglePlaces({required this.apiKey});

  final String apiKey;

  Future<SparkPlaceResponse?> searchGooglePlace(
    BuildContext context, {
    SparkStyle? style,
    num? radius,
    List<String>? types,
    List<Component>? components,
    bool? strictBounds,
    String? region,
  }) async {
    RestService.apiKey = apiKey;
    RestService.radius = radius;
    RestService.types = types;
    RestService.components = components;
    RestService.strictBounds = strictBounds;
    RestService.region = region;
    style ??= SparkStyle();
    try {
      final result = await Navigator.of(context).push<SparkPlaceResponse?>(
        MaterialPageRoute<SparkPlaceResponse?>(
          builder: (_) => SearchPlaceView(
            style: style!,
          ),
        ),
      );
      return result;
    } catch (_) {
      rethrow;
    }
  }
}

class SparkStyle {
  SparkStyle({
    this.title = 'Search Place',
    this.titleTextStyle,
    this.loadingWidget,
    this.emptyErrorTextStyle,
    this.searchFieldTextStyle,
    this.searchFieldDecoration,
    this.hintText,
    this.resultTextStyle,
    this.logo,
    this.errorWidget,
    this.noResultWidget,
    this.pagePadding,
    this.resultBuilder,
  });

  final String title;
  final TextStyle? titleTextStyle;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? noResultWidget;
  final TextStyle? emptyErrorTextStyle;
  final TextStyle? searchFieldTextStyle;
  final InputDecoration? searchFieldDecoration;
  final String? hintText;
  final TextStyle? resultTextStyle;
  final Widget? logo;
  final EdgeInsets? pagePadding;
  final ResultWidgetBuilder? resultBuilder;
}
