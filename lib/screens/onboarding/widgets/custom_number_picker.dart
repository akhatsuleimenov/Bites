import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A horizontally scrollable "ruler" style number picker.
class RulerNumberPicker extends StatefulWidget {
  final int minValue;
  final int maxValue;
  final int initialValue;
  final Color indicatorColor;
  final double indicatorWidth;
  final TextStyle? textStyle;
  final ValueChanged<int>? onValueChanged;
  final String unit;

  const RulerNumberPicker({
    Key? key,
    required this.minValue,
    required this.maxValue,
    required this.initialValue,
    this.indicatorColor = Colors.green,
    this.indicatorWidth = 2.0,
    this.textStyle,
    this.onValueChanged,
    required this.unit,
  }) : super(key: key);

  @override
  State<RulerNumberPicker> createState() => _RulerNumberPickerState();
}

class _RulerNumberPickerState extends State<RulerNumberPicker> {
  late ScrollController _scrollController;
  final double _stepWidth = 12.0; // Adjusted for better spacing
  late int _selectedValue;
  bool _isAnimating = false; // Add this flag

  @override
  void initState() {
    super.initState();
    _selectedValue =
        widget.initialValue.clamp(widget.minValue, widget.maxValue);
    _scrollController = ScrollController(
      initialScrollOffset: (_selectedValue - widget.minValue) * _stepWidth,
    );
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isAnimating) return; // Skip if we're already animating

    final double offset = _scrollController.offset;
    final double rawValue = offset / _stepWidth + widget.minValue;
    final int roundedValue =
        rawValue.round().clamp(widget.minValue, widget.maxValue);

    if (roundedValue != _selectedValue) {
      HapticFeedback.selectionClick();
      setState(() {
        _selectedValue = roundedValue;
      });
      widget.onValueChanged?.call(_selectedValue);
    }
  }

  void _animateToSelectedValue() {
    if (_isAnimating) return;

    _isAnimating = true;
    final targetOffset = (_selectedValue - widget.minValue) * _stepWidth;

    _scrollController
        .animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
    )
        .then((_) {
      _isAnimating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalSteps = (widget.maxValue - widget.minValue);
    final totalWidth = totalSteps * _stepWidth;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$_selectedValue ${widget.unit}',
          style: widget.textStyle ??
              const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 60,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            alignment: Alignment.center,
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollEndNotification && !_isAnimating) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _animateToSelectedValue();
                    });
                  }
                  return true;
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width / 2,
                    ),
                    child: CustomPaint(
                      painter: _RulerPainter(
                        minValue: widget.minValue,
                        maxValue: widget.maxValue,
                        stepWidth: _stepWidth,
                        selectedValue: _selectedValue,
                      ),
                      child: SizedBox(width: totalWidth, height: 80),
                    ),
                  ),
                ),
              ),
              Container(
                width: widget.indicatorWidth,
                height: 60,
                color: widget.indicatorColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The custom painter that draws the tick marks.
/// Long ticks for each integer, short ticks for each step in between (if you want fractional steps).
class _RulerPainter extends CustomPainter {
  final int minValue;
  final int maxValue;
  final double stepWidth;
  final int selectedValue;

  _RulerPainter({
    required this.minValue,
    required this.maxValue,
    required this.stepWidth,
    required this.selectedValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = 1.0;

    for (int value = minValue; value <= maxValue; value++) {
      final double x = (value - minValue) * stepWidth;
      final bool isMajorTick = value % 5 == 0;

      // Use a light gray for ticks
      paint.color = const Color(0xFFCCCCCC);

      // Determine tick height
      double tickHeight = isMajorTick ? 20.0 : 10.0;

      // Draw tick
      final startY = size.height - tickHeight;
      final endY = size.height;
      canvas.drawLine(Offset(x, startY), Offset(x, endY), paint);

      // Draw numbers for major ticks
      if (isMajorTick) {
        final textSpan = TextSpan(
          text: value.toString(),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF999999),
            fontWeight: FontWeight.w400,
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        // Position text above the tick marks
        textPainter.paint(
          canvas,
          Offset(x - (textPainter.width / 2), startY - 25),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RulerPainter oldDelegate) =>
      oldDelegate.selectedValue != selectedValue;
}
