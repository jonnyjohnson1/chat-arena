import 'package:flutter/material.dart';

class UserImageWidget extends StatelessWidget {
  
  final status;
  final _deviceHeight;

  UserImageWidget(this.status, this._deviceHeight);
  
  @override
  Widget build(BuildContext context) {
    double _imageRadius = _deviceHeight * 0.05;
    return Container(
        height: _imageRadius,
        width: _imageRadius,
        child: ClipOval(
          child: Material(
            color: Colors.orange, // button color
            child: InkWell(
              splashColor: Colors.red, // inkwell color
              child: SizedBox(
                width: 56, 
                height: 56, 
                child: status == "winner" ? Icon(Icons.whatshot) : Container()),
              onTap: () {},
            ),
          ),
        )
        // decoration: BoxDecoration(
        //   borderRadius: BorderRadius.circular(500),
        //   image: DecorationImage(
        //     fit: BoxFit.cover,
        //     image: NetworkImage(this.widget.),
        //     ))
        );
  }
  }