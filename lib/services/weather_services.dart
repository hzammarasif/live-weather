
import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:live_weather/models/weatherModel.dart';

import '../models/city.dart';


class WeatherServices{
  static const BaseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  String apiKey;

  WeatherServices({required this.apiKey});
  Future<WeatherModel> getWeather(String cityName)async{
    print("Hitting the url $BaseUrl?q=$cityName&appid=$apiKey&units=metric");
    final response = await http.get(Uri.parse('$BaseUrl?q=$cityName&appid=$apiKey&units=metric'));
    if(response.statusCode == 200){
      print(response.body);
      return WeatherModel.fromJson(jsonDecode(response.body));
    }else{
      throw Exception('Failed to load data from the website');
    }
  }

  // get permission from the uesr
  Future<String> getCurrentCity()async{
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
    }

    // fetch the current location

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );

    // convert the location into a list of placemark objects
    List<Placemark> placemark = await placemarkFromCoordinates(position.latitude, position.longitude);

    // Extract the city name

    String? city = placemark[0].locality;

    return city ?? "not found";
  }

  Future<List<City>> searchCities(String query) async {
    final response = await http.get(
      Uri.parse(
        'https://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=$apiKey',
      ),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => City.fromJson(e)).toList();
    } else {
      throw Exception('City search failed');
    }
  }
  Future<WeatherModel> getWeatherByLatLon(double lat, double lon) async {
    final response = await http.get(
      Uri.parse(
        '$BaseUrl?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
      ),
    );

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather');
    }
  }



}