import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Pantalla de la cámara del escáner (RF07).
/// Solo se llega aquí después de validar el GPS (RF05).
class CamaraEscanerPage extends StatefulWidget {
  final CameraDescription camara;
  const CamaraEscanerPage({super.key, required this.camara});

  @override
  State<CamaraEscanerPage> createState() => _CamaraEscanerPageState();
}

class _CamaraEscanerPageState extends State<CamaraEscanerPage> {
  late final CameraController _controller;
  late final Future<void> _init;

  @override
  void initState() {
    super.initState();
    // El controlador se crea aquí: la cámara no se inicializa antes de validar la ubicación.
    _controller = CameraController(widget.camara, ResolutionPreset.medium);
    _init = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Escáner nutricional')),
        body: FutureBuilder<void>(
          future: _init,
          builder: (_, snap) {
            if (snap.hasError) {
              return const Center(child: Text('No se pudo abrir la cámara.'));
            }
            return snap.connectionState == ConnectionState.done
                ? CameraPreview(_controller)
                : const Center(child: CircularProgressIndicator());
          },
        ),
      );
}