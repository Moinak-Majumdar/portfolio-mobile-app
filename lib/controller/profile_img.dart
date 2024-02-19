import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:portfolio/Hive/hive_user_data.dart';

const _boxName = "User";
const _boxId = "user_data";

class ProfileImgController extends GetxController {
  RxString profileImgPath = ''.obs;
  RxBool isProfileImgAvailable = false.obs;

  @override
  void onInit() async {
    final box = await Hive.openBox<HiveUserData>(_boxName);
    final item = box.get(_boxId);

    if (item == null) {
      await box.put(
        _boxId,
        HiveUserData(profileImgPath: ''),
      );
      isProfileImgAvailable.value = false;
      profileImgPath.value = '';
    } else {
      if (item.profileImgPath == '') {
        isProfileImgAvailable.value = false;
        profileImgPath.value = '';
      } else {
        isProfileImgAvailable.value = true;
        profileImgPath.value = item.profileImgPath;
      }
    }
    await box.close();

    super.onInit();
  }

  Future<void> changeProfileImg(String path) async {
    final box = await Hive.openBox<HiveUserData>(_boxName);
    await box.put(
      _boxId,
      HiveUserData(
        profileImgPath: path,
      ),
    );
    await box.close();

    profileImgPath.value = path;
    isProfileImgAvailable.value = true;
  }

  Future<void> removeProfileImg() async {
    final box = await Hive.openBox<HiveUserData>(_boxName);
    await box.put(
      _boxId,
      HiveUserData(
        profileImgPath: '',
      ),
    );
    await box.close();

    profileImgPath.value = '';
    isProfileImgAvailable.value = false;
  }
}
