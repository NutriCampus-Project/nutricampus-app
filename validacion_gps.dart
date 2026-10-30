class ZonaCampus {
  final double latMin = -15.8295;
  final double latMax = -15.8210;
  final double lngMin = -70.0210;
  final double lngMax = -70.0120;
  Map<String, dynamic> validarPerimetroCampus(double latitud, double longitud) {
    if (latitud < -90 || latitud > 90 || longitud < -180 || longitud > 180) {
      return {'escaner_activo': false, 'mensaje': 'Coordenadas GPS inválidas.'};
    }

    bool dentroCampus = (latitud >= latMin && latitud <= latMax) &&
        (longitud >= lngMin && longitud <= lngMax);

    if (dentroCampus) {
      return {
        'escaner_activo': true,
        'estado': 'DENTRO_DEL_CAMPUS',
        'mensaje': 'Ubicación validada en Campus UNA Puno. Cámara habilitada.'
      };
    } else {
      return {
        'escaner_activo': false,
        'estado': 'FUERA_DEL_CAMPUS',
        'mensaje': 'Fuera del perímetro de la UNA Puno. El escáner nutricional está restringido.'
      };
    }
  }
}
void main() {
  final zona = ZonaCampus();
  print('CASO VALIDO (DENTRO DEL CAMPUS)');
  print(zona.validarPerimetroCampus(-15.8245, -70.0162));

  print('\nCASO INVALIDO (FUERA DEL CAMPUS)');
  print(zona.validarPerimetroCampus(-15.8402, -70.0219));
}