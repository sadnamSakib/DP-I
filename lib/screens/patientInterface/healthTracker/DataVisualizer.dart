import 'package:flutter/material.dart';

class DataVisualizer extends StatelessWidget {
  final String title;
  final String data;
  final Color circleColor;
  final double radius;

  DataVisualizer({
    required this.title,
    required this.data,
    required this.circleColor,
    this.radius = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            color: Colors.black, // Customize title text color.
            fontSize: 16.0, // Add your desired title font size.
          ),
        ),
        SizedBox(height: 8), // Adjust the space between title and circle.
        Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: circleColor, // Set circle color to the provided color.
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 4.0,
              ),
            ],
          ),
          child: Center(
            child: Text(
              textAlign: TextAlign.center,
              data,
              style: TextStyle(
                color: Colors.white, // Customize data text color.
                fontWeight: FontWeight.bold, // Add any desired data text styles.
                fontSize: 16.0, // Add your desired data font size.
              ),
            ),
          ),
        ),
      ],
    );
  }
}
