import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('travel_app_completo_v2.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE utenti (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        email TEXT NOT NULL,
        eta INTEGER NOT NULL,
        valuta TEXT NOT NULL,
        fotoProfilo TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE viaggi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titolo TEXT NOT NULL,
        luogo TEXT NOT NULL,
        dataInizio TEXT NOT NULL,
        dataFine TEXT NOT NULL,
        budgetPrevisto REAL,
        note TEXT,
        idUtente INTEGER NOT NULL,
        FOREIGN KEY (idUtente) REFERENCES utenti (id) ON DELETE CASCADE
      )
    ''');
    
    await db.execute('''
      CREATE TABLE spese (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titolo TEXT NOT NULL,
        importo REAL NOT NULL,
        data TEXT NOT NULL,
        idViaggio INTEGER NOT NULL,
        FOREIGN KEY (idViaggio) REFERENCES viaggi (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE tappe (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titolo TEXT NOT NULL,
        data TEXT,
        ora TEXT,
        descrizione TEXT,
        costoPrevisto REAL,
        idViaggio INTEGER NOT NULL,
        FOREIGN KEY (idViaggio) REFERENCES viaggi (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE checklist (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titolo TEXT NOT NULL,
        idViaggio INTEGER NOT NULL,
        FOREIGN KEY (idViaggio) REFERENCES viaggi (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE checklist_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nomeItem TEXT NOT NULL,
        isCompletato INTEGER NOT NULL DEFAULT 0,
        idChecklist INTEGER NOT NULL,
        FOREIGN KEY (idChecklist) REFERENCES checklist (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE packlist (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titolo TEXT NOT NULL,
        idViaggio INTEGER NOT NULL,
        FOREIGN KEY (idViaggio) REFERENCES viaggi (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE packlist_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nomeItem TEXT NOT NULL,
        isImballato INTEGER NOT NULL DEFAULT 0,
        idPacklist INTEGER NOT NULL,
        FOREIGN KEY (idPacklist) REFERENCES packlist (id) ON DELETE CASCADE
      )
    ''');
  }

  // --- METODI CRUD UNIVERSALI ---

  // INSERIMENTO: Restituisce l'ID del nuovo record creato
  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert(table, row);
  }

  // LETTURA: Restituisce tutte le righe di una tabella (filtrabili)
  Future<List<Map<String, dynamic>>> queryAllRows(String table, {String? where, List<dynamic>? whereArgs}) async {
    final db = await instance.database;
    return await db.query(table, where: where, whereArgs: whereArgs);
  }

  // ELIMINAZIONE
  Future<int> delete(String table, {required String where, required List<dynamic> whereArgs}) async {
    final db = await instance.database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  // AGGIORNAMENTO
  Future<int> update(String table, Map<String, dynamic> row, {required List<int> whereArgs, required String where}) async {
    final db = await instance.database;
    int id = row['id']; // Prende l'ID dell'oggetto che gli passiamo
    return await db.update(table, row, where: 'id = ?', whereArgs: [id]);
  }
}