import 'package:flutter/material.dart';

Widget buildRadio() {
  return RadioGroup<String>(
    groupValue: '1',
    onChanged: (v) {},
    child: Radio<String>(value: '1'),
  );
}
