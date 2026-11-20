import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'common.dart';

class MyBookings extends StatefulWidget {
  const MyBookings({super.key});

  @override
  State<MyBookings> createState() => _MyBookingsState();
}

class _MyBookingsState extends State<MyBookings> {
  final _c = TextEditingController();
  String _phone = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Meri Bookings',
              style: TextStyle(color: kYellow))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _c,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        hintText: 'Booking wala phone number'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kYellow,
                      foregroundColor: Colors.black),
                  onPressed: () => setState(() => _phone = _c.text.trim()),
                  child: const Text('Dekho'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _phone.isEmpty
                ? const Center(
                    child: Text('Phone number daalo',
                        style: TextStyle(color: Colors.grey)))
                : BookingList(phone: _phone),
          ),
        ],
      ),
    );
  }
}

class BookingList extends StatelessWidget {
  final String phone;
  const BookingList({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: bookingsCol.where('phone', isEqualTo: phone).snapshots(),
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
              child: Text('Koi booking nahi mili',
                  style: TextStyle(color: Colors.grey)));
        }
        return ListView(
          children: docs.map((doc) {
            final d = doc.data();
            final status = d['status'] as String;
            return Card(
              color: kCard,
              child: ListTile(
                title: Text('${d['service']} - Rs ${d['price']}',
                    style: const TextStyle(color: Colors.white)),
                trailing: Text(status,
                    style: TextStyle(
                        color: statusColor(status),
                        fontWeight: FontWeight.bold)),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
