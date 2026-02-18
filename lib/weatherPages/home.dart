import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../models/city.dart';
import '../models/weatherModel.dart';
import '../services/weather_services.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final weatherServices = WeatherServices(
    apiKey: 'YOUR-API-KEY',
  );
  WeatherModel? weatherM; // Nullable

  TextEditingController _textEditingController = TextEditingController();

  String getAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/default.json';

    switch (mainCondition.toLowerCase()) {
      case 'mist':
      case 'smoke':


      case 'haze':
      case 'clouds':
      case 'dust':
      case 'fog':
        return 'assets/4.json';
      case 'thunderstorm':
        return 'assets/1.json';
      case 'snow':
        return 'assets/snow.json';
      case 'rain':
        return 'assets/rain.json';

      default:
        return 'assets/default.json';
    }
  }

  fetchWeather() async {
    try {
      String cityName = await weatherServices.getCurrentCity();
      final weather = await weatherServices.getWeather(cityName);
      setState(() {
        weatherM = weather;
      });
    } catch (err) {
      log('Error fetching weather: $err');
      setState(() {
        weatherM = null; // Reset on error
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.search, color: Colors.white),

        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Search City',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Autocomplete<City>(
                    displayStringForOption: (City city) => '${city.name}',

                    optionsBuilder: (TextEditingValue textEditingValue) async {
                      if (textEditingValue.text.length < 2) {
                        return const Iterable<City>.empty();
                      }
                      return await weatherServices.searchCities(
                        textEditingValue.text,
                      );
                    },

                    onSelected: (City city) {
                      weatherServices.getWeatherByLatLon(city.lat, city.lon);
                    },

                    fieldViewBuilder:
                        (context, controller, focusNode, onFieldSubmitted) {
                          _textEditingController = controller;
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              hintText: "Search city",
                              filled: true,
                              fillColor: Colors.blueGrey.shade200,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          );
                        },
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        onPressed: () async {
                          final weather2 = await weatherServices.getWeather(
                            _textEditingController.text,
                          );
                          setState(() {
                            weatherM = weather2;
                          });

                          Navigator.of(context).pop();
                          _textEditingController.clear();
                        },
                        child: Text(
                          'Submit',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      body: Center(
        child: weatherM == null
            ? const Text('Loading weather data...')
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 📍 City + Country
                    Text(
                      '${weatherM!.cityName}, ${weatherM!.country}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 🌦 Animation
                    Lottie.asset(
                      getAnimation(weatherM!.mainCondition),
                      height: 200,
                    ),

                    // 🌡 Temperature
                    Text(
                      '${weatherM!.temperature.round()}°C',
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // ☁ Description
                    Text(
                      weatherM!.description,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 📊 Extra weather info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _weatherInfoTile(
                          label: 'Feels Like',
                          value: '${weatherM!.feelsLike.round()}°C',
                        ),
                        _weatherInfoTile(
                          label: 'Humidity',
                          value: '${weatherM!.humidity}%',
                        ),
                        _weatherInfoTile(
                          label: 'Wind',
                          value: '${weatherM!.windSpeed} m/s',
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
Widget _weatherInfoTile({
  required String label,
  required String value,
}) {
  return Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: const TextStyle(
          color: Colors.grey,
        ),
      ),
    ],
  );
}
