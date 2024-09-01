import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Row getHeader() {
  return  Row(
    children: [
      const Icon(Icons.supervised_user_circle_rounded, size: 24.0),
      // Icon on the left side
      Spacer(),
      // Spacer to push the TextField to the center
      Container(
        width: 200.0, // Fixed width of TextField
        height: 30,
        child: TextField(
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Search',
            hintStyle: const TextStyle(fontSize: 12),
            filled: true,
            // Enable the background color
            fillColor: const Color.fromRGBO(230, 230, 230, 1),
            // Set the background color
            //contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0), // Adjust the height of the text field
            border: InputBorder.none,
            // Remove the border
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              // Border radius
              borderSide: BorderSide.none, // Remove the border
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              // Border radius
              borderSide: BorderSide.none, // Remove the border
            ),
          ),
        ),
      ),
      Spacer(),
    ],
  );
}