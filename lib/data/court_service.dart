import 'package:cloud_firestore/cloud_firestore.dart';

class CourtService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getAllCourts() async{
    try{
      final QuerySnapshot courtSnapshot = await _firestore
        .collection('courts')
        .where('isActive', isEqualTo: true)
        .get();
      
      return courtSnapshot.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>; 
        return {
          'id': doc.id,
          'name': data['courtName'] ?? 'Unnamed Court',
          'location': data['location'] ?? 'No Location',
          'maxPlayers': data['maxPlayers'] ?? 4,
          'isActive': data['isActive'] ?? true,
        };
        }).toList();
    }catch(e){
      print('Error from gaining courts: $e' );
      return [];
    }
  }

  Future<List<String>> getTimeSLots() async {
    try{
      final QuerySnapshot slotSnapshot = await _firestore
        .collection('time_slots')
        .where('isActive', isEqualTo: true)
        .orderBy('orderIndex')
        .get();

      return slotSnapshot.docs
        .map((doc) => (
          doc.data() as Map<String, dynamic>
        )['slot'] as String).toList();
    }catch(e){
      print('Error from gaining time slot: $e');
      rethrow;
    }
  }
}