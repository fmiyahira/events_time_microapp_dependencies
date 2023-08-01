import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class SembastImpl {
  Future<Database> openDatabase() async {
    final Directory databasesPath = await getApplicationSupportDirectory();

    final String dbPath = '${databasesPath.path}/database/local.db';
    final DatabaseFactory dbFactory = databaseFactoryIo;

    return dbFactory.openDatabase(dbPath);
  }
}
