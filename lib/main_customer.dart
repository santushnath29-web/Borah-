import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'common.dart';
import 'my_bookings.dart';

void main() => startApp('Borah Customer', const CustomerHome());

class CustomerHome extends StatelessWidget {
  const CustomerHome({super.key});

  Future<void> _book(BuildContext context, String name, int price) async {
    final v = await askDialog(
      context,
      '$name - Rs $price',
      ['Aapka naam', 'Phone number', 'Address'],
      types: [
        TextInputType.name,
        TextInputType.phone,
        TextInputType.streetAddress,
      ],
    );
    if (v == null || !context.mounted) return;
    if (v[0].isEmpty || v[1].length < 10 || v[2].isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Naam, phone aur address sahi bharo')));
      return;
    }
    await bookingsCol.add({
      'service': name,
      'price': price,
      'status': 'Pending',
      'customer': v[0],
      'phone': v[1],
      'address': v[2],
      'createdAt': FieldValue.serverTimestamp(),
    });
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name Booked! Technician aayega')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Borah Electricals',
            style: TextStyle(color: kYellow, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const MyBookings())),
            child: const Text('Meri Bookings',
                style: TextStyle(color: kYellow)),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: settingsDoc.snapshots(),
        builder: (context, settingsSnap) {
          final data = settingsSnap.data?.data();
          final appOn = (data?['appOn'] as bool?) ?? true;
          if (!appOn) {
            return const Center(
              child: Text('Service abhi band hai.\nThodi der baad try karo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            );
          }
          return const ServiceList();
        },
      ),
    );
  }
}

class ServiceList extends StatelessWidget {
  const ServiceList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: servicesCol.orderBy('order').snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
              child: Text('Error: ${snap.error}',
                  style: const TextStyle(color: Colors.redAccent)));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snap.data!.docs;
        if (docs.isEmpty) {
          return const Center(
              child: Text('Abhi koi service nahi hai',
                  style: TextStyle(color: Colors.white, fontSize: 18)));
        }
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final d = docs[i].data();
            final name = d['name'] as String;
            final price = (d['price'] as num).toInt();
            return Card(
              color: kCard,
              margin: const EdgeInsets.all(10),
              child: ListTile(
                title: Text(name,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text('30-45 min - Biswanath / Guwahati',
                    style: TextStyle(color: Colors.grey)),
                trailing: Text('Rs $price',
                    style: const TextStyle(
                        color: kYellow,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                onTap: () => const CustomerHome()._book(context, name, price),
              ),
            );
          },
        );
      },
    );
  }
}
