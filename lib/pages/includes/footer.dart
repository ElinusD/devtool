import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Row getFooter() {
  return Row(
    children: [
      Expanded(
        child: Container(
          height: 30.0,
          // Set your desired fixed height
          color: const Color.fromRGBO(7, 38, 79, 25),
          padding: const EdgeInsets.only(bottom: 5),
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.only(right: 20),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (event) {
                    // setState(() {
                    //   helpIsHovered = true;
                    // });
                  },
                  onExit: (event) {
                    // setState(() {
                    //   helpIsHovered = false;
                    // });
                  },
                  child: Text(
                    'Help',
                    style: TextStyle(
                      // color: helpIsHovered ? Colors.white : Colors.grey,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(right: 20),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (event) {
                    // setState(() {
                    //   aboutIsHovered = true;
                    // });
                  },
                  onExit: (event) {
                    // setState(() {
                    //   aboutIsHovered = false;
                    // });
                  },
                  child: Text(
                    'About',
                    style: TextStyle(
                      // color: aboutIsHovered ? Colors.white : Colors.grey,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
