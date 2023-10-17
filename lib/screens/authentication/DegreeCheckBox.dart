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
  bool isChecked=false; // Local state to track the checked state

  @override
  void initState() {
    super.initState();
    isChecked = widget.isChecked; // Initialize the local state with the initial value
  }

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(widget.degree),
      value: isChecked, // Use the local state here
      onChanged: (bool? value) {
        setState(() {
          isChecked = value ?? false; // Update the local state and trigger a rebuild
        });
        widget.onChecked(isChecked); // Notify the parent widget about the change
      },
    );
  }
}