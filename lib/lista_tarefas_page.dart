import 'package:flutter/material.dart';

class ListaTarefasPage extends StatelessWidget {
  const ListaTarefasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> tarefas = [
      {'titulo': 'Configuração do Ambiente', 'situacao': true},
      {'titulo': 'Fazer compras', 'situacao': false},
      {'titulo': 'Estudar Inglês', 'situacao': false},
      {'titulo': 'Fazer compras', 'situacao': true},
      {'titulo': 'Pagar a fatura', 'situacao': true},
      {'titulo': 'Sair as 22h10', 'situacao': false},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Minhas Tarefas"),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: tarefas.length,
        itemBuilder: (context, index) {
          final tarefa = tarefas[index];
          final bool situacao = tarefa['situacao'];

          return Card(
            margin: EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: Icon(
                situacao ? Icons.check_circle : Icons.circle_outlined,
                color: situacao ? Colors.green : Colors.grey,
              ),
              title: Text(
                tarefa['titulo'],
                style: TextStyle(
                  decoration: situacao
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              subtitle: Text(situacao ? 'Concluida' : 'Pendente'),
              trailing: Icon(
                Icons.delete_outline,
                color: Colors.grey,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        //shape: CircleBorder(),
        child: Icon(Icons.add),
      ),
    );
  }
}
