import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StateController extends GetxController {
  final _token = GetStorage().read('token')?.toString().obs ?? "".obs;
  set token(String token) {
    _token.value = token;
    update();
  }

  String get token => _token.value.toString();

  final _serverIp = GetStorage().read('server_ip')?.toString().obs ?? "".obs;
  set serverIp(String serverIp) {
    _serverIp.value = serverIp;
    update();
  }

  String get serverIp => _serverIp.value.toString();
}
