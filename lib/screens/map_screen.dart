import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

// ignore: constant_identifier_names
const MAPBOX_ACCESS_TOKEN =
    'pk.eyJ1IjoicGl0bWFjIiwiYSI6ImNsY3BpeWxuczJhOTEzbnBlaW5vcnNwNzMifQ.ncTzM4bW-jpq-hUFutnR1g';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late String mapStyle;
  late MapController mapController;
  late LatLng actual;
  LatLng? myPosition;

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

  void getCurrentLocation() async {
    Position position = await determinePosition();
    setState(() {
      myPosition = LatLng(position.latitude, position.longitude);   
      actual = LatLng(position.latitude, position.longitude);   
    });
  }

   void _moveToCurrentLocation() async {
    print('Moviendo a la ubicación actual');
    await getCurrentLocation;
    _updateMapPosition();
  }


   void _updateMapPosition() {
    setState(() {
      // Actualiza la posición del centro del mapa a la ubicación actual
      actual = LatLng(actual.latitude, actual.longitude);
    });
  }

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
    mapController = MapController();
    
    mapStyle = 'mapbox/streets-v12';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Mapa'),
        backgroundColor: Colors.blueAccent,
      ),
      body: myPosition == null
          ? const CircularProgressIndicator()
          : FlutterMap(
              options: MapOptions(
                  center: myPosition, minZoom: 5, maxZoom: 25, zoom: 18),
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
                    )
                  ],
                )
              ],
            ),
	floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              // Cambia al estilo 'mapbox/streets-v12'
              setState(() {
                mapStyle = 'mapbox/streets-v12';
              });
            },
            tooltip: 'Streets View',
            child: const Icon(Icons.streetview),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              // Cambia al estilo 'mapbox/light-v11' (Normal)
              setState(() {
                mapStyle = 'mapbox/light-v11';
              });
            },
            tooltip: 'Normal View',
            child: const Icon(Icons.map),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              // Cambia al estilo 'mapbox/outdoors-v11' (Terreno)
              setState(() {
                mapStyle = 'mapbox/outdoors-v11';
              });
            },
            tooltip: 'Terrain View',
            child: const Icon(Icons.terrain),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              // Cambia al estilo 'mapbox/satellite-streets-v11' (Híbrida)
              setState(() {
                mapStyle = 'mapbox/satellite-streets-v11';
              });
            },
            tooltip: 'Hybrid View',
            child: const Icon(Icons.satellite),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              _moveToCurrentLocation();              
            },
            tooltip: 'Ubicación actual',
            child: const Icon(Icons.my_location),
          ),                   
        ],
      ),
    );
  }
}