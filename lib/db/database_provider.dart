import 'package:path/path.dart';
import 'package:riverpodcrud/models/note.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  static final DatabaseProvider instance = DatabaseProvider._init();
  static Database? _db;

  //o banco de dados sera iniciado na instancia da classe
  DatabaseProvider._init();

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _useDatabase('notes.db');
    return _db!;
  }

  Future<Database> _useDatabase(String filePath) async {
    final dbPath = await getDatabasesPath();
    // Descomentar as duas linhas abaixo para apagar a base de dados
    // String path = join(dbPath, 'notes.db');
    // await deleteDatabase(path);
    // Retorna o banco de dados aberto
    return await openDatabase(
      join(dbPath, 'notes.db'),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE notes (id INTEGER PRIMARY KEY, title TEXT, content TEXT)');
      },
      version: 1,
    );
  }

  // buscar todos as notas
  Future<List<Note>> buscarNotas() async {
    final db = await instance.db;
    final result = await db.rawQuery('SELECT * FROM notes ORDER BY id');
    // print(result);
    return result.map((json) => Note.fromJson(json)).toList();
  }

  //criar nova nota
  Future<Note> save(Note note) async {
    final db = await instance.db;
    final id = await db.rawInsert(
        'INSERT INTO notes (title, content) VALUES (?,?)',
        [note.title, note.content]);

    print(id);
    return note.copy(id: id);
  }

  //atualizar nota
  Future<Note> update(Note note) async {
    final db = await instance.db;
    final id = await db.rawUpdate(
        'UPDATE notes SET title = ?, content = ? WHERE id = ?',
        [note.title, note.content, note.id]);

    print(id);
    return note.copy(id: id);
  }

  //excluir notas
  Future<int> deleteAll() async {
    final db = await instance.db;
    final result = await db.rawDelete('DELETE FROM notes');
    print(result);
    return result;
  }

  //excluir nota
  Future<int> delete(int noteId) async {
    final db = await instance.db;
    final id = await db.rawDelete('DELETE FROM notes WHERE id = ?', [noteId]);
    print(id);
    return id;
  }

  //fechar conexao com o banco de dados, funcao nao usada nesse app
  Future close() async {
    final db = await instance.db;
    db.close();
  }
}
