import 'package:flutter_test/flutter_test.dart';
// Si tu paquete no se llama nutri_campus, cambia este import (revisa "name:" en pubspec.yaml).
import 'package:nutri_campus/geolocalizacion/zona_campus.dart';

void main() {
  const zona = ZonaCampus(vertices: [
    PuntoGeo(-15.828183948756864, -70.01690239357274),
    PuntoGeo(-15.825370885616998, -70.01143820889554),
    PuntoGeo(-15.82382353978454, -70.01208191746507),
    PuntoGeo(-15.822156375426285, -70.01568763167512),
    PuntoGeo(-15.82145566996163, -70.01940498364026),
    PuntoGeo(-15.82304975876398, -70.01996250086003),
  ]);

  test('P05: punto dentro del campus (centro)', () {
    expect(zona.contiene(-15.824007, -70.015913), isTrue);
    expect(zona.permiteUbicacion(-15.824007, -70.015913), isTrue);
  });

  test('P06: punto fuera del campus (~1.3 km)', () {
    expect(zona.permiteUbicacion(-15.8400, -70.0170), isFalse);
  });

  test('P13: margen de 15 m en el borde (arista sureste)', () {
    // 5 m dentro del borde
    expect(zona.permiteUbicacion(-15.826738, -70.014192), isTrue);
    // 10 m fuera del borde: dentro del margen de 15 m
    expect(zona.permiteUbicacion(-15.826857, -70.014126), isTrue);
    // 25 m fuera del borde: fuera del margen
    expect(zona.permiteUbicacion(-15.826976, -70.014060), isFalse);
  });
}