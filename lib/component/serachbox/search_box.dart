import 'package:flutter/material.dart';
import 'dart:async';

import 'package:mapapp/provider/places_provider.dart';
import 'package:mapapp/model/rerated_model.dart';
import 'package:mapapp/view/spot/spot_detail_screen.dart';

class SearchBox extends StatefulWidget {
  final TextEditingController controller;

  const SearchBox({super.key, required this.controller});

  @override
  // ignore: library_private_types_in_public_api
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  List<PlaceDetail> _searchResults = [];
  bool _isLoading = false;
  OverlayEntry? _overlayEntry;
  Timer? _debounceTimer;
  late PlacesProvider _placesProvider;

  @override
  void initState() {
    super.initState();
    _placesProvider = PlacesProvider();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _removeOverlay();
    super.dispose();
  }

  void _onSearch(String value) async {
    if (_debounceTimer != null) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(Duration(milliseconds: 500), () async {
      if (value.trim().isEmpty) {
        _removeOverlay();
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        var places = await _placesProvider.fetchPlaceAllDetails('search',
            keyword: value);
        setState(() {
          _searchResults = places;
        });
        _showOverlay(context);
      } catch (e) {
        print("Error fetching places: $e");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _showOverlay(BuildContext context) {
    if (_overlayEntry != null) {
      _removeOverlay();
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 130.0,
        left: 0.0,
        right: 0.0,
        bottom: 0.0,
        child: Material(
          child: Container(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final place = _searchResults[index];
                return ListTile(
                  title: Text(place.name ?? ''),
                  subtitle: Text(place.address ?? ''),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SpotDetailScreen(
                          spot: place,
                          parentContext: context,
                        ),
                      ),
                    );
                    _removeOverlay();
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    cursorColor: Color(0xFFF6E6DC), // カーソルの色
                    style: TextStyle(
                      color: Colors.white, // 入力されたテキストの色
                      // 他のスタイル設定もここに追加できます
                    ),
                    decoration: InputDecoration(
                      labelText: 'エリア・施設名・キーワード',
                      labelStyle: TextStyle(
                        color: Color(0xFFF6E6DC), // ラベル（プレースホルダー）の色
                      ),
                      suffixIcon: widget.controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  widget.controller.clear();
                                  _searchResults.clear();
                                  _removeOverlay();
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFFF6E6DC)), // 通常の枠の色
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFFF6E6DC)), // フォーカス時の枠の色
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFFF6E6DC)), // 有効時の枠の色
                      ),
                      filled: true,
                      fillColor: Color(0xFF444440),
                    ),
                    onSubmitted: (value) => _onSearch(value),
                  ),
                ),
              ],
            ),
          ],
        ),
        if (_isLoading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
