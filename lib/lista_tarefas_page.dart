import 'package:app_tarefas/database_helper.dart';
import 'package:flutter/material.dart';

class ListaTarefasPage extends StatefulWidget {
  const ListaTarefasPage({super.key});

  @override
  State<ListaTarefasPage> createState() => _ListaTarefasPageState();
}

class _ListaTarefasPageState extends State<ListaTarefasPage> {
  List<Map<String, dynamic>> tarefas = [];

  @override
  void initState() {
    super.initState();
    carregarTarefas();
  }

  void carregarTarefas() async {
    final dados = await DatabaseHelper.buscarTarefas();
    setState(() {
      tarefas = dados;
    });
  }

  //Marcar Tarefa como Concluida/Pendente
  void marcarSituacao(int index) {
    setState(() {
      tarefas[index]['situacao'] = !tarefas[index]['situacao'];
    });
  }

  //Remover Tarefa
  void removerTarefa(int index) {
    setState(() {
      tarefas.removeAt(index);
    });
  }

  //Adicionar Tarefa
  void adicionarTarefa() {
    final adicionarController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Nova Tarefa'),
          content: TextField(
            controller: adicionarController,
            decoration: InputDecoration(hintText: "Digite sua tarefa..."),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (adicionarController.text.isNotEmpty) {
                  await DatabaseHelper.inserirTarefa(adicionarController.text);

                  carregarTarefas();

                  if (!context.mounted) return;

                  Navigator.pop(context);
                }
              },
              child: Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Minhas Tarefas"),
        centerTitle: true,
      ),
      body: tarefas.isEmpty
          ? Center(
              child: Text(
                'Nenhuma Tarefa Encontrada',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: tarefas.length,
              itemBuilder: (context, index) {
                final tarefa = tarefas[index];
                final bool situacao = tarefa['situacao'] == 1;

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: GestureDetector(
                      onTap: () => marcarSituacao(index),
                      child: Icon(
                        situacao ? Icons.check_circle : Icons.circle_outlined,
                        color: situacao ? Colors.green : Colors.grey,
                      ),
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
                    trailing: GestureDetector(
                      onTap: () => removerTarefa(index),
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => adicionarTarefa(),
        //shape: CircleBorder(),
        child: Icon(Icons.add),
      ),
    );
  }
}
