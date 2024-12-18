import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forekast_app/utils/common_function.dart';
import 'package:forekast_app/utils/common_ui.dart';
import 'package:lottie/lottie.dart';

Widget getWeatherAnimation(String? condition) {
  String assetPath = 'assets/weather_animations';
  switch (condition) {
    case '01d':
      assetPath = '$assetPath/sunny.json';
      break;
    case '01n':
      assetPath = '$assetPath/clear_night.json';
      break;
    case '02d':
      assetPath = '$assetPath/few_clouds_day.json';
      break;
    case '02n':
      assetPath = '$assetPath/few_clouds_night.json';
      break;
    case '03d' || '03n' || '04d' || '04n':
      assetPath = '$assetPath/cloudy.json';
      break;
    case '09d' || '10d':
      assetPath = '$assetPath/shower_rain_day.json';
      break;
    case '09n' || '10n':
      assetPath = '$assetPath/shower_rain_night.json';
      break;
    case '11d' || '11n':
      assetPath = '$assetPath/thunderstorm.json';
      break;
    case '13d' || '13n':
      assetPath = '$assetPath/snow.json';
      break;
    case '50d' || '50n':
      assetPath = '$assetPath/mist.json';
      break;
    default:
      return Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: getIcon(condition),
        ),
      );
  }
  return Center(
    child: SizedBox(
      width: 320,
      height: 320,
      child: Lottie.asset(assetPath),
    ),
  );
}

SizedBox div = const SizedBox(height: 16);

Widget currentWeather(
  String temp,
  String location,
  String description,
  String country,
  String timestamp,
  String weatherCondition,
  BuildContext context,
) {
  return Center(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        getWeatherAnimation(weatherCondition),
        currentWeatherElement(
          temp,
          Theme.of(context).colorScheme.primary,
          Theme.of(context).textTheme.labelLarge?.fontSize,
          FontWeight.bold,
          context,
        ),
        currentWeatherElement(
          "$location, $country",
          Theme.of(context).colorScheme.secondary,
          Theme.of(context).textTheme.labelMedium?.fontSize,
          FontWeight.bold,
          context,
        ),
        const SizedBox(height: 10.0),
        currentWeatherElement(
          description,
          Theme.of(context).colorScheme.tertiary,
          Theme.of(context).textTheme.titleLarge?.fontSize,
          FontWeight.w300,
          context,
        ),
        const SizedBox(height: 4.0),
        currentWeatherElement(
          timestamp,
          Theme.of(context).colorScheme.tertiary,
          Theme.of(context).textTheme.titleSmall?.fontSize,
          FontWeight.w300,
          context,
        ),
      ],
    ),
  );
}

Widget currentWeatherElement(
  String value,
  Color color,
  double? fontSize,
  FontWeight fontWeight,
  BuildContext context,
) {
  return SizedBox(
    width: 340,
    child: Text(
      value,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      textAlign: TextAlign.center,
    ),
  );
}

Widget additionalInformation(
  String wind,
  String humidity,
  String pressure,
  String feelsLike,
  String? degree,
  String sunrise,
  String sunset,
  String visibility,
  BuildContext context,
) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            additionalInfoSubWidget(
              context,
              Icons.air,
              'wind',
              wind,
              position: 'left',
            ),
            additionalInfoSubWidget(
                context, Icons.water_drop_outlined, 'humidity', humidity),
          ],
        ),
        div,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            additionalInfoSubWidget(
              context,
              CupertinoIcons.gauge,
              'pressure',
              pressure,
              position: 'left',
            ),
            additionalInfoSubWidget(
                context, CupertinoIcons.thermometer, 'feels like', feelsLike),
          ],
        ),
        div,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            additionalInfoSubWidget(
              context,
              CupertinoIcons.sunrise,
              'sunrise',
              '$sunrise - $sunset',
              position: 'left',
            ),
            additionalInfoSubWidget(
                context, CupertinoIcons.eye, 'visibility', visibility),
          ],
        ),
      ],
    ),
  );
}

Widget additionalInfoSubWidget(
  BuildContext context,
  IconData icon,
  String title,
  String value, {
  String position = 'right',
}) {
  Map<String, TextStyle> styleComponents = cardStyleComponents(context);
  return Container(
    width: 165,
    height: 100,
    margin: position == 'right'
        ? const EdgeInsets.only(left: 10)
        : const EdgeInsets.only(right: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10.0),
      color: Theme.of(context).colorScheme.primaryContainer,
    ),
    padding: const EdgeInsets.symmetric(
      vertical: 10,
      horizontal: 10,
    ),
    child: Column(
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(width: 8.0),
            Text(
              title,
              style: styleComponents["containerTitleMedium"],
            )
          ],
        ),
        div,
        Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: styleComponents["containerInfoLarge"],
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      ],
    ),
  );
}

Widget dailyForecast(List data, String temperatureUnit, BuildContext context) {
  Map<String, TextStyle> styleComponents = cardStyleComponents(context);
  if (data[0]["err"] == 1) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        "Daily forecast data unavailable!",
        style: TextStyle(
          color: Theme.of(context).colorScheme.tertiary,
        ),
      ),
    );
  } else {
    return SizedBox(
      width: 368.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                shadowColor: Colors.transparent,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      commonExpandedWidget(
                        1,
                        Alignment.centerLeft,
                        Alignment.center,
                        Text(
                          data[index]["dt"],
                          style: styleComponents["cardDateSmall"],
                        ),
                        padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                      ),
                      commonExpandedWidget(
                        1,
                        Alignment.centerLeft,
                        Alignment.center,
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: getSmallIcon(data[index]["icon"]),
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                      ),
                      commonExpandedWidget(
                        3,
                        Alignment.centerLeft,
                        Alignment.centerRight,
                        Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  "${data[index]["tempMax"]} / ${data[index]["tempMin"]}$temperatureUnit",
                                  style: styleComponents["cardTempMediumBold"],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    data[index]["description"],
                                    style: styleComponents["cardDescrSmall"],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

Expanded commonExpandedWidget(
  int flex,
  Alignment rootAlignment,
  Alignment childAlignment,
  Widget child, {
  EdgeInsets? padding,
}) {
  padding ??= const EdgeInsets.all(0);
  return Expanded(
    flex: flex,
    child: Align(
      alignment: rootAlignment,
      child: Container(
        alignment: childAlignment,
        // width: 200.0,
        // height: 100.0,
        padding: padding,
        child: child,
      ),
    ),
  );
}
