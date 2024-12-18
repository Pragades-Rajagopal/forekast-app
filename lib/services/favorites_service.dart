import 'dart:convert';
import 'package:forekast_app/data/local_storage/local_data.dart';
import 'package:forekast_app/data/models/favorites_model.dart';
import 'package:forekast_app/utils/common_function.dart';
import 'package:http/http.dart' as http;
import 'package:forekast_app/config/dotenv.dart';

/// Favorites API model
/// - Handles weather information for favorite cities
/// - Handles save and other validations for favorites
class FavoriteWeather {
  FavoritesData favoritesData = FavoritesData();
  SettingsData settingsData = SettingsData();

  /// Retrieves the weather information for the favorite city
  Future<SingleFavoriteWeather> getWeatherForFavoriteCity(String city) async {
    try {
      final env = await parseStringToMap(assetsFileName: '.env');
      String parsedCity = await countryNameToCodeConvertor(city);
      Map<String, dynamic> settings = await settingsData.getPreferences();
      var url = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$parsedCity&appid=${env["OPENWEATHER_API_KEY_DAILY"]}&units=${settings["selectedUnit"]}');
      var response = await http.get(url);
      var body = jsonDecode(response.body);
      SingleFavoriteWeather weather = SingleFavoriteWeather.fromJSON(body);
      return weather;
    } catch (e) {
      throw Exception('Failed to load data for $city');
    }
  }

  /// Retrieves the weather information for all the favorite city
  ///
  /// Loops through favorites and fetches weather info
  Future<List<Map<String, dynamic>>> getWeatherForAllFavorites(
      List<String> cities) async {
    try {
      List<Future<SingleFavoriteWeather>> futures = cities.map((city) {
        return getWeatherForFavoriteCity(city);
      }).toList();
      List<SingleFavoriteWeather> responses = await Future.wait(futures);
      List<Map<String, dynamic>> list = [];
      for (var i in responses) {
        var countryName = await getCountryNameForCode(i.country!);
        list.add({
          "tempMin": i.tempMin,
          "tempMax": i.tempMax,
          "temp": i.temp,
          "city":
              i.country != null ? '${i.cityName}, $countryName' : i.cityName,
          "icon": i.icon,
          "description": i.description,
        });
      }
      return list;
    } catch (e) {
      throw Exception('Failed to load data for $cities');
    }
  }

  /// Saves a city as favorite
  ///
  /// Internally calls `FavoritesData` local data model
  Future<bool> saveFavorites(String city) async {
    try {
      List<Map<String, dynamic>> data = await favoritesData.getFavorites();
      if (data.length > 7) return false;
      List<Map<String, dynamic>> newData = [
        ...data,
        {"city": city, "default": "false"}
      ];
      await favoritesData.saveFavorites(newData);
      return true;
    } catch (e) {
      throw Exception('Failed to add $city as favorite');
    }
  }

  /// Checks if a city is already added to favorites
  ///
  /// Internally calls `FavoritesData` local data model
  Future<bool> favoriteExists(String city_) async {
    List<Map<String, dynamic>> data = await favoritesData.getFavorites();
    final cityData = data.any((city) {
      return city["city"].toString().toLowerCase() ==
          city_.toString().toLowerCase();
    });
    if (cityData) return true;
    return false;
  }

  /// Retrieves the number of favorites added
  ///
  /// This check is to limit adding only upto 8 cities as favorites
  ///
  /// Internally calls `FavoritesData` local data model
  Future<int> favoritesCount() async {
    List<Map<String, dynamic>> data = await favoritesData.getFavorites();
    return data.length;
  }
}
