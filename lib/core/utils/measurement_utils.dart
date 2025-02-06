class MeasurementHelper {
  static const double inchToCm = 2.54;
  static const double feetToCm = 30.48;
  static const double lbToKg = 0.453592;

  static String getWeightLabel(bool isMetric) {
    return isMetric ? 'kg' : 'lb';
  }

  static String getHeightLabel(bool isMetric) {
    return isMetric ? 'cm' : "ft'in\"";
  }

  static double convertWeight(double weightKg, bool toMetric) {
    return toMetric ? weightKg : weightKg / lbToKg;
  }

  static double standardizeWeight(double weight, bool isMetric) {
    return isMetric ? weight : weight * lbToKg;
  }

  static dynamic convertHeight(int heightCm, bool toMetric) {
    if (toMetric) return heightCm;

    final totalInches = (heightCm / inchToCm).round();
    final feet = (totalInches / 12).floor();
    final inches = totalInches % 12;

    return [feet, inches];
  }

  static String formatHeight(int heightCm, bool isMetric) {
    if (isMetric) return '$heightCm cm';

    final result = convertHeight(heightCm, false) as List<int>;
    return '${result[0]} ft ${result[1]} in';
  }

  static String formatWeight(double weightKg, bool isMetric,
      {int decimalPlaces = 0}) {
    final weight = convertWeight(weightKg, isMetric);
    return '${weight.toStringAsFixed(decimalPlaces)} ${getWeightLabel(isMetric)}';
  }

  static int parseImperialHeight(List<int> feetInches) {
    final feet = feetInches[0];
    final inches = feetInches[1];
    final heightCm = ((feet * feetToCm) + (inches * inchToCm)).round();

    return heightCm;
  }

  static int childCountWeightPicker(bool isMetric) {
    return isMetric ? 221 : 487;
  }

  static List<int> childCountHeightPicker(bool isMetric) {
    return isMetric ? [141, 0] : [4, 12];
  }

  static int initialItemHeightPicker() {
    return 170;
  }

  static double initialItemWeightPicker() {
    return 70;
  }

  static int offsetHeightPicker(bool isMetric) {
    return isMetric ? 100 : 4;
  }

  static double offsetWeightPicker(bool isMetric) {
    return isMetric ? 30 : 66;
  }
}
