import 'package:connectivity/connectivity.dart';
import 'package:get/get.dart';
import 'package:getx_hacker_news_api/app/data/local/local_database.dart';
import 'package:getx_hacker_news_api/app/data/network/api.dart';
import 'package:getx_hacker_news_api/app/services/articles_service.dart';

// setup services (dependencies) via Get service locator
Future<void> setupDependencies() async {
  // construct local database, api (data layer)
  final localDatabase = LocalDatabase();
  final api = Api();
  // wait for init database
  await localDatabase.initDb();
  // register ArticlesService
  Get.lazyPut<ArticlesService>(
      () => ArticlesService(localDatabase: localDatabase, api: api));
  // register Connectivity service
  Get.lazyPut<Connectivity>(() => Connectivity());
}
