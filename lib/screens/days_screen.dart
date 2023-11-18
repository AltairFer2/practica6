import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DayScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<DayScreen> {
  Position? _currentLocation;
  Map<String, dynamic>? _weatherData;
  String? _cityName;

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  void _loadWeatherData() async {
    try {
      _currentLocation = await getCurrentLocation();

      final weatherData = await getWeatherData(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
      );

      setState(() {
        _weatherData = weatherData;
        _cityName = _weatherData!['city']['name'];
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Forecast'),
      ),
      body: _weatherData != null
          ? _buildWeatherContent()
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildWeatherContent() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ubicación Actual',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            '$_cityName',
          ),
          SizedBox(height: 16.0),
          TextField(
            decoration: InputDecoration(
              labelText: 'Buscar ciudad',
              suffixIcon: Icon(Icons.search),
            ),
            onSubmitted: (city) {
              // Lógica para buscar pronóstico de la ciudad ingresada
            },
          ),
          SizedBox(height: 16.0),
          Text(
            'Pronóstico de los próximos 5 días',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                // Ajuste del índice para mostrar los días correctamente
                var dayIndex = index + 1;
                var weatherData = _weatherData!['list'][index];
                var temperatureKelvin = weatherData['main']['temp'];
                var temperatureCelsius = temperatureKelvin - 273.15;
                var weatherDescription =
                    weatherData['weather'][0]['description'];
                var iconAbbreviation = weatherData['weather'][0]['icon'];

                return ListTile(
                  title: Text('Día $dayIndex'),
                  subtitle: Text(
                      'Temperatura: ${temperatureCelsius.toStringAsFixed(1)}°C, Estado: $weatherDescription'),
                  leading: Image.network(
                    'https://openweathermap.org/img/wn/$iconAbbreviation.png',
                    width: 50,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Future<Position> getCurrentLocation() async {
  return await Geolocator.getCurrentPosition();
}

Future<Map<String, dynamic>> getWeatherData(double lat, double lon) async {
  final apiKey =
      '37dc66eac76ce609805ba132e8b6b700'; // Reemplaza con tu clave de API de OpenWeatherMap
  final apiUrl = 'https://api.openweathermap.org/data/2.5/forecast';

  final response = await http.get(
    Uri.parse('$apiUrl?lat=$lat&lon=$lon&appid=$apiKey'),
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Error al obtener datos del clima');
  }
}
