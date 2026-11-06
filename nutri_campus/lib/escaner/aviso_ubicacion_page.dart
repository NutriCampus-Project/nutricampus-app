import 'package:flutter/material.dart';

/// Pantalla de aviso de ubicación (RF06).
class AvisoUbicacionPage extends StatelessWidget {
  final String mensaje;
  const AvisoUbicacionPage({super.key, required this.mensaje});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Ubicación no válida')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_off, size: 64),
                const SizedBox(height: 16),
                Text(mensaje, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Volver'),
                ),
              ],
            ),
          ),
        ),
      );
}