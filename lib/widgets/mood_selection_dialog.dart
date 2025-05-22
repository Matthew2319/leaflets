import 'package:flutter/material.dart';
import '../models/mood.dart';

class MoodSelectionDialog extends StatefulWidget {
  final String initialMood;
  final Function(String) onSave;
  final VoidCallback onCancel;

  const MoodSelectionDialog({
    super.key,
    required this.initialMood,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<MoodSelectionDialog> createState() => _MoodSelectionDialogState();
}

class _MoodSelectionDialogState extends State<MoodSelectionDialog> {
  late String _selectedMood;
  late int _moodIndex;
  late List<String> _relatedMoods;
  String _selectedRelatedMood = '';

  @override
  void initState() {
    super.initState();
    _selectedMood = widget.initialMood;
    _moodIndex = MoodData.moods.indexWhere((mood) => mood.name == _selectedMood);
    if (_moodIndex == -1) _moodIndex = 3; // Default to Neutral
    _relatedMoods = MoodData.moods[_moodIndex].relatedMoods;
  }

  void _updateMoodFromSlider(double value) {
    final index = value.round();
    setState(() {
      _moodIndex = index;
      _selectedMood = MoodData.moods[index].name;
      _relatedMoods = MoodData.moods[index].relatedMoods;
      _selectedRelatedMood = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 24.0),
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5DB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How are you feeling?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              MoodData.moods[_moodIndex].emoji,
              style: TextStyle(
                fontSize: 48,
                color: const Color(0xFF9C834F),
              ),
            ),
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: const Color(0xFF9C834F),
                inactiveTrackColor: const Color(0xFF9C834F).withOpacity(0.3),
                thumbColor: const Color(0xFFF5F5DB),
                overlayColor: const Color(0xFF9C834F).withOpacity(0.2),
                thumbShape: RoundedRectangleSliderThumbShape(),
                trackHeight: 8,
              ),
              child: Slider(
                value: _moodIndex.toDouble(),
                min: 0,
                max: 6,
                divisions: 6,
                onChanged: _updateMoodFromSlider,
              ),
            ),
            const SizedBox(height: 16),
            _buildMoodDropdown(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 28,
                  ),
                  onPressed: widget.onCancel,
                ),
                IconButton(
                  icon: Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 28,
                  ),
                  onPressed: () {
                    final finalMood = _selectedRelatedMood.isNotEmpty 
                        ? _selectedRelatedMood 
                        : _selectedMood;
                    widget.onSave(finalMood);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF9C834F).withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: _selectedRelatedMood.isEmpty ? null : _selectedRelatedMood,
        hint: Text(
          _selectedMood,
          style: TextStyle(
            color: const Color(0xFF9C834F),
          ),
        ),
        isExpanded: true,
        icon: Icon(
          Icons.arrow_drop_down,
          color: const Color(0xFF9C834F),
        ),
        underline: SizedBox(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedRelatedMood = newValue ?? '';
          });
        },
        items: _relatedMoods.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(
                color: const Color(0xFF9C834F),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class RoundedRectangleSliderThumbShape extends SliderComponentShape {
  final double width;
  final double height;

  RoundedRectangleSliderThumbShape({
    this.width = 20.0,
    this.height = 20.0,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(width, height);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final rect = Rect.fromCenter(
      center: center,
      width: width,
      height: height,
    );

    final paint = Paint()
      ..color = const Color(0xFF9C834F)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(4.0)),
      paint,
    );
  }
}