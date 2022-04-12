import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../config/palette.dart';

class AddPostPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.backgroundColor,
        appBar: AppBar(
          backgroundColor: Palette.backgroundColor,
          foregroundColor: Palette.textColor,
          elevation: 0, //no shadow
          automaticallyImplyLeading: false, //no arrow
        ),
        body: Center(
          child: Text(
            'Add post',
            style: TextStyle(fontSize: 30, color: Colors.black),
          ),
        ),
      );
}
