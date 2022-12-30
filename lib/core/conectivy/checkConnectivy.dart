import 'package:connectivity_plus/connectivity_plus.dart';

class CheckConnectivy {
  Future<bool> checkConnectivy() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    bool result = false;
    if (connectivityResult == ConnectivityResult.wifi) {
      result = true;
    } else if (connectivityResult == ConnectivityResult.mobile) {
      result = true;
    }

    return result;
  }
}
