import 'package:flutter/material.dart';
import '../escaner/escaner_gate.dart';

/// EJEMPLO de la pantalla "Menú del día". No reemplaces la tuya:
/// solo copia el botón y su onPressed en tu pantalla real.
class MenuDiaPageEjemplo extends StatelessWidget {
  const MenuDiaPageEjemplo({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Menú del día')),
        body: const Center(child: Text('Aquí va el menú vigente (RF04)')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => onEscanearPressed(context),
          icon: const Icon(Icons.camera_alt),
          label: const Text('Escanear alimento'),
        ),
      );
}