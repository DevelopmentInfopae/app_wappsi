import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';

// Helper para verificar conexión real (no solo WiFi conectado)
class ConnectionHelper {
  // Lo hacemos estático para no tener que instanciar la clase
  static Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      
      // Si ni siquiera hay señal de red, retornamos false de inmediato
      if (connectivityResult == ConnectivityResult.none) return false;

      // Verificación real mediante DNS
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
          
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}