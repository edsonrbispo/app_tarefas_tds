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
  Future<void> marcarSituacao(int index) async {
    final tarefa = tarefas[index];

    await DatabaseHelper.atualizarSituacao(
      tarefa['id'],
      tarefa['situacao'],
    );

    carregarTarefas();
  }

  //Remover Tarefa
  Future<void> removerTarefa(int index) async {
    final tarefa = tarefas[index];

    await DatabaseHelper.removerTarefa(tarefa['id']);

    carregarTarefas();
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
                'Nenhuma tarefa ainda. Toque em + para adicionar',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: tarefas.length,
              itemBuilder: (context, index) {
                final tarefa = tarefas[index];
                final bool situacao = tarefa['situacao'] == 1;

                // IMPLEMENTAÇÃO DO DESLIZAR PARA EXCLUIR
                return Dismissible(
                  // Chave única obrigatória usando o ID do banco
                  key: Key(tarefa['id'].toString()),

                  // Força o deslize apenas da direita para a esquerda
                  direction: DismissDirection.endToStart,

                  // Remove primeiro localmente para evitar erro visual de sincronia
                  onDismissed: (direction) async {
                    // Remove do banco de dados e recarrega
                    await removerTarefa(index);

                    // Feedback visual rápido na parte inferior da tela
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Tarefa excluída'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },

                  // Fundo vermelho com ícone de lixeira que surge no deslize
                  background: Container(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // Arredonda junto com o card
                    ),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),

                  // O seu Card original adaptado
                  child: Card(
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
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => adicionarTarefa(),
        child: Icon(Icons.add),
      ),
    );
  }
}
