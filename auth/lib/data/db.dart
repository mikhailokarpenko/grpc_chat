import 'package:stormberry/stormberry.dart';

late Database db;

Database initDatabase() => Database(
    debugPrint: true,
    port: 4500,
    password: 'mike',
    user: 'mike',
    useSSL: false);
