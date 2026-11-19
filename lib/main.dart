import 'package:flutter/material.dart';

const kYellow = Color(0xFFFFC800);
const kCard = Color(0xFF1A1A1A);

// ---------------- DATA / SHARED STATE ----------------
class Service {
  final String name;
  int price;
  Service(this.name, this.price);
}

class Booking {
  final int id;
  final String service;
  final int price;
  String status; // Pending, Accepted, Started, Done, Cancelled
  Booking(this.id, this.service, this.price, this.status);
}

class Store extends ChangeNotifier {
  bool appOn = true;
  int _nextId = 1;

  final List<Service> services = [
    Service('AC Service', 499),
    Service('Fridge Repair', 399),
    Service('Fan / Light Repair', 149),
    Service('Wiring / Switch', 299),
    Service('Inverter Repair', 349),
  ];

  final List<Booking> bookings = [];

  int get earnings => bookings
      .where((b) => b.status == 'Done')
      .fold(0, (sum, b) => sum + b.price);

  void book(Service s) {
    bookings.insert(0, Booking(_nextId++, s.name, s.price, 'Pending'));
    notifyListeners();
  }

  void setStatus(Booking b, String status) {
    b.status = status;
    notifyListeners();
  }

  void setPrice(Service s, int price) {
    s.price = price;
    notifyListeners();
  }

  void setAppOn(bool v) {
    appOn = v;
    notifyListeners();
  }
}

final store = Store();

// ---------------- APP ----------------
void main() => runApp(const BorahApp());

class BorahApp extends StatelessWidget {
  const BorahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Borah Electricals Home Care',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: const RoleSelect(),
    );
  }
}

class RoleSelect extends StatelessWidget {
  const RoleSelect({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('BORAH',
                style: TextStyle(
                    color: kYellow, fontSize: 42, fontWeight: FontWeight.bold)),
            const Text('ELECTRICALS HOME CARE ⚡',
                style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 40),
            _btn(context, 'Customer - Service Book Karo', Colors.white,
                Colors.black, const CustomerHome()),
            const SizedBox(height: 12),
            _btn(context, 'Technician - Job Dekho', kYellow, Colors.black,
                const TechnicianHome()),
            const SizedBox(height: 12),
            _btn(context, 'Borah Owner - Full Control 👑', Colors.grey[800]!,
                Colors.white, const OwnerHome()),
          ],
        ),
      ),
    );
  }

  Widget _btn(BuildContext c, String t, Color bg, Color fg, Widget page) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: bg, minimumSize: const Size(300, 50)),
      onPressed: () =>
          Navigator.push(c, MaterialPageRoute(builder: (_) => page)),
      child: Text(t,
          style: TextStyle(color: fg, fontWeight: FontWeight.bold)),
    );
  }
}

// ---------------- CUSTOMER ----------------
class CustomerHome extends StatelessWidget {
  const CustomerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Borah Electricals Home Care',
            style: TextStyle(color: kYellow, fontWeight: FontWeight.bold)),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          if (!store.appOn) {
            return const Center(
              child: Text('Service abhi band hai.\nThodi der baad try karo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            );
          }
          return ListView.builder(
            itemCount: store.services.length,
            itemBuilder: (context, i) {
              final s = store.services[i];
              return Card(
                color: kCard,
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(s.name,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: const Text('30-45 min - Biswanath / Guwahati',
                      style: TextStyle(color: Colors.grey)),
                  trailing: Text('Rs ${s.price}',
                      style: const TextStyle(
                          color: kYellow,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  onTap: () {
                    store.book(s);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('${s.name} Booked! Technician aayega')));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------- TECHNICIAN ----------------
class TechnicianHome extends StatelessWidget {
  const TechnicianHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Technician', style: TextStyle(color: kYellow))),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final jobs =
              store.bookings.where((b) => b.status != 'Cancelled').toList();
          if (jobs.isEmpty) {
            return const Center(
              child: Text('Abhi koi job nahi hai',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: jobs.length,
            itemBuilder: (context, i) => _jobCard(jobs[i]),
          );
        },
      ),
    );
  }

  Widget _jobCard(Booking b) {
    String? label;
    String? next;
    switch (b.status) {
      case 'Pending':
        label = 'Accept';
        next = 'Accepted';
        break;
      case 'Accepted':
        label = 'Start';
        next = 'Started';
        break;
      case 'Started':
        label = 'Done';
        next = 'Done';
        break;
    }
    return Card(
      color: kCard,
      child: ListTile(
        title: Text('${b.service} - Rs ${b.price}',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text('Job #${b.id} • ${b.status}',
            style: const TextStyle(color: Colors.grey)),
        trailing: label == null
            ? const Icon(Icons.check_circle, color: Colors.green)
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: kYellow, foregroundColor: Colors.black),
                onPressed: () => store.setStatus(b, next!),
                child: Text(label),
              ),
      ),
    );
  }
}

// ---------------- OWNER ----------------
class OwnerHome extends StatelessWidget {
  const OwnerHome({super.key});

  void _editPrice(BuildContext context, Service s) {
    final controller = TextEditingController(text: s.price.toString());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${s.name} - Naya Price'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(prefixText: 'Rs '),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final p = int.tryParse(controller.text.trim());
              if (p != null && p > 0) store.setPrice(s, p);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Borah Owner 👑',
              style: TextStyle(color: kYellow))),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Kamai (Done jobs): Rs ${store.earnings}',
                  style: const TextStyle(
                      color: kYellow,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Card(
                color: kCard,
                child: SwitchListTile(
                  activeColor: kYellow,
                  title: const Text('App ON / OFF',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(store.appOn ? 'Chalu hai' : 'Band hai',
                      style: const TextStyle(color: Colors.grey)),
                  value: store.appOn,
                  onChanged: store.setAppOn,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Service + Price Control',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              ...store.services.map((s) => Card(
                    color: kCard,
                    child: ListTile(
                      title: Text(s.name,
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text('Rs ${s.price} -> Badlo',
                          style: const TextStyle(color: Colors.grey)),
                      trailing: const Icon(Icons.edit, color: kYellow),
                      onTap: () => _editPrice(context, s),
                    ),
                  )),
              const SizedBox(height: 16),
              const Text('Booking Control',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              if (store.bookings.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Abhi koi booking nahi',
                      style: TextStyle(color: Colors.grey)),
                ),
              ...store.bookings.map((b) => Card(
                    color: kCard,
                    child: ListTile(
                      title: Text('#${b.id} ${b.service} - Rs ${b.price}',
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(b.status,
                          style: const TextStyle(color: Colors.grey)),
                      trailing: (b.status == 'Done' || b.status == 'Cancelled')
                          ? null
                          : TextButton(
                              onPressed: () => store.setStatus(b, 'Cancelled'),
                              child: const Text('Cancel',
                                  style: TextStyle(color: Colors.redAccent)),
                            ),
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }
}
