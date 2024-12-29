import 'package:flutter/material.dart';
import 'package:utm_courtify/data/promotion_data/equipment_service.dart';
import 'promotion_order.dart'; 

class EquipmentListScreen extends StatelessWidget {
  final String category;
  final String discount;

  EquipmentListScreen({required this.category, required this.discount});

  final EquipmentService firebaseService = EquipmentService();

  final Map<String, String> imageMap = {
    'Yonex Arcsaber 11 Pro': 'assets/images/Promotion/arc11pro.png',
    'Victor Thruster Ryuga II': 'assets/images/Promotion/ryuga2.png',
    'Li-Ning Axforce Light Cannon': 'assets/images/Promotion/axforcecannon.png',
    'Victor A970ACE': 'assets/images/Promotion/a970ace.png',
    'Yonex Badminton T-Shirt': 'assets/images/Promotion/badminton_tshirt.png',
    'Yonex Power Cushion Aerus Z2': 'assets/images/Promotion/power_cushion.png',
    'Li-Ning Badminton Shorts': 'assets/images/Promotion/badminton_shorts.png',
    'Li-Ning No.1 String': 'assets/images/Promotion/lining_string.png',
    'Victor VBS-63 String': 'assets/images/Promotion/victor_string.png',
    'Yonex BG65 String': 'assets/images/Promotion/bg65_string.png',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
        title: Text('Equipment with $discount Off',
        style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFFB2626),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: firebaseService.fetchEquipment(category, discount),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading equipment"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No equipment found"));
          }

          final equipmentList = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: equipmentList.length,
            itemBuilder: (context, index) {
              final equipment = equipmentList[index];
              final name = equipment['name'];
              final price = equipment['price'];
              final imagePath = imageMap[name] ?? 'assets/placeholder.png';
              final double discountedPrice = firebaseService.calculateDiscountedPrice(price, discount);

              return Container(
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
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Row(
                            children: [
                              Text(
                                'Price: ',
                                style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontSize: 16.0,
                                ),
                              ),
                              Text(
                                'RM${price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16.0,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Text(
                                'RM${discountedPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Color(0xFFFB2626),
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.0),
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => PromotionOrderDialog(
                                  name: name,
                                  price: discountedPrice,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFB2626),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Buy Now'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Container(
                      height: 80.0,
                      width: 80.0,
                      decoration: BoxDecoration(
                        color: Colors.black,  // Black background for image
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.asset(
                          imagePath,
                          height: 80.0,
                          width: 80.0,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey,
                              child: Icon(Icons.error, color: Colors.white),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
