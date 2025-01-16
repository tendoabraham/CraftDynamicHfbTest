import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:craft_dynamic/craft_dynamic.dart';
// import 'package:flutter/foundation.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamController<ConnectivityResult> connectionStatusController =
      StreamController<ConnectivityResult>();

  Future<void> initialize() async {
    ConnectivityResult result = await _connectivity.checkConnectivity();
    connectionStatusController.add(result);

    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      AppLogger.appLogD(
          tag: "connection changed", message: "connection state has changed");
      connectionState.value = result;
      connectionStatusController.add(result);
    });
  }

  void dispose() {
    connectionStatusController.close();
  }
}

// class ConnectivityService {
//   final Connectivity _connectivity = Connectivity();
//   final StreamController<ConnectivityResult> connectionStatusController =
//       StreamController<ConnectivityResult>();

//   ValueNotifier<ConnectivityResult> connectionState =
//       ValueNotifier<ConnectivityResult>(ConnectivityResult.none);

//   Future<void> initialize() async {
//     // Check connectivity, assuming it may return a list of results
//     dynamic result = await _connectivity.checkConnectivity();

//     // Handle cases where the result is a list of ConnectivityResult
//     if (result is List<ConnectivityResult> && result.isNotEmpty) {
//       ConnectivityResult primaryResult = result.first; // Use the first result
//       connectionStatusController.add(primaryResult);
//       connectionState.value = primaryResult;
//     } else if (result is ConnectivityResult) {
//       // Handle older behavior where it returned a single ConnectivityResult
//       connectionStatusController.add(result);
//       connectionState.value = result;
//     }

//     // Listen to connectivity changes
//     _connectivity.onConnectivityChanged.listen((dynamic result) {
//       if (result is List<ConnectivityResult> && result.isNotEmpty) {
//         ConnectivityResult primaryResult = result.first;
//         AppLogger.appLogD(
//             tag: "connection changed", message: "connection state has changed");
//         connectionState.value = primaryResult;
//         connectionStatusController.add(primaryResult);
//       } else if (result is ConnectivityResult) {
//         AppLogger.appLogD(
//             tag: "connection changed", message: "connection state has changed");
//         connectionState.value = result;
//         connectionStatusController.add(result);
//       }
//     });
//   }

//   void dispose() {
//     connectionStatusController.close();
//   }
// }
