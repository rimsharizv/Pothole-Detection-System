import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final CollectionReference _potholesCollection = FirebaseFirestore.instance.collection('potholes');

  Stream<QuerySnapshot> getPotholesStream() {
    return _potholesCollection.snapshots();
  }
}