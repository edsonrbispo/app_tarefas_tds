import 'package:flutter/material.dart';

class ListaTarefasPage extends StatelessWidget {
  const ListaTarefasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Minhas Tarefas"),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(12),
        children: [
          Card(
            margin: EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              title: Text(
                'Configurar o Ambiente de Desenvolvimento',
                style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              subtitle: Text('Concluida'),
              trailing: Icon(
                Icons.delete_outline,
                color: Colors.grey,
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: Icon(
                Icons.circle_outlined,
                color: Colors.grey,
              ),
              title: Text(
                'Cria projeto em Flutter',
              ),
              subtitle: Text('Pendente'),
              trailing: Icon(
                Icons.delete_outline,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
