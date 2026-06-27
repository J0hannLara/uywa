import 'package:flutter/material.dart';

class CompleteProfilePage
    extends StatelessWidget {

  const CompleteProfilePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Completa tu perfil',
        ),
      ),

      body: const Center(
        child: Text(
          'Formulario perfil',
        ),
      ),
    );
  }
}