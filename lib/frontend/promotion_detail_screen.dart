import 'package:flutter/material.dart';
import 'equipment_list_screen.dart';
import 'promotion.dart';

class PromotionDetailScreen extends StatelessWidget {
  final Promotion promotion;

  PromotionDetailScreen({required this.promotion});

  final Map<String, String> promotionImages = {
    '20% Off For Badminton Equipment': 'photo1.png',
    '15% Off For Shoes Equipment': 'photo2.png',
    'RM5 Off For Badminton Apparel': 'photo3.png',
    '10% Off For Badminton String': 'photo4.png',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(promotion.title),
        backgroundColor: Color(0xFFFB2626),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/${promotionImages[promotion.title] ?? 'default.png'}',
              height: 200.0,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 24.0),
            Text(
              promotion.title,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.0),
            Text(
              promotion.detail,
              style: TextStyle(fontSize: 16.0, color: Color(0xFFFFFFFF)),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EquipmentListScreen(
                      category: promotion.category,
                      discount: promotion.discount,
                    ),
                  ),
                );
              },
              child: Text('View Items', style: TextStyle(fontSize: 16.0, color: Color(0XFFFFFFFF))),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFB2626),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

