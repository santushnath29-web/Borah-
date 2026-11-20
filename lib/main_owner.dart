import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'common.dart';

void main() => startApp(
      'Borah Owner',
      const PinGate(pin: ownerPin, title: 'Owner PIN 👑', child: OwnerHome()),
    );

class OwnerHome extends StatefulWidget {
  const OwnerHome({super.key});

  @override
  State<OwnerHome> createState() => _OwnerHomeState();
}

class _OwnerHomeState extends State<OwnerHome> {
  @override
  void initState() {
    super.initState();
    seedServices();
  }

  Future<void> _editPrice(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
    final d = doc.data();
    final v = await askDialog(context, '${d['name']} - Naya Price', ['Price (Rs)'],
        initial: ['${d['price']}'], types: [TextInputType.number]);
    final p = int.tryParse(v?[0] ?? '');
    if (p != null && p > 0) await doc.reference.update({'price': p});
  }

  Future<void> _addService() async {
    final v = await askDialog(
        context, 'Nayi Service', ['Naam', 'Price (Rs)'],
        types: [TextInputType.text, TextInputType.number]);
    if (v == null) return;
    final p = int.tryParse(v[1]);
    if (v[0].isEmpty || p == null || p <= 0) return;
    await servicesCol.add({
      'name': v[0],
      'price': p,
      'order': DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Borah Owner 👑', style: TextStyle(color: kYellow))),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: bookingsCol.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
                child: Text('Error: ${snap.error}',
                    style: const TextStyle(color: Colors.redAccent)));
          }
          final docs = snap.data?.docs ?? [];
          final earnings = docs
              .where((d) => d.data()['status'] == 'Done')
              .fold<int>(
                  0, (sum, d) => sum + ((d.data()['price'] as num?)?.toInt() ?? 0));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Kamai (Done jobs): Rs $earnings',
                  style: const TextStyle(
                      color: kYellow, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: settingsDoc.snapshots(),
                builder: (context, s) {
                  final appOn = (s.data?.data()?['appOn'] as bool?) ?? true;
                  return Card(
                    color: kCard,
                    child: SwitchListTile(
                      activeColor: kYellow,
                      title: const Text('Customer App ON / OFF',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text(appOn ? 'Chalu hai' : 'Band hai',
                          style: const TextStyle(color: Colors.grey)),
                      value: appOn,
                      onChanged: (v) =>
                          settingsDoc.set({'appOn': v}, SetOptions(merge: true)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: Text('Service + Price Control',
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: kYellow),
                    onPressed: _addService,
                  ),
                ],
              ),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: servicesCol.orderBy('order').snapshots(),
                builder: (context, s) {
                  final list = s.data?.docs ?? [];
                  return Column(
                    children: list.map((doc) {
                      final d = doc.data();
                      return Card(
                        color: kCard,
                        child: ListTile(
                          title: Text('${d['name']}',
                              style: const TextStyle(color: Colors.white)),
                          subtitle: Text('Rs ${d['price']} -> Badlo',
                              style: const TextStyle(color: Colors.grey)),
                          onTap: () => _editPrice(doc),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => doc.reference.delete(),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text('Booking Control',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              if (docs.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Abhi koi booking nahi',
                      style: TextStyle(color: Colors.grey)),
                ),
              ...docs.map((doc) {
                final d = doc.data();
                final status = d['status'] as String;
                return Card(
                  color: kCard,
                  child: ListTile(
                    isThreeLine: true,
                    title: Text('${d['service']} - Rs ${d['price']}',
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Text(
                        '${d['customer']} • ${d['phone']}\n${d['address']}\n$status',
                        style: TextStyle(color: statusColor(status))),
                    trailing: (status == 'Done' || status == 'Cancelled')
                        ? null
                        : TextButton(
                            onPressed: () =>
                                doc.reference.update({'status': 'Cancelled'}),
                            child: const Text('Cancel',
                                style: TextStyle(color: Colors.redAccent)),
                          ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
