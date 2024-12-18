import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forekast_app/data/local_storage/local_data.dart';
import 'package:forekast_app/data/models/weather_model.dart';
import 'package:forekast_app/presentations/widgets/common_widgets.dart';
import 'package:forekast_app/presentations/widgets/weather_widgets.dart';
import 'package:forekast_app/services/cities_service.dart';
import 'package:forekast_app/services/favorites_service.dart';
import 'package:forekast_app/services/weather_service.dart';
import 'package:forekast_app/utils/common_function.dart';
import 'package:forekast_app/utils/common_ui.dart';

class WeatherPage extends StatefulWidget {
  final ValueNotifier<String> selectedCity;
  const WeatherPage({super.key, required this.selectedCity});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final textController = TextEditingController();
  WeatherApi client = WeatherApi();
  CitiesApi citiesApi = CitiesApi();
  FavoriteWeather favoriteWeather = FavoriteWeather();
  SettingsData settingsData = SettingsData();
  Weather? data;
  DailyWeather? dailyData;
  String? country;
  bool isFavorite = false;
  int favoriteCount = 0;
  String temperatureUnit = '°C';
  String windSpeed = 'm/s';
  Icon addedFavText = const Icon(
    CupertinoIcons.heart_fill,
    color: Colors.red,
    size: 28.0,
  );
  Icon addToFavText = const Icon(
    CupertinoIcons.heart,
    color: Color(0xFFFA877F),
    size: 28.0,
  );
  final ValueNotifier<Icon> favoriteButton = ValueNotifier<Icon>(const Icon(
    CupertinoIcons.heart,
    color: Colors.grey,
  ));

  @override
  void initState() {
    super.initState();
    widget.selectedCity.addListener(_handleCityChange);
    checkFavorite(widget.selectedCity.value);
  }

  @override
  void dispose() {
    widget.selectedCity.removeListener(_handleCityChange);
    super.dispose();
  }

  void _handleCityChange() async {
    await checkFavorite(widget.selectedCity.value);
  }

  Future<void> checkFavorite(String city) async {
    isFavorite = await favoriteWeather.favoriteExists(city);
    favoriteCount = await favoriteWeather.favoritesCount();
    favoriteButton.value = isFavorite ? addedFavText : addToFavText;
  }

  Future<Weather?> getData() async {
    try {
      data = await client.getCurrentWeather(widget.selectedCity.value);
      dailyData = await client.getDailyWeather(data?.lat, data?.lon);
      Map<String, String>? ccMap = await CitiesData().getCountryCodeMap();
      // Check the local data first, if not fetch from network
      country = ccMap![data?.country] ??
          await citiesApi.getCountryName('${data?.country}');
      Map<String, dynamic> settings = await settingsData.getPreferences();
      temperatureUnit = settings["selectedUnit"] == 'metric' ? '°C' : '°F';
      windSpeed = settings["selectedUnit"] == 'metric' ? 'm/s' : 'mph';
      return data;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: weatherFutureBuilder(),
    );
  }

  FutureBuilder<void> weatherFutureBuilder() {
    return FutureBuilder<Weather?>(
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return errorWidget(
              context,
              message: "unable to provide weather info right now",
            );
          }
          final snapshotData = snapshot.data;
          if (snapshotData != null && snapshotData.cityName!.isNotEmpty) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [weatherData(data)],
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(18.0),
              child: Center(
                child: CommonWidgets.myRichText(
                  context,
                  'Oops! Weather info not available for',
                  text2: widget.selectedCity.value,
                ),
              ),
            );
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return CommonWidgets.myLoadingIndicator(
            context,
            text1: 'getting weather info for',
            text2: widget.selectedCity.value,
          );
        }
        return errorWidget(context);
      },
      future: getData(),
    );
  }

  Widget weatherData(data) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          currentWeather(
            "${data!.temp}$temperatureUnit",
            "${data!.cityName}",
            "${data!.description}",
            "$country",
            "${data!.timestamp}",
            "${data!.weatherCondition}",
            context,
          ),
          const SizedBox(
            height: 18.0,
          ),
          commonText(
            context,
            'additional information',
            fontSize: 18.0,
            color: Theme.of(context).colorScheme.tertiary,
            fontWeight: FontWeight.bold,
          ),
          additionalInformation(
            "${data!.wind}$windSpeed ${data!.degree}",
            "${data!.humidity}%",
            "${data!.pressure}mBar",
            "${data!.feelsLike}$temperatureUnit",
            "${data!.degree}",
            "${data!.sunrise}",
            "${data!.sunset}",
            "${data!.visibility}km",
            context,
          ),
          const SizedBox(
            height: 18.0,
          ),
          commonText(
            context,
            'daily forecast',
            fontSize: 18.0,
            color: Theme.of(context).colorScheme.tertiary,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(
            height: 4.0,
          ),
          dailyForecast(dailyData!.model, temperatureUnit, context),
          const SizedBox(
            height: 8.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              addToFavButton('${data!.cityName}, $country'),
              if (favoriteCount < 8) const SizedBox(width: 18),
              launchMaps(data),
            ],
          ),
        ],
      ),
    );
  }

  Widget launchMaps(data) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(24.0)),
        color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
      ),
      child: IconButton(
        style: const ButtonStyle(
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStatePropertyAll(Colors.transparent),
        ),
        onPressed: () => launchMapsUrl(context, data?.lat, data?.lon),
        icon: const Icon(
          CupertinoIcons.map,
          color: Colors.lightBlue,
        ),
      ),
    );
  }

  Widget addToFavButton(String city) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(24.0)),
        color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
      ),
      child: favoriteCount < 8
          ? ValueListenableBuilder<Icon>(
              valueListenable: favoriteButton,
              builder: (context, icon, child) {
                return IconButton(
                  style: const ButtonStyle(
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: WidgetStatePropertyAll(Colors.transparent),
                  ),
                  onPressed: () async {
                    if (favoriteButton.value == addToFavText) {
                      await favoriteWeather.saveFavorites(city);
                    }
                    favoriteButton.value = addedFavText;
                  },
                  icon: icon,
                );
              },
            )
          : null,
    );
  }
}
