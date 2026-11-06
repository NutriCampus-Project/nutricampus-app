import 'dart:math' as math;

/// Punto geográfico (latitud, longitud) en grados decimales.
class PuntoGeo {
  final double lat;
  final double lng;
  const PuntoGeo(this.lat, this.lng);
}

/// Perímetro del campus de la UNA Puno (clase ZonaCampus del diseño).
/// Resuelve la condición espacial de RF05/RF06 y el margen de RNF03.
class ZonaCampus {
  /// Vértices del polígono, en orden (horario o antihorario).
  final List<PuntoGeo> vertices;

  /// Margen de tolerancia en metros (RNF03: 15 m).
  final double margenMetros;

  const ZonaCampus({required this.vertices, this.margenMetros = 15.0});

  // Metros por grado de latitud (aprox. esférica; suficiente a escala de campus).
  static const double _metrosPorGrado = 111195.0;

  /// Ray casting: true si (lat, lng) está estrictamente dentro del polígono.
  bool contiene(double lat, double lng) {
    var dentro = false;
    for (var i = 0, j = vertices.length - 1; i < vertices.length; j = i++) {
      final a = vertices[i];
      final b = vertices[j];
      final cruza = (a.lat > lat) != (b.lat > lat) &&
          lng < (b.lng - a.lng) * (lat - a.lat) / (b.lat - a.lat) + a.lng;
      if (cruza) dentro = !dentro;
    }
    return dentro;
  }

  /// Distancia mínima (en metros) del punto al borde del polígono.
  double distanciaAlBordeM(double lat, double lng) {
    final kx = _metrosPorGrado * math.cos(lat * math.pi / 180);
    const ky = _metrosPorGrado;
    var minimo = double.infinity;

    for (var i = 0; i < vertices.length; i++) {
      final a = vertices[i];
      final b = vertices[(i + 1) % vertices.length];

      // Coordenadas planas locales en metros, con el punto como origen.
      final ax = (a.lng - lng) * kx;
      final ay = (a.lat - lat) * ky;
      final bx = (b.lng - lng) * kx;
      final by = (b.lat - lat) * ky;

      final dx = bx - ax;
      final dy = by - ay;
      final len2 = dx * dx + dy * dy;
      final t = len2 == 0
          ? 0.0
          : (-(ax * dx + ay * dy) / len2).clamp(0.0, 1.0).toDouble();

      final px = ax + t * dx;
      final py = ay + t * dy;
      minimo = math.min(minimo, math.sqrt(px * px + py * py));
    }
    return minimo;
  }

  /// Dentro del polígono o a ≤ margenMetros de su borde.
  bool permiteUbicacion(double lat, double lng) =>
      contiene(lat, lng) || distanciaAlBordeM(lat, lng) <= margenMetros;
}