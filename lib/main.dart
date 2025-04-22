import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() => runApp(const DugApp());

class DugApp extends StatelessWidget {
  const DugApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Otplata Duga',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
      home: const DugScreen(),
    );
  }
}

class DugScreen extends StatefulWidget {
  const DugScreen({super.key});

  @override
  State<DugScreen> createState() => _DugScreenState();
}

class _DugScreenState extends State<DugScreen> {
  final TextEditingController _dugController = TextEditingController();
  final TextEditingController _kamatnaStopaController = TextEditingController();
  final TextEditingController _mjesecniDoprinosController =
      TextEditingController();

  double? _rezultat;
  final List<Map<String, dynamic>> _povijest = [];
  Database? _db;

  @override
  void initState() {
    super.initState();
    _initDB();
  }

  Future<void> _initDB() async {
    _db = await openDatabase(
      join(await getDatabasesPath(), 'dug.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE povijest(id INTEGER PRIMARY KEY, dug REAL, kamatna_stopa REAL, doprinos REAL, mjeseci INTEGER, datum TEXT)',
        );
      },
      version: 1,
    );
    await _ucitajPovijest();
  }

  Future<void> _ucitajPovijest() async {
    final data = await _db?.query('povijest', orderBy: 'id DESC');
    setState(() {
      _povijest.clear();
      _povijest.addAll(data ?? []);
    });
  }

  Future<void> _izracunajOtplatu() async {
    final dug = double.tryParse(_dugController.text) ?? 0;
    final kamata = double.tryParse(_kamatnaStopaController.text) ?? 0;
    final doprinos = double.tryParse(_mjesecniDoprinosController.text) ?? 0;

    if (dug <= 0 || doprinos <= 0) {
      _prikaziPoruku('Unesite valjane iznose duga i doprinosa.');
      return;
    }

    int mjeseci = 0;
    double trenutniDug = dug;
    while (trenutniDug > 0) {
      trenutniDug += trenutniDug * (kamata / 100 / 12);
      trenutniDug -= doprinos;
      mjeseci++;
      if (mjeseci > 1000) break;
    }

    final datum = DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now());

    await _db?.insert('povijest', {
      'dug': dug,
      'kamatna_stopa': kamata,
      'doprinos': doprinos,
      'mjeseci': mjeseci,
      'datum': datum,
    });

    setState(() {
      _rezultat = mjeseci.toDouble();
      _povijest.insert(0, {
        'dug': dug,
        'kamatna_stopa': kamata,
        'doprinos': doprinos,
        'mjeseci': mjeseci,
        'datum': datum,
      });
    });

    Navigator.of(context as BuildContext).push(
      MaterialPageRoute(
        builder: (context) => RezultatScreen(
          dug: dug,
          kamata: kamata,
          doprinos: doprinos,
          mjeseci: mjeseci,
          datum: datum,
        ),
      ),
    );

    _dugController.clear();
    _kamatnaStopaController.clear();
    _mjesecniDoprinosController.clear();
  }

  void _prikaziPoruku(String poruka) {
    ScaffoldMessenger.of(context as BuildContext).showSnackBar(
      SnackBar(content: Text(poruka), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Otplata Duga')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _dugController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Ukupan dug (EUR)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _kamatnaStopaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Kamatna stopa (%)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.percent),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _mjesecniDoprinosController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Mjesečni doprinos (EUR)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.payments),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _izracunajOtplatu,
              icon: const Icon(Icons.calculate),
              label: const Text('Izračunaj otplatu'),
            ),
            const SizedBox(height: 10),
            if (_rezultat != null)
              Text(
                'Potrebno mjeseci: ${_rezultat!.toInt()}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PovijestScreen(povijest: _povijest),
                  ),
                );
              },
              icon: const Icon(Icons.history),
              label: const Text('Povijest izračuna'),
            ),
          ],
        ),
      ),
    );
  }
}

class RezultatScreen extends StatelessWidget {
  final double dug;
  final double kamata;
  final double doprinos;
  final int mjeseci;
  final String datum;

  const RezultatScreen({
    super.key,
    required this.dug,
    required this.kamata,
    required this.doprinos,
    required this.mjeseci,
    required this.datum,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rezultat otplate')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dug: €$dug'),
            Text('Kamatna stopa: $kamata%'),
            Text('Mjesečni doprinos: €$doprinos'),
            const SizedBox(height: 10),
            Text('Potrebno mjeseci za otplatu: $mjeseci',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Natrag'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PovijestScreen extends StatelessWidget {
  final List<Map<String, dynamic>> povijest;

  const PovijestScreen({super.key, required this.povijest});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Povijest izračuna')),
      body: ListView.builder(
        itemCount: povijest.length,
        itemBuilder: (context, index) {
          final zapis = povijest[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.timeline),
              title: Text(
                'Mjeseci: ${zapis['mjeseci']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Dug: €${zapis['dug']}\nKamatna stopa: ${zapis['kamatna_stopa']}%\nDoprinos: €${zapis['doprinos']}\n${zapis['datum']}',
              ),
            ),
          );
        },
      ),
    );
  }
}

