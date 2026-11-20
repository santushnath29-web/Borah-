import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'common.dart';

void main() => startApp(
      'Borah Technician',
      const PinGate(
          pin: technicianPin, title: 'Technician PIN', child: TechnicianHome()),
    );

class TechnicianHome extends StatelessWidget {
  const TechnicianHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Technician Jobs',
              style: TextStyle(color: kYellow))),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: bookingsCol.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
                child: Text('Error: ${snap.error}',
                    style: const TextStyle(color: Colors.redAccent)));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final jobs = snap.data!.docs
              .where((d) => d.data()['status'] != 'Cancelled')
              .toList();
          if (jobs.isEmpty) {
            return const Center(
                child: Text('Abhi koi job nahi hai',
                    style: TextStyle(color: Colors.white, fontSize: 18)));
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

  Widget _jobCard(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    final status = d['status'] as String;
    String? label;
    String? next;
    if (status == 'Pending') {
      label = 'Accept';
      next = 'Accepted';
    } else if (status == 'Accepted') {
      label = 'Start';
      next = 'Started';
    } else if (status == 'Started') {
      label = 'Done';
      next = 'Done';
    }
    return Card(
      color: kCard,
      child: ListTile(
        isThreeLine: true,
        title: Text('${d['service']} - Rs ${d['price']}',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(
            '${d['customer']} • ${d['phone']}\n${d['address']}\n$status',
            style: TextStyle(color: statusColor(status))),
        trailing: label == null
            ? const Icon(Icons.check_circle, color: Colors.green)
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: kYellow, foregroundColor: Colors.black),
                onPressed: () => doc.reference.update({'status': next}),
                child: Text(label),
              ),
      ),
    );
  }
}
