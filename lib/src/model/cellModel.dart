import 'package:flutter/material.dart';

class Cell {
  int count;
  int owner;
  Color color;

  Cell({
    this.count = 0,
    this.owner = 0,
    this.color = Colors.transparent,
  });
}
