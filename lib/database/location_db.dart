import 'dart:async';
import 'package:clima/models/location_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocationDB {
  static final LocationDB _instance = LocationDB._internal();

  factory LocationDB() => _instance;

  static Database? _database;

  LocationDB._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    final String path = join(await getDatabasesPath(), 'locations.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE locations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cityName TEXT UNIQUE,
            latitude REAL,
            longitude REAL
          )
        ''');
      },
    );
  }

  Future<void> insertLocation(LocationModel location) async {
    final db = await database;
    await db.insert('locations', location.toMap());
  }

  Future<List<LocationModel>> getLocations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('locations');
    return List.generate(maps.length, (i) {
      return LocationModel.fromMap(maps[i]);
    });
  }

  Future<List<String>> getCityNames() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('locations', columns: ['cityName']);
    return List.generate(maps.length, (i) {
      return maps[i]['cityName'] as String;
    });
  }

  Future<void> deleteLocation(String cityName) async {
    final db = await database;
    await db.delete(
      'locations',
      where: 'cityName = ?',
      whereArgs: [cityName],
    );
  }
}
