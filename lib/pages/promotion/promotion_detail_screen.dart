import 'package:flutter/material.dart';
import 'promotion.dart';
import 'equipment_list_screen.dart';

class PromotionDetailScreen extends StatelessWidget {
  final Promotion promotion;

  const PromotionDetailScreen({required this.promotion});

  @override
  Widget build(BuildContext context) {
    // Define image paths based on category or title
    final Map<String, String> imagePaths = {
      '20% Off For Badminton Equipment': 'assets/images/Promotion/photo1.png',
      '15% Off For Shoes Equipment': 'assets/images/Promotion/photo2.png',
      'RM5 Off For Badminton Apparel': 'assets/images/Promotion/photo3.png',
      '10% Off For Badminton String': 'assets/images/Promotion/photo4.png',
    };

    final String imagePath = imagePaths[promotion.title] ?? 'images/default_image.png';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
    ),
  ),
        backgroundColor: Color(0xFFFB2626),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          promotion.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Display Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Image.asset(
                imagePath,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 24),
            // Title
            Text(
              promotion.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            // Description
            Text(
              promotion.detail,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 40),
            // View Items Button
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFB2626),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'View Items',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
