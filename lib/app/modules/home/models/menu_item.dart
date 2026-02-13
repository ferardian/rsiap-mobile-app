import 'package:flutter/material.dart';

class MenuItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  MenuItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
