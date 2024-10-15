import 'package:flutter/material.dart';
import 'package:myapp/ruta.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  Ruta? _selectedRuta;
  List<Ruta> _rutas = [];

  @override
  void initState() {
    super.initState();
    getRutas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NFC Reader'),
      ),
      body: Center(
          child: Column(
        children: [
          Center(
            child: DropdownButton<Ruta>(
              hint: const Text('Seleccione una ruta'),
              value: _selectedRuta,
              onChanged: (Ruta? newValue) {
                setState(() {
                  _selectedRuta = newValue;
                });
              },
              items: _rutas.map<DropdownMenuItem<Ruta>>((Ruta ruta) {
                return DropdownMenuItem<Ruta>(
                  value: ruta,
                  child: Text(ruta.nombre),
                );
              }).toList(),
            ),
          ),
          ElevatedButton(
            onPressed: _startNFCReading,
            child: const Text('Start NFC Reading'),
          ),
        ],
      )),
    );
  }

  void _startNFCReading() async {
    try {
      bool isAvailable = await NfcManager.instance.isAvailable();

      //We first check if NFC is available on the device.
      if (isAvailable) {
        //If NFC is available, start an NFC session and listen for NFC tags to be discovered.
        NfcManager.instance.startSession(
          onDiscovered: (NfcTag tag) async {
            // Process NFC tag, When an NFC tag is discovered, print its data to the console.
            print('NFC Tag Detected: ${tag.data}');
            //realizarPago();
          },
        );
      } else {
        debugPrint('NFC not available.');
      }
    } catch (e) {
      debugPrint('Error reading NFC: $e');
    }
  }

  void getRutas() async {
    var url = "$BACKEND_URL/elimapass/v1/rutas/";

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      List<Ruta> rutas = Ruta.listFromJson(json);
      print(rutas);
      setState(() {
        _rutas = rutas;
      });
    }
    return;
  }

  Future<double> realizarPago(String tarjetaId) async {
    var url = "$BACKEND_URL/elimapass/v1/viajes/";

    var body = {"tarjetaId": tarjetaId, "rutaId": _selectedRuta!.id};

    final response = await http.post(Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final saldo = json["saldo"];
      return saldo;
    } else {
      throw Exception('Ha ocurrido un error desconocido. Inténtelo más tarde');
    }
  }
}
