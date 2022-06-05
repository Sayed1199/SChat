import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final Color mColor;
  const LoadingWidget({Key? key,required this.mColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(color: mColor,);
  }
}
