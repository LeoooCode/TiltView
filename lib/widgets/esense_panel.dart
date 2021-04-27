import 'package:flutter/material.dart';

class ESensePanel extends StatelessWidget {
  const ESensePanel({Key key, this.color, this.text, this.button})
      : super(key: key);

  final Color color;
  final String text;
  final Widget button;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(40, 25, 40, 25),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 5)],
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(0),
          bottom: Radius.elliptical(170, 25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            "assets/esense.jpg",
            width: 200,
          ),
          SizedBox(
            height: 7,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.circle,
                color: color,
                size: 10,
              ),
              SizedBox(width: 3),
              Text(
                text,
                style: TextStyle(color: color, fontSize: 16),
              )
            ],
          ),
          SizedBox(
            height: 30,
          ),
          button
        ],
      ),
    );
  }
}
