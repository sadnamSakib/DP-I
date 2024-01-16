import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DegreeCheckbox extends StatefulWidget {
  final String degree;
  final bool isChecked;
  final ValueChanged<bool> onChecked;

  DegreeCheckbox({super.key,
    required this.degree,
    required this.isChecked,
    required this.onChecked,
  });

  @override
  _DegreeCheckboxState createState() => _DegreeCheckboxState();
}
class _DegreeCheckboxState extends State<DegreeCheckbox> {
  bool isChecked=false;

  @override
  void initState() {
    super.initState();
    isChecked = widget.isChecked;
  }

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(widget.degree),
      value: isChecked,
      onChanged: (bool? value) {
        setState(() {
          isChecked = value ?? false;
        });
        widget.onChecked(isChecked);
      },
    );
  }
}