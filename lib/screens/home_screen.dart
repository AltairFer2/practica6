import 'dart:convert';
import 'dart:ui';

import 'package:clima/bloc/weather_bloc_bloc.dart';
import 'package:clima/database/location_db.dart';
import 'package:clima/models/location_model.dart';
import 'package:clima/screens/days_screen.dart';
import 'package:clima/screens/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:material_text_fields/material_text_fields.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _weatherData;
  String? _cityName;
  List<String> cityNames = [];

  @override
  void initState() {
    super.initState();
    _loadCityNames();
  }

  Widget getWeatherIcon(int code) {
    switch (code) {
      case >= 200 && < 300:
        return Image.asset('assets/1.png');
      case >= 300 && < 400:
        return Image.asset('assets/2.png');
      case >= 500 && < 600:
        return Image.asset('assets/3.png');
      case >= 600 && < 700:
        return Image.asset('assets/4.png');
      case >= 700 && < 800:
        return Image.asset('assets/5.png');
      case == 800:
        return Image.asset('assets/6.png');
      case > 800 && <= 804:
        return Image.asset('assets/7.png');
      default:
        return Image.asset('assets/7.png');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const UserAccountsDrawerHeader(
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
                ),
                accountName: Text('Víctor Fernando Sánchez Alvarado'),
                accountEmail: Text('20031003@itcelaya.edu.mx')),
            ListTile(
              title: Text('Mapa'),
              onTap: () {
                // Navega a map_screen.dart aquí
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapScreen(),
                  ),
                );
              },
              leading: const Icon(Icons.map),
            ),
            ListTile(
              title: Text('Recargar'),
              leading: const Icon(Icons.autorenew),
              onTap: () async {
                Navigator.pop(context); // Minimiza el Drawer
                // Obtener la posición actual
                Position currentPosition = await _determinePosition();

                // Disparar el evento de carga de datos con la nueva posición
                BlocProvider.of<WeatherBlocBloc>(context)
                    .add(FetchWeather(currentPosition));
              },
            ),
            ListTile(
              title: Text('Clima en 5 días'),
              onTap: () {
                // Navega a map_screen.dart aquí
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DayScreen(),
                  ),
                );
              },
              leading: const Icon(Icons.map),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(40, 1.2 * kToolbarHeight, 40, 20),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Align(
                alignment: AlignmentDirectional(3, -0.3),
                child: Container(
                  height: 300,
                  width: 300,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.deepPurple),
                ),
              ),
              Align(
                alignment: AlignmentDirectional(-3, -0.3),
                child: Container(
                  height: 300,
                  width: 300,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.deepPurple),
                ),
              ),
              Align(
                alignment: AlignmentDirectional(0, -1.2),
                child: Container(
                  height: 300,
                  width: 600,
                  decoration: BoxDecoration(color: Color(0xFFFFAB40)),
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
                child: Container(
                  decoration: BoxDecoration(color: Colors.transparent),
                ),
              ),
              BlocBuilder<WeatherBlocBloc, WeatherBlocState>(
                builder: (context, state) {
                  if (state is WeatherBlocSuccess) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '📍 ${state.weather.areaName}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          const Text(
                            'Good Morning',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold),
                          ),
                          getWeatherIcon(state.weather.weatherConditionCode!),
                          Center(
                            child: Text(
                              '${state.weather.temperature!.celsius!.round()} °C',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 55,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Center(
                            child: Text(
                              state.weather.weatherMain!.toUpperCase(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Center(
                            child: Text(
                              DateFormat('EEEE dd •')
                                  .add_jm()
                                  .format(state.weather.date!),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/11.png',
                                    scale: 8,
                                  ),
                                  const SizedBox(width: 5),
                                  const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Sunrise',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w300),
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                        '5:34 am',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/12.png',
                                    scale: 8,
                                  ),
                                  const SizedBox(width: 5),
                                  const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Sunset',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w300),
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                        '9:34 pm',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.0),
                            child: Divider(
                              color: Colors.grey,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/13.png',
                                    scale: 8,
                                  ),
                                  const SizedBox(width: 5),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Temp Max',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w300),
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                        '${state.weather.tempMax!.celsius!.round()} °C',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/14.png',
                                    scale: 8,
                                  ),
                                  const SizedBox(width: 5),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Temp Min',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w300),
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                        '${state.weather.tempMin!.celsius!.round()} °C',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        // Establece el color de fondo transparente
                        backgroundColor: Colors.transparent,
                      ),
                      child: FutureBuilder(
                        future: Future.delayed(Duration(seconds: 5)),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            // Después de 5 segundos, recargar la pantalla home_screen
                            return HomeScreen();
                          } else {
                            // Muestra un Container con un GIF mientras espera
                            return Container(
                              width: 480, // Ajusta según tus necesidades
                              height: 480, // Ajusta según tus necesidades
                              child: Image.asset('assets/loading.gif'),
                            );
                          }
                        },
                      ),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteCityDialog(String cityName) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Ciudad'),
          content: Text('¿Estás seguro de que deseas eliminar $cityName?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cierra el diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await _deleteCity(cityName);
                Navigator.pop(context); // Cierra el diálogo
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _showDatabaseCitiesDialog(BuildContext context) async {
    List<LocationModel> cities = await LocationDB().getLocations();

    String citiesText = '';
    for (LocationModel city in cities) {
      citiesText +=
          '${city.cityName}, Lat: ${city.latitude}, Lon: ${city.longitude}\n';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ciudades en la Base de Datos'),
          content: Text(citiesText),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cierra el diálogo
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadCityNames() async {
    try {
      List<LocationModel> locations = await LocationDB().getLocations();
      List<String> names =
          locations.map((location) => location.cityName).toList();
      setState(() {
        cityNames = names;
      });
    } catch (e) {
      print('Error al cargar nombres de ciudades: $e');
    }
  }

  Future<void> _deleteCity(String cityName) async {
    try {
      await LocationDB().deleteLocation(cityName);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ciudad eliminada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      _loadCityNames(); // Actualizar la lista después de eliminar
    } catch (e) {
      print('Error al eliminar ciudad: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar ciudad: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Los servicios de localización están desactivados.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error(
            'Los servicios de localización han sido denegados.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Los servicios de localización han sido denegados para siempre.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _showAddCityDialog(BuildContext context) {
    TextEditingController cityController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Añadir Ciudad'),
          content: MaterialTextField(
            controller: cityController,
            labelText: 'Nombre de la Ciudad',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cierra el diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                String cityName = cityController.text.trim();
                if (cityName.isNotEmpty) {
                  await _addCityToDatabase(cityName, context);
                  Navigator.pop(context); // Cierra el cajón de navegación
                  final position = await _determinePosition();
                  final weatherBloc = WeatherBlocBloc()
                    ..add(FetchWeather(position));
                  // ignore: use_build_context_synchronously
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          _buildHomeScreen(position, weatherBloc),
                    ),
                  );
                }
              },
              child: const Text('Añadir'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHomeScreen(Position position, WeatherBlocBloc bloc) {
    return BlocProvider.value(
      value: bloc,
      child: const HomeScreen(),
    );
  }

  Future<void> _addCityToDatabase(String cityName, BuildContext context) async {
    try {
      List<Location> locations = await locationFromAddress(cityName);
      if (locations.isNotEmpty) {
        Location location = locations[0];
        LocationModel newLocation = LocationModel(
          cityName: cityName,
          latitude: location.latitude!,
          longitude: location.longitude!,
        );
        await LocationDB().insertLocation(newLocation);
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Se insertó correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se encontró la ciudad: $cityName'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al añadir ciudad a la base de datos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<Map<String, dynamic>> getForecastData(
      double latitude, double longitude) async {
    final apiKey =
        '37dc66eac76ce609805ba132e8b6b700'; // Reemplaza con tu propia clave de API
    final apiUrl = 'https://api.openweathermap.org/data/2.5/forecast';

    final response = await http.get(
      Uri.parse('$apiUrl?lat=$latitude&lon=$longitude&appid=$apiKey'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception(
          'Error al cargar datos de pronóstico: ${response.statusCode}');
    }
  }

  Future<void> _updateWeatherData(String city) async {
    try {
      List<Location> locations = await locationFromAddress(city);
      if (locations.isNotEmpty) {
        Location location = locations[0];
        final forecastData = await getForecastData(
          location.latitude!,
          location.longitude!,
        );

        setState(() {
          _weatherData = forecastData; // Assuming forecastData is a Map
          _cityName = _weatherData!['city']['name'];
        });
      } else {
        print('No se encontró la ciudad: $city');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
