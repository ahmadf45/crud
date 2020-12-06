import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'calendar_model.dart';
import 'package:intl/intl.dart';

class CalendarHelper {
  static Database _db;
  static const String ID = 'id';
  static const String NAME = 'name';
  static const String TGL = 'tgl';
  static const String TABLE = 'Calendar';
  static const String DB_NAME = 'calendars.db';

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $TABLE ($ID INTEGER PRIMARY KEY, $NAME TEXT, $TGL INTEGER)");
  }

  Future<Calendar> save(Calendar calendar) async {
    var dbClient = await db;
    calendar.id = await dbClient.insert(TABLE, calendar.toMap());
    return calendar;
    /*
    await dbClient.transaction((txn) async {
      var query = "INSERT INTO $TABLE ($NAME) VALUES ('" + employee.name + "')";
      return await txn.rawInsert(query);
    });
    */
  }

  Future<List<Calendar>> getCalendars() async {
    int now = DateTime.tryParse(DateFormat('yyyy-MM-dd').format(DateTime.now()))
        .millisecondsSinceEpoch;

    var dbClient = await db;
    //List<Map> maps = await dbClient.query(TABLE, columns: [ID, NAME, TGL]);
    List<Map> maps =
        await dbClient.rawQuery("SELECT * FROM $TABLE WHERE $TGL >= $now");
    List<Calendar> calendars = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        calendars.add(Calendar.fromMap(maps[i]));
      }
    }
    return calendars;
  }

  Future<int> delete(int id) async {
    var dbClient = await db;
    return await dbClient.delete(TABLE, where: '$ID = ?', whereArgs: [id]);
  }

  Future<int> update(Calendar calendar) async {
    var dbClient = await db;
    return await dbClient.update(TABLE, calendar.toMap(),
        where: '$ID = ?', whereArgs: [calendar.id]);
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}
