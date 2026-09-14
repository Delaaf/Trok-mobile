import 'package:flutter/material.dart';

class CategoryItem {
  const CategoryItem({required this.id, required this.name, required this.icon});

  final int id;
  final String name;
  final IconData icon;
}

/// Correspond exactement aux catégories créées par le CategorySeeder backend.
/// À remplacer par un appel API (GET /categories) une fois le provider branché.
const mockCategories = <CategoryItem>[
  CategoryItem(id: 1, name: 'Vêtements', icon: Icons.checkroom_outlined),
  CategoryItem(id: 2, name: 'Chaussures', icon: Icons.ice_skating_outlined),
  CategoryItem(id: 3, name: 'Téléphones', icon: Icons.smartphone_outlined),
  CategoryItem(id: 4, name: 'Ordinateurs', icon: Icons.laptop_mac_outlined),
  CategoryItem(id: 5, name: 'Consoles', icon: Icons.sports_esports_outlined),
  CategoryItem(id: 6, name: 'Meubles', icon: Icons.chair_outlined),
  CategoryItem(id: 7, name: 'Électroménager', icon: Icons.kitchen_outlined),
  CategoryItem(id: 8, name: 'Véhicules', icon: Icons.directions_car_outlined),
  CategoryItem(id: 9, name: 'Immobilier', icon: Icons.home_work_outlined),
  CategoryItem(id: 10, name: 'Agricole', icon: Icons.grass_outlined),
];
