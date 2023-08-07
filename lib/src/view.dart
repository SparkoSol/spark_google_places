import 'package:flutter/material.dart';
import 'package:spark_google_places/spark_google_places.dart';

class SearchPlaceView extends StatefulWidget {
  const SearchPlaceView({
    super.key,
    required this.style,
  });

  final SparkStyle style;

  @override
  State<SearchPlaceView> createState() => _SearchPlaceViewState();
}

class _SearchPlaceViewState extends State<SearchPlaceView> {
  SparkStyle get _style => widget.style;

  final _textController = TextEditingController();
  String? _error;
  var _isLoading = false;
  var _data = <PlacesResponse>[];

  Future<void> _fetchData() async {
    if (_textController.text.isEmpty) {
      _isLoading = false;
      _error = null;
      _data = [];
      if (!mounted) return;
      setState(() {});
      return;
    }
    _isLoading = true;
    if (!mounted) return;
    setState(() {});
    try {
      _data = await RestService.searchPlaces(_textController.text);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    late Widget child;
    if (_textController.text.isEmpty) {
      child = Center(
        child: _style.logo ?? Text('Enter a location to search.'),
      );
    } else if (_isLoading) {
      child = _style.loadingWidget ??
          Center(
            child: CircularProgressIndicator(),
          );
    } else if (_error?.isNotEmpty ?? false) {
      child = _style.errorWidget ??
          Center(
            child: Text(
              _error!,
              style: _style.emptyErrorTextStyle,
            ),
          );
    } else if (_data.isEmpty) {
      child = _style.noResultWidget ??
          Center(
            child: Text(
              'Unable to locate any places.',
              style: _style.emptyErrorTextStyle,
            ),
          );
    } else {
      child = _buildListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _style.title,
          style: _style.titleTextStyle,
        ),
      ),
      body: Padding(
        padding: _style.pagePadding ??
            EdgeInsets.fromLTRB(
              10,
              10,
              10,
              media.padding.bottom + 10,
            ),
        child: Column(children: [
          TextFormField(
            controller: _textController,
            onChanged: (_) => _fetchData(),
            style: _style.searchFieldTextStyle,
            textInputAction: TextInputAction.search,
            onFieldSubmitted: (_) => _fetchData(),
            onEditingComplete: _fetchData,
            decoration: _style.searchFieldDecoration ??
                InputDecoration(
                  hintText: _style.hintText ?? 'Enter a location to search.',
                ),
          ),
          Expanded(child: child),
        ]),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemBuilder: (_, i) {
        final place = _data[i];
        if (_style.resultBuilder != null) {
          return InkWell(
            onTap: () => _selectLocation(place),
            child: _style.resultBuilder!(place),
          );
        } else {
          return ListTile(
            leading: Icon(Icons.location_on),
            title: Text(
              place.description,
              style: _style.resultTextStyle,
            ),
            onTap: () => _selectLocation(place),
          );
        }
      },
      itemCount: _data.length,
    );
  }

  void _selectLocation(PlacesResponse place) async {
    showDialog(
      context: context,
      builder: (_) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
    try {
      final latLng = await RestService.getLatLng(
        place.placeId,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      Navigator.of(context).pop<SparkPlaceResponse>(
        SparkPlaceResponse(
          address: place.description,
          latitude: latLng.$1,
          longitude: latLng.$2,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: Text('Ok'),
              )
            ],
          );
        },
      );
    }
  }
}
