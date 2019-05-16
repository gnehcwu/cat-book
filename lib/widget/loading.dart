import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  const Loading({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            new CircularProgressIndicator(),
            SizedBox(
              height: 15,
            ),
            new Text("Loading..."),
          ],
        ),
      );
  }
}
