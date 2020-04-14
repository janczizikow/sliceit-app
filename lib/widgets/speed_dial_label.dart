import 'package:flutter/material.dart';

class SpeedDialLabel extends StatelessWidget {
  final String title;
  final String subTitle;

  const SpeedDialLabel({
    Key key,
    @required this.title,
    @required this.subTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.body2,
          ),
          const SizedBox(height: 4),
          Text(
            subTitle,
            style: Theme.of(context).textTheme.caption,
          )
        ],
      ),
    );
  }
}
