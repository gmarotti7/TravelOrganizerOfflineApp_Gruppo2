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
      version: 2,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  // MIGRAZIONE: aggiunge le colonne introdotte dopo la v1 ai database
  // già esistenti sui dispositivi (creati prima che queste colonne esistessero).
  // Ogni ALTER TABLE è protetto da un try/catch perché SQLite non ha un modo
  // pulito per dire "aggiungi la colonna solo se non esiste già": se il
  // database è già aggiornato, l'errore "duplicate column" viene ignorato.
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    final comandi = <String>[
      'ALTER TABLE tappe ADD COLUMN data TEXT',
      'ALTER TABLE tappe ADD COLUMN ora TEXT',
      'ALTER TABLE tappe ADD COLUMN descrizione TEXT',
      'ALTER TABLE tappe ADD COLUMN costoPrevisto REAL',
      'ALTER TABLE spese ADD COLUMN stato TEXT',
      'ALTER TABLE spese ADD COLUMN descrizione TEXT',
      'ALTER TABLE spese ADD COLUMN metodoPagamento TEXT',
      'ALTER TABLE spese ADD COLUMN categoria TEXT',
      'ALTER TABLE spese ADD COLUMN attivitaAssociata TEXT',
      'ALTER TABLE spese ADD COLUMN valuta TEXT',
    ];

    for (final comando in comandi) {
      try {
        await db.execute(comando);
      } catch (_) {
        // La colonna esiste già: va bene così, andiamo avanti.
      }
    }
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
        stato TEXT,
        descrizione TEXT,
        metodoPagamento TEXT,
        categoria TEXT,
        attivitaAssociata TEXT,
        valuta TEXT,
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
  Future<int> update(String table, Map<String, dynamic> row, {required List<dynamic> whereArgs, required String where}) async {
    final db = await instance.database;
    return await db.update(table, row, where: where, whereArgs: whereArgs);
  }
}