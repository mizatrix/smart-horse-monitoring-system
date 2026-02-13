
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

class Horse {
  final String id;
  final String name;
  final String breed;
  final int age;
  final String imageUrl;
  final double currentHeartRate;
  final double currentTemp;
  final int currentRespiration;
  final List<double> heartRateHistory; // Last 24 hours
  final List<double> tempHistory; // Last 24 hours
  final String status; // 'Stable', 'Critical', 'Warning'
  final String location; // 'Stall 1', 'Paddock A'

  Horse({
    required this.id,
    required this.name,
    required this.breed,
    required this.age,
    required this.imageUrl,
    required this.currentHeartRate,
    required this.currentTemp,
    required this.currentRespiration,
    required this.heartRateHistory,
    required this.tempHistory,
    required this.status,
    required this.location,
  });
}

class MockDataService extends ChangeNotifier {
  List<Horse> _horses = [];
  List<Horse> get horses => _horses;

  MockDataService() {
    _generateMockHorses();
  }

  void _generateMockHorses() {
    final random = Random();
    final names = [
      'Thunder', 'Spirit', 'Bella', 'Charlie', 'Luna', 'Max', 'Daisy', 'Cooper',
      'Rocky', 'Molly', 'Buddy', 'Lucy', 'Bailey', 'Ginger', 'Harley', 'Sadie',
      'Shadow', 'Coco', 'Tucker', 'Bear', 'Duke', 'Jack', 'Oliver', 'Toby',
      'Zeus', 'Apollo', 'Stella', 'Roxy', 'Penny', 'Chloe'
    ];
    final breeds = [
      'Arabian', 'Thoroughbred', 'Quarter Horse', 'Appaloosa', 'Morgan',
      'Warmblood', 'Andalusian', 'Friesian', 'Mustang', 'Clydesdale'
    ];
    
    // Images from assets
    final images = [
      'assets/images/image1.png', 'assets/images/image2.png', 'assets/images/image3.png',
      'assets/images/image4.png', 'assets/images/image5.png', 'assets/images/image6.png',
      'assets/images/image7.png', 'assets/images/image8.png', 'assets/images/image9.png',
      'assets/images/image10.png'
    ];

    for (int i = 0; i < 50; i++) {
      String id = const Uuid().v4();
      String name = names[random.nextInt(names.length)] + " ${i + 1}";
      String breed = breeds[random.nextInt(breeds.length)];
      int age = random.nextInt(15) + 3;
      String imageUrl = images[random.nextInt(images.length)];
      
      // Vitals simulation
      double heartRate = 30 + random.nextDouble() * 20; // 30-50 bpm normal
      double temp = 37.0 + random.nextDouble() * 1.5; // 37-38.5 C normal
      int respiration = 10 + random.nextInt(15); // 10-25 breaths/min

      // Randomly make some critical
      String status = 'Stable';
      if (random.nextDouble() > 0.9) {
        status = 'Critical';
        heartRate += 30; // Elevated HR
        temp += 1.5; // Fever
      } else if (random.nextDouble() > 0.8) {
        status = 'Warning';
        heartRate += 15;
      }

      // Generate history
      List<double> hrHistory = List.generate(24, (index) => 30 + random.nextDouble() * 20 + (status == 'Critical' ? 30 : 0));
      List<double> tempHistory = List.generate(24, (index) => 37.0 + random.nextDouble() * 1.0 + (status == 'Critical' ? 1.5 : 0));

      _horses.add(Horse(
        id: id,
        name: name,
        breed: breed,
        age: age,
        imageUrl: imageUrl,
        currentHeartRate: double.parse(heartRate.toStringAsFixed(1)),
        currentTemp: double.parse(temp.toStringAsFixed(1)),
        currentRespiration: respiration,
        heartRateHistory: hrHistory,
        tempHistory: tempHistory,
        status: status,
        location: 'Stall ${random.nextInt(100)}',
      ));
    }
  }

  // Helper to get critical count
  int get criticalCount => _horses.where((h) => h.status == 'Critical').length;
  int get warningCount => _horses.where((h) => h.status == 'Warning').length;
  int get stableCount => _horses.where((h) => h.status == 'Stable').length;
}
