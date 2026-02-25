import 'animal.dart';

class DamagotchiData {
  Animal? currentAnimal;
  List<Animal> collection;

  DamagotchiData({
    this.currentAnimal,
    List<Animal>? collection,
  }) : collection = collection ?? [];

  Map<String, dynamic> toJson() {
    return {
      'currentAnimal': currentAnimal?.toJson(),
      'collection': collection.map((a) => a.toJson()).toList(),
    };
  }

  factory DamagotchiData.fromJson(Map<String, dynamic> json) {
    // null safety 처리
    final currentAnimalJson = json['currentAnimal'];
    
    return DamagotchiData(
      currentAnimal: currentAnimalJson != null ? Animal.fromJson(currentAnimalJson) : null,
      collection: (json['collection'] as List<dynamic>?)
              ?.map((a) => Animal.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
