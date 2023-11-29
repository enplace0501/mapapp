import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mapapp/test/PlaceChategories.dart';
import 'package:mapapp/test/rerated_model.dart';

class PlacesProvider with ChangeNotifier {
  final String _baseUrl =
      'https://r1ahdkatn2.execute-api.ap-northeast-1.amazonaws.com/mymap';

  PlacesProvider(BuildContext context);

  Future<List<PlaceDetail>> fetchPlaceAllDetails(String endpoint,
      {String? keyword}) async {
    String url;
    switch (endpoint) {
      case 'places':
        url = '$_baseUrl/places';
        break;
      case 'coupons':
        url = '$_baseUrl/coupons';
        break;
      case 'search':
        url = '$_baseUrl/places/$keyword';
        break;
      default:
        throw Exception('Invalid endpoint');
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      String responseBody = utf8.decode(response.bodyBytes);

      Map<String, dynamic> outerBody = json.decode(responseBody);

      // 修正: innerBody を Map<String, dynamic> として取得
      Map<String, dynamic> innerBody = outerBody['body'];

      // 修正: innerBody の 'body' キーの値（文字列）を再度デコード
      List<dynamic> bodyData = json.decode(innerBody['body']);

      List<PlaceDetail> placeDetails = bodyData.map((item) {
        return PlaceDetail.fromJson(item);
      }).toList();

      return placeDetails;
    } else {
      throw Exception('Failed to load places');
    }
  }

  Future<List<PlaceCategory>> fetchPlaceCategories() async {
    final url = '$_baseUrl/tables/PlaceCategories';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      String responseBody = utf8.decode(response.bodyBytes);

      Map<String, dynamic> outerBody = json.decode(responseBody);

      // innerBody を Map<String, dynamic> として取得
      Map<String, dynamic> innerBody = outerBody['body'];

      // innerBody の 'body' キーの値（文字列）を再度デコード
      List<dynamic> bodyData = json.decode(innerBody['body']);

      List<PlaceCategory> categories = bodyData.map((item) {
        return PlaceCategory.fromJson(item);
      }).toList();

      return categories;
    } else {
      throw Exception('Failed to load table data');
    }
  }

  Future<List<PlaceCategorySub>> fetchPlaceCategoriesSub() async {
    final url = '$_baseUrl/tables/PlaceCategoriesSub';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> outerBody = json.decode(responseBody);
      Map<String, dynamic> innerBody = outerBody['body'];
      List<dynamic> bodyData = json.decode(innerBody['body']);

      List<PlaceCategorySub> categoriessub = bodyData.map((item) {
        return PlaceCategorySub.fromJson(item);
      }).toList();

      return categoriessub;
    } else {
      throw Exception('Failed to load table data');
    }
  }

  Future<List<PlaceDetail>> fetchFilteredPlaceDetails(
      List<int> placeIds) async {
    List<PlaceDetail> allPlaces = await fetchPlaceAllDetails('places');
    List<PlaceDetail> filteredPlaces = [];

    for (int id in placeIds) {
      filteredPlaces.addAll(allPlaces.where((place) => place.placeId == id));
    }

    return filteredPlaces;
  }
}
