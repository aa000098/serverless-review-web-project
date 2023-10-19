import 'package:flutter/material.dart';

// 별점 보여주기
class StarDisplay extends StatelessWidget {
  final int value;
  const StarDisplay({this.value = 0});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < value ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }
}

// 별점 매기기
class StarRating extends StatelessWidget {
  final int value;
  final IconData filledStar;
  final IconData unfilledStar;
  final void Function(int index) onChanged;

  const StarRating({
    this.value = 0,
    required this.filledStar,
    required this.unfilledStar,
    required this.onChanged,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () {
            onChanged(value == index + 1 ? index : index + 1);
          },
          color: Colors.amber,
          iconSize: 30,
          icon: Icon(
            index < value ? filledStar : unfilledStar,
          ),
          padding: EdgeInsets.zero,
          tooltip: "${index + 1} of 5",
        );
      }),
    );
  }
}
