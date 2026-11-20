import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

const kYellow = Color(0xFFFFC800);
const kCard = Color(0xFF1A1A1A);

// PIN badalna ho to yahan badlo
const ownerPin = '4321';
const technicianPin = '1234';

const firebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyAoeJ_8sWz36VRtfyzpUf52HJf0ca72JFc',
  appId: '1:356332411116:android:d5d540960b4d174882edc9',
  messagingSenderId: '356332411116',
  projectId: 'borah-e6462',
  storageBucket: 'borah-e6462.firebasestorage.app',
);

FirebaseFirestore get _db => FirebaseFirestore.instance;
CollectionReference<Map<String, dynamic>> get servicesCol =>
    _db.collection('services');
CollectionReference<Map<String, dynamic>> get bookingsCol =>
    _db.collection('bookings');
DocumentReference<Map<String, dynamic>> get settingsDoc =>
    _db.collection('settings').doc('app');

Future<void> startApp(String title, Widget home) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: title,
    theme: ThemeData(
      scaffoldBackgroundColor: Colors.black,
      colorScheme: const ColorScheme.dark(primary: kYellow),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
    ),
    home: home,
  ));
}

Future<void> seedServices() async {
  final snap = await servicesCol.limit(1).get();
  if (snap.docs.isNotEmpty) return;
  final defaults = [
    {'name': 'AC Service', 'price': 499},
    {'name': 'Fridge Repair', 'price': 399},
    {'name': 'Fan / Light Repair', 'price': 149},
    {'name': 'Wiring / Switch', 'price': 299},
    {'name': 'Inverter Repair', 'price': 349},
  ];
  var order = 1;
  for (final s in defaults) {
    await servicesCol.add({...s, 'order': order++});
  }
}

Future<List<String>?> askDialog(
  BuildContext context,
  String title,
  List<String> labels, {
  List<String>? initial,
  List<TextInputType>? types,
}) {
  final controllers = List.generate(labels.length,
      (i) => TextEditingController(text: initial != null ? initial[i] : ''));
  return showDialog<List<String>>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < labels.length; i++)
              TextField(
                controller: controllers[i],
                keyboardType: types != null ? types[i] : TextInputType.text,
                decoration: InputDecoration(labelText: labels[i]),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        TextButton(
          onPressed: () =>
              Navigator.pop(ctx, controllers.map((c) => c.text.trim()).toList()),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

Color statusColor(String s) {
  switch (s) {
    case 'Accepted':
      return Colors.lightBlueAccent;
    case 'Started':
      return Colors.orangeAccent;
    case 'Done':
      return Colors.greenAccent;
    case 'Cancelled':
      return Colors.redAccent;
    default:
      return Colors.grey;
  }
}

class PinGate extends StatefulWidget {
  final String pin;
  final String title;
  final Widget child;
  const PinGate(
      {super.key, required this.pin, required this.title, required this.child});

  @override
  State<PinGate> createState() => _PinGateState();
}

class _PinGateState extends State<PinGate> {
  final _c = TextEditingController();
  bool _ok = false;
  bool _wrong = false;

  @override
  Widget build(BuildContext context) {
    if (_ok) return widget.child;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.title,
                  style: const TextStyle(
                      color: kYellow, fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: _c,
                obscureText: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 22),
                decoration: InputDecoration(
                  hintText: 'PIN',
                  errorText: _wrong ? 'Galat PIN' : null,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: kYellow, foregroundColor: Colors.black),
                onPressed: () {
                  if (_c.text == widget.pin) {
                    setState(() => _ok = true);
                  } else {
                    setState(() => _wrong = true);
                  }
                },
                child: const Text('Andar Jao'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
