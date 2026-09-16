import 'package:flutter/material.dart';

class TravelCategory {
  final String title;
  final IconData icon;

  const TravelCategory({
    required this.title,
    required this.icon,
  });
}

const travelCategories = [
  TravelCategory(title: "All", icon: Icons.apps),
  TravelCategory(title: "Nature", icon: Icons.park),
  TravelCategory(title: "Islands", icon: Icons.beach_access),
  TravelCategory(title: "Wildlife", icon: Icons.pets),
  TravelCategory(title: "Adventure", icon: Icons.landscape),
  TravelCategory(title: "Food", icon: Icons.restaurant),
  TravelCategory(title: "City", icon: Icons.location_city),
  TravelCategory(title: "Culture", icon: Icons.museum),
];

const postCategories = [
  "Nature",
  "Islands",
  "Wildlife",
  "Adventure",
  "Food",
  "Culture",
  "City",
];

Color categoryColor(String category) {
  switch (category.toLowerCase()) {
    case "nature":
      return Colors.green.shade600;
    case "islands":
      return Colors.blue.shade600;
    case "wildlife":
      return Colors.orange.shade700;
    case "adventure":
      return Colors.deepPurple.shade600;
    case "food":
      return Colors.red.shade600;
    case "culture":
      return Colors.brown.shade600;
    case "city":
      return Colors.teal.shade600;
    default:
      return Colors.grey.shade600;
  }
}

IconData categoryIcon(String category) {
  switch (category.toLowerCase()) {
    case "nature":
      return Icons.park;
    case "islands":
      return Icons.beach_access;
    case "wildlife":
      return Icons.pets;
    case "adventure":
      return Icons.hiking;
    case "food":
      return Icons.restaurant;
    case "culture":
      return Icons.museum;
    case "city":
      return Icons.location_city;
    default:
      return Icons.place;
  }
}
