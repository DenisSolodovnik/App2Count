import 'dart:async';
import 'package:flutter/material.dart';

typedef LongTapCallback = void Function(double duration, int timesFired);
typedef SwipeCallback = void Function(DragUpdateDetails details);

class LongTapButton extends StatefulWidget {
  final Widget icon; //IconData icon;
  final double? iconSize;
  final Color iconColor, color;
  final double size;
  final double cornerRadius;

  final LongTapCallback fireCallback;
  final SwipeCallback? swipeCallback;

  const LongTapButton(
      {required Key key,
      required this.icon,
      this.iconSize,
      required this.iconColor,
      required this.color,
      required this.size,
      double? cornerRadius,
      required this.fireCallback,
      this.swipeCallback})
      : cornerRadius = cornerRadius ?? 0,
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LongTapButtonState();
  }
}

class _LongTapButtonState extends State<LongTapButton> {
  final _isPressed = false;
  Timer? _longTapTimer;
  var _timesFired = 0;

  @override
  Widget build(BuildContext context) {
    var backgroundColor = _isPressed ? Colors.white : widget.color;
    return GestureDetector(
      onTap: () {
        widget.fireCallback(0, 0);
        _resetTimer();
      },
      onLongPress: () {
        widget.fireCallback(0, _timesFired);
        _startTimer();
      },
      onLongPressEnd: (details) {
        _resetTimer();
      },
      onHorizontalDragUpdate: (details) {
        if (widget.swipeCallback != null) {
          widget.swipeCallback!(details);
        }
      },
      child: Container(
        height: widget.size,
        width: widget.size,
        child: widget.icon, // Icon(widget.icon, color: widget.iconColor, size: widget.iconSize),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(widget.cornerRadius),
              bottomRight: Radius.circular(widget.cornerRadius),
              topLeft: Radius.circular(widget.cornerRadius),
              topRight: Radius.circular(widget.cornerRadius),
            ),
            color: backgroundColor),
      ),
    );
  }

  void _startTimer() {
    _longTapTimer = Timer(const Duration(milliseconds: 300), _timerFired);
  }

  void _resetTimer() {
    _longTapTimer?.cancel();
    _timesFired = 0;
  }

  void _timerFired() {
    widget.fireCallback(0, _timesFired);
    _timesFired++;
    _startTimer();
  }
}
