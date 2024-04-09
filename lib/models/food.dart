class Food {
  int id;
  String name;
  String imageUrl;
  String calories;
  String readyInMinutes;
  String fiber;
  String protein;
  String sugar;
  bool vegetarian;
  Food(
      {required this.id,
      required this.name,
      required this.imageUrl,
      required this.calories,
      required this.readyInMinutes,
      required this.fiber,
      required this.protein,
      required this.sugar,
      required this.vegetarian});
  factory Food.fromJson(Map<String, dynamic> json) {
    var nutrition = json['nutrition'];
    var nutrients = nutrition != null ? nutrition['nutrients'] : [];
    // ignore: prefer_interpolation_to_compose_strings
    var calories =  "";
    var fiber = "";
    var protein = "";
    var sugar = "";

    for (var nutrient in nutrients) {
      if (nutrient['name'] == 'Calories') {
        // ignore: prefer_interpolation_to_compose_strings
        calories = '${nutrient['amount']} ' + nutrient['unit'];
        if(calories.isEmpty) {
          calories = "0 cal";
        }
      }
      if (nutrient['name'] == 'Sugar') {
        // ignore: prefer_interpolation_to_compose_strings
        sugar = '${nutrient['amount']} ' + nutrient['unit'];
        if(sugar.isEmpty) {
          sugar = "0 g";
        }
      }
      if (nutrient['name'] == 'Protein') {
        // ignore: prefer_interpolation_to_compose_strings
        protein = '${nutrient['amount']} ' + nutrient['unit'];
        if(protein.isEmpty) {
          protein = "0 g";
        }
      }
      if (nutrient['name'] == 'Fiber') {
        // ignore: prefer_interpolation_to_compose_strings
        fiber = '${nutrient['amount']} ' + nutrient['unit'];
        if(fiber.isEmpty) {
          fiber = "0 g";
        }
      }
    }

    return Food(
      id: json['id'],
      name: json['title'] as String,
      imageUrl: json['image'] as String,
      calories: calories,
      readyInMinutes: json['readyInMinutes'].toString(),
      fiber: fiber,
      sugar: sugar,
      protein: protein,
      vegetarian: json['vegetarian'],
    );
  }
}
