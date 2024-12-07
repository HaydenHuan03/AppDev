import 'package:flutter/material.dart';
import 'promotion_detail_screen.dart';
import 'promotion.dart';

class PromotionListScreen extends StatelessWidget {
  final List<Promotion> promotions = [
    Promotion(
      title: '20% Off For Badminton Equipment',
      validity: 'November 11',
      detail: 'This promotion can be used to discount a 20% on Badminton Equipment.',
      category: 'badminton',
      discount: '20%',
    ),
    Promotion(
      title: '15% Off For Shoes Equipment',
      validity: 'November 11',
      detail: 'This promotion can be used to discount a 15% on Shoes Equipment.',
      category: 'shoes',
      discount: '15%',
    ),
    Promotion(
      title: 'RM5 Off For Badminton Apparel',
      validity: 'Every Weekend',
      detail: 'This promotion gives RM5 off for Badminton Apparel.',
      category: 'badminton apparel',
      discount: 'RM5',
    ),
    Promotion(
      title: '10% Off For Badminton String',
      validity: 'December 25',
      detail: 'Get a 10% discount on all badminton strings during the holiday season.',
      category: 'badminton string',
      discount: '10%',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Equipment Promotion',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFFFFF),
            fontSize: 24.0,
          ),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: promotions.length,
        itemBuilder: (context, index) {
          return PromotionCard(promotion: promotions[index]);
        },
      ),
    );
  }
}

class PromotionCard extends StatelessWidget {
  final Promotion promotion;

  const PromotionCard({required this.promotion});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PromotionDetailScreen(promotion: promotion),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Color(0xFF000000),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: Color(0xFFFB2626), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFFB2626).withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              promotion.title,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFFFFFF),
                fontFamily: 'Roboto',
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Validity: ${promotion.validity}',
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontFamily: 'Roboto',
                fontSize: 14.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

