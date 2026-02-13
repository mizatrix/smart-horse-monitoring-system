
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
  // New fields
  final double weight; // in kg
  final String lastVetVisit;
  final String vaccinationStatus; // 'Up to date', 'Due Soon', 'Overdue'
  final String gender; // 'Stallion', 'Mare', 'Gelding'
  final double hydrationLevel; // 0-100%
  final String gaitScore; // 'Normal', 'Slight Lameness', 'Abnormal'
  final int stressIndex; // 0-100
  final String microchipId;

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
    this.weight = 450.0,
    this.lastVetVisit = 'Jan 15, 2026',
    this.vaccinationStatus = 'Up to date',
    this.gender = 'Stallion',
    this.hydrationLevel = 85.0,
    this.gaitScore = 'Normal',
    this.stressIndex = 20,
    this.microchipId = '900-000-000-0000',
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
      'assets/images/default_horse_avatar.png',
      'assets/images/horse_avatar_1.png',
      'assets/images/horse_avatar_2.png',
      'assets/images/horse_avatar_3.png',
      'assets/images/horse_avatar_6.png',
    ];

    final genders = ['Stallion', 'Mare', 'Gelding'];
    final vaccStatuses = ['Up to date', 'Due Soon', 'Overdue'];
    final gaitScores = ['Normal', 'Normal', 'Normal', 'Slight Lameness', 'Abnormal'];
    final vetDates = ['Jan 15, 2026', 'Dec 20, 2025', 'Feb 1, 2026', 'Nov 10, 2025', 'Jan 28, 2026'];

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

      // New fields
      double weight = 350 + random.nextDouble() * 250; // 350-600 kg
      String gender = genders[random.nextInt(genders.length)];
      String vaccStatus = status == 'Critical' ? 'Overdue' : vaccStatuses[random.nextInt(vaccStatuses.length)];
      double hydration = status == 'Critical' ? 40 + random.nextDouble() * 20 : 70 + random.nextDouble() * 30;
      String gait = status == 'Critical' ? 'Abnormal' : gaitScores[random.nextInt(gaitScores.length)];
      int stress = status == 'Critical' ? 60 + random.nextInt(40) : (status == 'Warning' ? 30 + random.nextInt(30) : random.nextInt(30));
      String chipId = '900-${100 + random.nextInt(900)}-${100 + random.nextInt(900)}-${1000 + random.nextInt(9000)}';

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
        weight: double.parse(weight.toStringAsFixed(1)),
        lastVetVisit: vetDates[random.nextInt(vetDates.length)],
        vaccinationStatus: vaccStatus,
        gender: gender,
        hydrationLevel: double.parse(hydration.toStringAsFixed(1)),
        gaitScore: gait,
        stressIndex: stress,
        microchipId: chipId,
      ));
    }
  }

  // CRUD Operations
  void addHorse(Horse horse) {
    _horses.add(horse);
    notifyListeners();
  }

  void updateHorse(Horse updatedHorse) {
    final index = _horses.indexWhere((h) => h.id == updatedHorse.id);
    if (index != -1) {
      _horses[index] = updatedHorse;
      notifyListeners();
    }
  }

  void deleteHorse(String id) {
    _horses.removeWhere((h) => h.id == id);
    notifyListeners();
  }
  int get criticalCount => _horses.where((h) => h.status == 'Critical').length;
  int get warningCount => _horses.where((h) => h.status == 'Warning').length;
  int get stableCount => _horses.where((h) => h.status == 'Stable').length;
  double get avgHeartRate => _horses.isEmpty ? 0 : _horses.map((h) => h.currentHeartRate).reduce((a, b) => a + b) / _horses.length;
  double get avgTemp => _horses.isEmpty ? 0 : _horses.map((h) => h.currentTemp).reduce((a, b) => a + b) / _horses.length;
}
