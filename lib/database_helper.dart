import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _db;

  //Abre (ou cria, se não existir) o arquivo do banco de dados
  static Future<Database> abrirBanco() async {
    final caminho = join(await getDatabasesPath(), 'tarefas.db');

    return openDatabase(
      caminho,
      version: 2,
      onCreate: (db, versao) {
        return db.execute(
          'CREATE TABLE tarefas ('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'titulo TEXT, '
          'situacao INTEGER,' //0, 1
          'categoria TEXT)',
        );
      },
      onUpgrade: (db, versaoAntiga, versaoNova) {
        if (versaoAntiga < 2) {
          db.execute('ALTER TABLE tarefas ADD COLUMN categoria TEXT');
        }
      },
    );
  }

  //Getter que devolve o banco de dados já aberto, ou abre se ainda não exite
  static Future<Database> get database async {
    _db ??= await abrirBanco();
    return _db!;
  }

  //READ: Buscar/Listar todas as tarefas salvas no banco de dados
  static Future<List<Map<String, dynamic>>> buscarTarefas({
    String? filtro,
  }) async {
    final db = await DatabaseHelper.database;

    if (filtro == 'pendentes') {
      // SELECT * FROM tarefas WHERE situacao = 0
      return db.query(
        'tarefas',
        where: 'situacao = 0',
      );
    } else if (filtro == 'concluidas') {
      // SELECT * FROM tarefas WHERE situacao = 1
      return db.query(
        'tarefas',
        where: 'situacao = 1',
      );
    }
    return db.query('tarefas');
  }

  //CREATE: Inserir tarefa no banco de dados
  static Future<void> inserirTarefa(String titulo, String categoria) async {
    final db = await DatabaseHelper.database;
    await db.insert('tarefas', {
      'titulo': titulo,
      'situacao': 0,
      'categoria': categoria,
    });
  }

  //UPDATE: Alterar o campo marcado da tarefa
  static Future<void> atualizarSituacao(int id, int situacao) async {
    final db = await DatabaseHelper.database;
    await db.update(
      'tarefas',
      {'situacao': situacao == 1 ? 0 : 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //DELETE: Remover uma tarefa
  static Future<void> removerTarefa(int id) async {
    final db = await DatabaseHelper.database;
    await db.delete(
      'tarefas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
