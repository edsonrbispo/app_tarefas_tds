import 'package:app_tarefas/database_helper.dart';
import 'package:app_tarefas/sobre_page.dart';
import 'package:flutter/material.dart';

class ListaTarefasPage extends StatefulWidget {
  const ListaTarefasPage({super.key});

  @override
  State<ListaTarefasPage> createState() => _ListaTarefasPageState();
}

class _ListaTarefasPageState extends State<ListaTarefasPage> {
  List<Map<String, dynamic>> tarefas = [];
  String? filtroAtual;

  static const categorias = ['Pessoal', 'Trabalho', 'Estudo', 'Compras'];

  @override
  void initState() {
    super.initState();
    carregarTarefas();
  }

  void carregarTarefas() async {
    final dados = await DatabaseHelper.buscarTarefas(filtro: filtroAtual);
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

  //Mudar Filtro dos dados = Todas, Pendente e Concluída
  void aplicarFiltro(String? novoFiltro) {
    filtroAtual = novoFiltro;
    Navigator.pop(context);
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
    String categoriaEscolhida = categorias.first;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Nova Tarefa'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: adicionarController,
                    decoration: InputDecoration(
                      hintText: "Digite sua tarefa...",
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),

                  DropdownButton<String>(
                    value: categoriaEscolhida,
                    isExpanded: true,
                    items: categorias.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      );
                    }).toList(),

                    onChanged: (novaCategoria) {
                      setStateDialog(() {
                        categoriaEscolhida = novaCategoria!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () async {
                    if (adicionarController.text.isNotEmpty) {
                      await DatabaseHelper.inserirTarefa(
                        adicionarController.text,
                        categoriaEscolhida,
                      );

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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo),
              child: Text(
                "Minhas Tarefas",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('Todas as Tarefas'),
              selected: filtroAtual == null,
              selectedColor: Colors.indigo,
              onTap: () => aplicarFiltro(null),
            ),
            ListTile(
              leading: Icon(Icons.pending_actions),
              title: Text('Pendentes'),
              selected: filtroAtual == 'pendentes',
              selectedColor: Colors.indigo,
              onTap: () => aplicarFiltro('pendentes'),
            ),
            ListTile(
              leading: Icon(Icons.check_circle_outline),
              title: Text('Concluídas'),
              selected: filtroAtual == 'concluidas',
              selectedColor: Colors.indigo,
              onTap: () => aplicarFiltro('concluidas'),
            ),
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Sobre o Aplicativo'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SobrePage(),
                  ),
                );
              },
            ),
          ],
        ),
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
                final String categoria = tarefa['categoria'] ?? 'Sem Categoria';

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
                      subtitle: Text(
                        '${situacao ? 'Concluida' : 'Pendente'} - $categoria',
                      ),
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
