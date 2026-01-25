import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class INetworkInfo {
  Future<bool> get isConnected;
}

//provider 
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  // final connectivity = ref.watch(connectivityProvider);
  return NetworkInfo(Connectivity());
});
class NetworkInfo implements INetworkInfo {
  final Connectivity _connectivity;
  NetworkInfo(this._connectivity);
  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity(); //wifi or mobile
    if(result.contains(ConnectivityResult.none)){
      return false;
    }

    return await _sacchaiInternetChakiNai() ; // Placeholder return value
  }

  Future<bool> _sacchaiInternetChakiNai() async{
    try{
      final result= await InternetAddress.lookup("google.com");
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    }
  
  on SocketException {
      return false;
    }
  }
  
}