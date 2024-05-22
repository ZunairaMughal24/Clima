import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Clima',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String temperature = '';
  String weatherDescription = '';
  String location = '';
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchLocationAndWeather();
  }

  void fetchLocationAndWeather() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      double latitude = position.latitude;
      double longitude = position.longitude;

      // Fetch weather using latitude and longitude
      fetchWeatherByCoordinates(latitude, longitude);
    } catch (e) {
      setState(() {
        temperature = '';
        weatherDescription = 'Failed to fetch location data: $e';
      });
    }
  }

  void fetchWeatherByCoordinates(double latitude, double longitude) async {
    const apiKey = '8ac246e77479e5e99b615ad084b2e218';
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=metric&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          temperature = '${data['main']['temp']}°C';
          weatherDescription = data['weather'][0]['main'];
          location = data['name'];
        });
      } else {
        setState(() {
          temperature = '';
          weatherDescription = 'Failed to fetch weather data';
        });
      }
    } catch (e) {
      setState(() {
        temperature = '';
        weatherDescription = 'Failed to fetch weather data: $e';
      });
    }
  }

  void fetchWeatherByLocation(String location) async {
    const apiKey = '8ac246e77479e5e99b615ad084b2e218';
    final url = 'https://api.openweathermap.org/data/2.5/weather?q=$location&units=metric&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          temperature = '${data['main']['temp']}°C';
          weatherDescription = data['weather'][0]['main'];
          this.location = data['name'];
        });
      } else {
        setState(() {
          temperature = '';
          weatherDescription = 'Failed to fetch weather data';
        });
      }
    } catch (e) {
      setState(() {
        temperature = '';
        weatherDescription = 'Failed to fetch weather data: $e';
      });
    }
  }

  String getWeatherEmoji(String weather) {
    switch (weather.toLowerCase()) {
      case 'thunderstorm':
        return '⛈️';
      case 'drizzle':
      case 'rain':
        return '🌧️';
      case 'snow':
        return '❄️';
      case 'clear':
        return '☀️';
      case 'clouds':
        return '☁️';
      default:
        return '🌈';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"), // Set your image path here
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 60),
              const Text(
                'Weather App',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25.0, color: Colors.white),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            hintText: 'Enter a location',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: IconButton(
                          onPressed: () {
                            fetchWeatherByLocation(_locationController.text);
                          },
                          icon: const Icon(Icons.search),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 200),
              Center(
                child: Text(
                  location.isNotEmpty ? 'Weather in $location' : 'Fetching location...',
                  style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  temperature,
                  style: const TextStyle(
                    fontSize: 36,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      weatherDescription,
                      style: const TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      getWeatherEmoji(weatherDescription),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
