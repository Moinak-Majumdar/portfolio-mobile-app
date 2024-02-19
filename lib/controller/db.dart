import 'package:get/get.dart';

class DbController extends GetxController {
  RxBool isUsingTestDb = true.obs;

  Map<String, dynamic> apiQueryParamBase() {
    if (isUsingTestDb.value) {
      return {
        "dbAdmin": true,
        "testDb": true,
      };
    } else {
      return {
        "dbAdmin": true,
      };
    }
  }
}
