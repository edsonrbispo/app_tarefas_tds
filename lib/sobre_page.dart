import 'package:flutter/material.dart';

class SobrePage extends StatelessWidget {
  const SobrePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sobre o Aplicativo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/img/logo.png',
              width: 120,
              height: 120,
            ),
            SizedBox(
              height: 20,
            ),
            Text('Este é uma aplicativo para que controle suas tarefas.'),
            SizedBox(
              height: 20,
            ),
            Text('Versão 1.0'),
          ],
        ),
      ),
    );
  }
}
