import 'package:flutter/material.dart';

class StarRating extends StatefulWidget {
  final int initialRating;
  final bool readOnly;
  final double size;
  final Color? color;
  final Function(int)? onRatingChanged;

  const StarRating({
    super.key,
    this.initialRating = 0,
    this.readOnly = false,
    this.size = 24.0,
    this.color,
    this.onRatingChanged,
  });

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  late int _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  void didUpdateWidget(StarRating oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRating != widget.initialRating) {
      _currentRating = widget.initialRating;
    }
  }

  void _handleTap(int rating) {
    if (!widget.readOnly) {
      setState(() {
        _currentRating = rating;
      });
      widget.onRatingChanged?.call(rating);
    }
  }

  @override
  Widget build(BuildContext context) {
    final starColor = widget.color ?? Colors.amber;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isFilled = starIndex <= _currentRating;
        
        return GestureDetector(
          onTap: widget.readOnly ? null : () => _handleTap(starIndex),
          child: Icon(
            isFilled ? Icons.star : Icons.star_border,
            color: isFilled ? starColor : Colors.grey,
            size: widget.size,
          ),
        );
      }),
    );
  }
}

