import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _db;

  //Getter que devolve o banco de dados já aberto, ou abre se ainda não exite
  static Future<Database> get database async {
    _db ??= await abrirBanco();
    return _db!;
  }

  //Abre (ou cria, se não existir) o arquivo do banco de dados
  static Future<Database> abrirBanco() async {
    final caminho = join(await getDatabasesPath(), 'tarefas.db');

    return openDatabase(
      caminho,
      version: 1,
      onCreate: (db, versao) {
        return db.execute(
          'CREATE TABLE tarefas ('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'titulo TEXT, '
          'situacao INTEGER)', //0, 1
        );
      },
    );
  }

  //READ: Buscar/Listar todas as tarefas salvas no banco de dados
  static Future<List<Map<String, dynamic>>> buscarTarefas() async {
    final db = await DatabaseHelper.database;
    return db.query('tarefas'); // SELECT * FROM tarefas
  }

  //CREATE: Inserir tarefa no banco de dados
  static Future<void> inserirTarefa(String titulo) async {
    final db = await DatabaseHelper.database;
    await db.insert('tarefas', {
      'titulo': titulo,
      'situacao': 0, //0 = False, 1 = Verdadeiro (SQLite não tem Boolean)
    });
  }
}
