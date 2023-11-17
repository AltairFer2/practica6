import 'package:animated_floating_buttons/animated_floating_buttons.dart';
import 'package:clima/data/my_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';

const MAPBOX_ACCESS_TOKEN =
    'pk.eyJ1IjoicGl0bWFjIiwiYSI6ImNsY3BpeWxuczJhOTEzbnBlaW5vcnNwNzMifQ.ncTzM4bW-jpq-hUFutnR1g';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late String mapStyle;
  late MapController mapController;
  late LatLng actual;
  late TextEditingController cityController;
  LatLng? myPosition;
  late WeatherFactory weatherFactory;
  List<WeatherMarker> weatherMarkers = [];

  Future<Position> determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('error');
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<void> getCurrentWeather() async {
    if (myPosition != null) {
      List<Weather> weatherList =
          await weatherFactory.fiveDayForecastByLocation(
        myPosition!.latitude,
        myPosition!.longitude,
      );

      setState(() {
        weatherMarkers = weatherList.map((weather) {
          return WeatherMarker(
            latitude: weather.latitude,
            longitude: weather.longitude,
            temperature: weather.temperature?.celsius?.round(),
            weatherMain: weather.weatherMain,
          );
        }).toList();
      });
    }
  }

  void getCurrentLocation() async {
    Position position = await determinePosition();
    setState(() {
      myPosition = LatLng(position.latitude, position.longitude);
      actual = LatLng(position.latitude, position.longitude);
    });
    await getCurrentWeather();
  }

  void _onLongPress(BuildContext context, LatLng point) async {
    // Agregar un nuevo marcador al dejar pulsado
    Weather weather =
        await getWeatherByCoordinates(point.latitude, point.longitude);
    WeatherMarker weatherMarker = WeatherMarker(
      latitude: point.latitude,
      longitude: point.longitude,
      temperature: weather.temperature?.celsius?.round(),
      weatherMain: weather.weatherMain,
    );

    setState(() {
      weatherMarkers.add(weatherMarker);
    });
  }

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
    mapController = MapController();
    cityController = TextEditingController();
    mapStyle = 'mapbox/streets-v12';
    weatherFactory = WeatherFactory(API_KEY, language: Language.SPANISH);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: cityController,
                  decoration: InputDecoration(
                    labelText: 'Nombre de la ciudad',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                    border: null,
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (cityController.text.isNotEmpty) {
                  Weather weather = await getWeatherByCity(cityController.text);
                  showWeatherDialog(context, weather);
                }
              },
              child: Text('Obtener Clima'),
            ),
          ],
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: myPosition == null
          ? const CircularProgressIndicator()
          : FlutterMap(
              mapController: mapController,
              options: MapOptions(
                center: myPosition!,
                minZoom: 5,
                maxZoom: 25,
                zoom: 18,
                onLongPress: (tapPosition, point) {
                  _onLongPress(context, point);
                },
              ),
              nonRotatedChildren: [
                TileLayer(
                  urlTemplate:
                      'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                  additionalOptions: {
                    'accessToken': MAPBOX_ACCESS_TOKEN,
                    'id': mapStyle
                  },
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: myPosition!,
                      builder: (context) {
                        return Container(
                          child: const Icon(
                            Icons.person_pin,
                            color: Colors.blueAccent,
                            size: 40,
                          ),
                        );
                      },
                    ),
                    for (var marker in weatherMarkers)
                      Marker(
                        point: LatLng(marker.latitude!, marker.longitude!),
                        builder: (context) {
                          return Container(
                            child: Column(
                              children: [
                                Text(
                                  '${marker.temperature}°C',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.cloud,
                                  color: Colors.blue,
                                  size: 10,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ],
            ),
      floatingActionButton: AnimatedFloatingActionButton(
        fabButtons: <Widget>[
          FloatingActionButton(
            onPressed: () {
              setState(() {
                mapStyle = 'mapbox/streets-v12';
              });
            },
            tooltip: 'Streets View',
            child: const Icon(Icons.streetview),
          ),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                mapStyle = 'mapbox/light-v11';
              });
            },
            tooltip: 'Normal View',
            child: const Icon(Icons.map),
          ),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                mapStyle = 'mapbox/outdoors-v11';
              });
            },
            tooltip: 'Terrain View',
            child: const Icon(Icons.terrain),
          ),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                mapStyle = 'mapbox/satellite-streets-v11';
              });
            },
            tooltip: 'Hybrid View',
            child: const Icon(Icons.satellite),
          ),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapScreen(),
                ),
              );
            },
            tooltip: 'Ubicación actual',
            child: const Icon(Icons.my_location),
          ),
        ],
        colorStartAnimation: Colors.blue,
        colorEndAnimation: Colors.red,
        animatedIconData: AnimatedIcons.menu_close,
      ),
    );
  }

  Future<Weather> getWeatherByCity(String cityName) async {
    WeatherFactory wf = WeatherFactory(API_KEY, language: Language.SPANISH);
    return await wf.currentWeatherByCityName(cityName);
  }

  Future<Weather> getWeatherByCoordinates(
      double latitude, double longitude) async {
    WeatherFactory wf = WeatherFactory(API_KEY, language: Language.SPANISH);
    return await wf.currentWeatherByLocation(latitude, longitude);
  }

  void showWeatherDialog(BuildContext context, Weather weather) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clima en ${weather.areaName}'),
          content: Column(
            children: [
              Text('Temperatura: ${weather.temperature?.celsius?.round()}°C'),
              Text('Estado del tiempo: ${weather.weatherMain}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}

class WeatherMarker {
  final double? latitude;
  final double? longitude;
  final int? temperature;
  final String? weatherMain;

  WeatherMarker({
    required this.latitude,
    required this.longitude,
    required this.temperature,
    required this.weatherMain,
  });
}
