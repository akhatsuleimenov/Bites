import 'dart:io';

class FoodvisorService {
  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Return mock data
    return {
      "analysis_id": "981e5606-3811-4059-ac29-eb1f8f001fae",
      "items": [
        {
          "food": [
            {
              "confidence": 1.0,
              "food_info": {
                "food_id": "4a4e1d49fb47deae8d45cefd9df24e5a",
                "fv_grade": "D",
                "g_per_serving": 300.0,
                "display_name": "Pasta Carbonara",
                "quantity": 300.0,
                "position": {
                  "height": 0.4283,
                  "width": 0.5183,
                  "x": 0.3683,
                  "y": 0.1333
                },
                "nutrition": {
                  "alcohol_100g": 0.0,
                  "calcium_100g": 0.0194,
                  "calories_100g": 94.0,
                  "carbs_100g": 13.1,
                  "chloride_100g": null,
                  "cholesterol_100g": 0.0294,
                  "copper_100g": null,
                  "fat_100g": 2.6,
                  "fibers_100g": 0.0,
                  "glycemic_index": 60.0,
                  "insat_fat_100g": 0.965,
                  "iodine_100g": null,
                  "iron_100g": 0.000946,
                  "magnesium_100g": 0.0252,
                  "manganese_100g": null,
                  "mono_fat_100g": 0.748,
                  "omega_3_100g": 0.01209,
                  "omega_6_100g": 0.205,
                  "phosphorus_100g": 0.088,
                  "poly_fat_100g": 0.217,
                  "polyols_100g": null,
                  "potassium_100g": 0.0597,
                  "proteins_100g": 7.2,
                  "salt_100g": null,
                  "sat_fat_100g": 0.411,
                  "selenium_100g": null,
                  "sodium_100g": 0.0406,
                  "sugars_100g": 0.0,
                  "veg_percent": 0.0,
                  "vitamin_a_beta_k_100g": null,
                  "vitamin_a_retinol_100g": null,
                  "vitamin_b12_100g": null,
                  "vitamin_b1_100g": null,
                  "vitamin_b2_100g": null,
                  "vitamin_b3_100g": null,
                  "vitamin_b5_100g": null,
                  "vitamin_b6_100g": null,
                  "vitamin_b9_100g": 9.2e-06,
                  "vitamin_c_100g": 0.0,
                  "vitamin_d_100g": null,
                  "vitamin_e_100g": null,
                  "vitamin_k1_100g": null,
                  "water_100g": null,
                  "zinc_100g": null,
                },
              },
              "ingredients": [
                {
                  "confidence": 1.0,
                  "food_info": {
                    "food_id": "dc2bf7a30d928df24e19acae178a922a",
                    "fv_grade": "C",
                    "g_per_serving": 150.0,
                    "display_name": "Pasta",
                    "nutrition": {
                      "carbs_100g": 25.0,
                      "proteins_100g": 10.0,
                      "fat_100g": 0.5,
                      "calories_100g": 120.0,
                    },
                  },
                  "ingredients": [],
                  "quantity": 150.0,
                },
                {
                  "confidence": 1.0,
                  "food_info": {
                    "food_id": "60aa725a34508e0daac3fc8f39aaa98d",
                    "fv_grade": "C",
                    "g_per_serving": 30.0,
                    "display_name": "Low fat sour cream",
                    "nutrition": {
                      "alcohol_100g": 0.0,
                      "calcium_100g": 0.098,
                      "calories_100g": 120.0,
                      "carbs_100g": 4.6,
                      "cholesterol_100g": 0.0147,
                      "fat_100g": 7.0,
                      "fibers_100g": 0.0,
                      "insat_fat_100g": 2.037,
                      "iron_100g": 0.0001,
                      "magnesium_100g": 0.008,
                      "mono_fat_100g": 1.587,
                      "omega_3_100g": 0.028,
                      "omega_6_100g": 0.422,
                      "phosphorus_100g": 0.073,
                      "poly_fat_100g": 0.45,
                      "potassium_100g": 0.141,
                      "proteins_100g": 7.0,
                      "sat_fat_100g": 4.513,
                      "sodium_100g": 0.08,
                      "sugars_100g": 3.5,
                      "vitamin_a_retinol_100g": 0.00014,
                      "vitamin_b12_100g": 0.00000037,
                      "vitamin_b2_100g": 0.00014,
                      "vitamin_d_100g": 0.0000001
                    },
                  },
                  "ingredients": [],
                  "quantity": 40.0,
                },
                {
                  "confidence": 1.0,
                  "food_info": {
                    "food_id": "70bbb8f7ad90430d1936d790ed528d5c",
                    "fv_grade": "D",
                    "g_per_serving": 100.0,
                    "display_name": "Diced bacon",
                    "nutrition": {
                      "alcohol_100g": 0.0,
                      "calcium_100g": 0.006,
                      "calories_100g": 541.0,
                      "carbs_100g": 0.1,
                      "cholesterol_100g": 0.110,
                      "fat_100g": 41.78,
                      "fibers_100g": 0.0,
                      "insat_fat_100g": 23.688,
                      "iron_100g": 0.00089,
                      "magnesium_100g": 0.023,
                      "mono_fat_100g": 18.535,
                      "omega_3_100g": 0.211,
                      "omega_6_100g": 4.942,
                      "phosphorus_100g": 0.454,
                      "poly_fat_100g": 5.153,
                      "potassium_100g": 0.565,
                      "proteins_100g": 37.04,
                      "sat_fat_100g": 13.089,
                      "sodium_100g": 1.85,
                      "sugars_100g": 0.0,
                      "vitamin_b1_100g": 0.00425,
                      "vitamin_b12_100g": 0.00000164,
                      "vitamin_b3_100g": 0.01643,
                      "vitamin_b6_100g": 0.00034,
                      "vitamin_d_100g": 0.00000102,
                      "zinc_100g": 0.00277
                    },
                  },
                  "ingredients": [],
                  "quantity": 10.0,
                },
              ],
            },
          ]
        },
      ],
      "scopes": [
        "multiple_items",
        "quantity",
        "nutrition:nutriscore",
        "nutrition:micro",
        "position",
        "nutrition:macro",
      ]
    };
  }
}

class FoodvisorException implements Exception {
  final String message;
  FoodvisorException(this.message);
  @override
  String toString() => message;
}
