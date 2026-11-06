import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../geolocalizacion/zona_campus.dart';
import '../geolocalizacion/geolocalizacion_service.dart';
import 'camara_escaner_page.dart';
import 'aviso_ubicacion_page.dart';

// Perímetro de la UNA Puno (vértices en orden, medidos en Google Maps).
// Ideal: cargarlo desde la API (tabla zonas_campus). Si tu mapa del campus tiene
// más esquinas, agrega más puntos respetando el orden alrededor del perímetro.
const zonaUnaPuno = ZonaCampus(vertices: [
  PuntoGeo(-15.828183948756864, -70.01690239357274),
  PuntoGeo(-15.825370885616998, -70.01143820889554),
  PuntoGeo(-15.82382353978454, -70.01208191746507),
  PuntoGeo(-15.822156375426285, -70.01568763167512),
  PuntoGeo(-15.82145566996163, -70.01940498364026),
  PuntoGeo(-15.82304975876398, -70.01996250086003),
]);

// Para probar con el emulador (ubicación simulada) se desactiva el bloqueo solo en modo debug.
final geoService = GeolocalizacionService(
  zonaUnaPuno,
  bloquearUbicacionSimulada: !kDebugMode,
);

/// Se invoca al pulsar "Escanear alimento" (UC06).
/// La cámara solo se crea si la ubicación fue validada (RF05).
Future<void> onEscanearPressed(BuildContext context) async {
  final r = await geoService.validarUbicacion();

  // Registro para evidencias (P05, P06, P13). Quitar en producción.
  debugPrint('GPS -> estado=${r.estado.name} lat=${r.lat} lng=${r.lng} '
      'precision=${r.precisionM} distBorde=${r.distanciaBordeM}');

  if (!context.mounted) return;

  if (r.habilitaCamara) {
    // RF05 cumplido: recién ahora se accede a la cámara (RF07).
    final camaras = await availableCameras();
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CamaraEscanerPage(camara: camaras.first),
      ),
    );
  } else {
    // RF06: la cámara NO se crea; se muestra el aviso informativo.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AvisoUbicacionPage(mensaje: mensajeRF06(r)),
      ),
    );
  }
}

String mensajeRF06(ResultadoUbicacion r) => switch (r.estado) {
      EstadoUbicacion.fueraDelCampus =>
        'El escáner nutricional solo está disponible dentro del campus de la UNA Puno.',
      EstadoUbicacion.gpsDesactivado =>
        'Activa el GPS de tu dispositivo para usar el escáner.',
      EstadoUbicacion.permisoDenegado =>
        'Necesitamos el permiso de ubicación para verificar que estás en el campus.',
      EstadoUbicacion.permisoDenegadoPermanente =>
        'El permiso de ubicación está bloqueado. Habilítalo en Ajustes de la aplicación.',
      EstadoUbicacion.precisionInsuficiente =>
        'No se pudo determinar tu ubicación con precisión. Sal a un espacio abierto e inténtalo de nuevo.',
      EstadoUbicacion.ubicacionSimulada =>
        'Se detectó una ubicación simulada. Desactívala para continuar.',
      _ => 'No se pudo verificar tu ubicación. Inténtalo nuevamente.',
    };