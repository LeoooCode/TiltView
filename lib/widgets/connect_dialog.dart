import 'package:flutter/material.dart';

import '../home_screen.dart';

class ConnectDialog extends StatefulWidget {
  const ConnectDialog({
    Key key,
    this.callback,
  }) : super(key: key);

  final Function(String) callback;

  @override
  _ConnectDialogState createState() => _ConnectDialogState();
}

class _ConnectDialogState extends State<ConnectDialog> {
  TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController();
    controller.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    // controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Connect to erable"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Type in the bluetooth name of the left earable containing the sensors. " +
              "This earable does not have to be connected to the phone yet."),
          SizedBox(height: 20),
          TextField(
            controller: controller,
            decoration: InputDecoration(
                hintText: 'eSense-XXXX',
                isDense: true,
                contentPadding: EdgeInsets.all(0)),
          )
        ],
      ),
      actions: [
        MaterialButton(
          color: Colors.blue,
          textColor: Colors.white,
          child: IconText(icon: Icons.check, text: "Connect"),
          onPressed: controller.text.length > 0
              ? () => widget.callback(controller.text)
              : null,
        ),
      ],
    );
  }
}
