import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'zona_campus.dart';

/// Resultados posibles de la validación de ubicación (RF05 / RF06).
enum EstadoUbicacion {
  dentroDelCampus,
  fueraDelCampus,
  gpsDesactivado,
  permisoDenegado,
  permisoDenegadoPermanente,
  precisionInsuficiente,
  ubicacionSimulada,
  error,
}

class ResultadoUbicacion {
  final EstadoUbicacion estado;
  final double? lat;
  final double? lng;
  final double? precisionM;
  final double? distanciaBordeM;

  const ResultadoUbicacion(
    this.estado, {
    this.lat,
    this.lng,
    this.precisionM,
    this.distanciaBordeM,
  });

  /// La cámara solo se habilita si la ubicación fue validada dentro del campus.
  bool get habilitaCamara => estado == EstadoUbicacion.dentroDelCampus;
}

/// Módulo Geolocalización: obtiene el GPS y valida el perímetro (RF05, RNF03).
class GeolocalizacionService {
  final ZonaCampus zona;

  /// En pruebas con emulador (ubicación simulada) se pasa false.
  final bool bloquearUbicacionSimulada;

  GeolocalizacionService(this.zona, {this.bloquearUbicacionSimulada = true});

  Future<ResultadoUbicacion> validarUbicacion() async {
    try {
      // 1. ¿Servicio GPS activo?
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const ResultadoUbicacion(EstadoUbicacion.gpsDesactivado);
      }

      // 2. Permisos de ubicación
      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }
      if (permiso == LocationPermission.denied) {
        return const ResultadoUbicacion(EstadoUbicacion.permisoDenegado);
      }
      if (permiso == LocationPermission.deniedForever) {
        return const ResultadoUbicacion(
            EstadoUbicacion.permisoDenegadoPermanente);
      }

      // 3. Coordenadas actuales (máxima precisión, límite de 10 s)
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // 4. Lecturas no confiables
      if (bloquearUbicacionSimulada && pos.isMocked) {
        return const ResultadoUbicacion(EstadoUbicacion.ubicacionSimulada);
      }
      if (pos.accuracy > zona.margenMetros) {
        return ResultadoUbicacion(
          EstadoUbicacion.precisionInsuficiente,
          lat: pos.latitude,
          lng: pos.longitude,
          precisionM: pos.accuracy,
        );
      }

      // 5. Condición espacial (RNF03)
      final distancia = zona.distanciaAlBordeM(pos.latitude, pos.longitude);
      final permitido = zona.permiteUbicacion(pos.latitude, pos.longitude);

      return ResultadoUbicacion(
        permitido
            ? EstadoUbicacion.dentroDelCampus
            : EstadoUbicacion.fueraDelCampus,
        lat: pos.latitude,
        lng: pos.longitude,
        precisionM: pos.accuracy,
        distanciaBordeM: distancia,
      );
    } on TimeoutException {
      return const ResultadoUbicacion(EstadoUbicacion.error);
    } catch (_) {
      return const ResultadoUbicacion(EstadoUbicacion.error);
    }
  }
}