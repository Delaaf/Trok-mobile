import 'package:flutter/material.dart';

/// Le backend stocke `icon` comme un simple identifiant texte (voir CategorySeeder
/// côté Laravel : 'shirt', 'phone', 'car'...). On le traduit ici en IconData Flutter.
IconData iconForCategory(String? iconKey) {
  switch (iconKey) {
    case 'shirt':
      return Icons.checkroom_outlined;
    case 'shoe':
      return Icons.ice_skating_outlined;
    case 'phone':
      return Icons.smartphone_outlined;
    case 'laptop':
      return Icons.laptop_mac_outlined;
    case 'console':
      return Icons.sports_esports_outlined;
    case 'sofa':
      return Icons.chair_outlined;
    case 'appliance':
      return Icons.kitchen_outlined;
    case 'car':
      return Icons.directions_car_outlined;
    case 'home':
      return Icons.home_work_outlined;
    case 'leaf':
      return Icons.grass_outlined;
    default:
      return Icons.category_outlined;
  }
}
