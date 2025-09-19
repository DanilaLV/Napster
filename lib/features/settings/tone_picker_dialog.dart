import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../data/models/settings.dart';

class TonePickerDialog extends StatefulWidget {
  const TonePickerDialog({required this.selected, required this.pro, super.key});

  final AlarmTone selected;
  final bool pro;

  @override
  State<TonePickerDialog> createState() => _TonePickerDialogState();
}

class _TonePickerDialogState extends State<TonePickerDialog> {
  late AlarmTone _selected = widget.selected;
  final _player = AudioPlayer();

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playTone(AlarmTone tone) async {
    final toneName = _toneAsset(tone);
    await _player.play(AssetSource('audio/$toneName.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    final tones = widget.pro ? AlarmTone.values : [AlarmTone.tone1];
    return AlertDialog(
      title: const Text('Select tone'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: tones.length,
          itemBuilder: (context, index) {
            final tone = tones[index];
            return RadioListTile<AlarmTone>(
              value: tone,
              groupValue: _selected,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selected = value);
              },
              title: Text('Tone ${index + 1}'),
              secondary: IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: () => _playTone(tone),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _selected),
          child: const Text('Select'),
        ),
      ],
    );
  }
}

String _toneAsset(AlarmTone tone) {
  switch (tone) {
    case AlarmTone.tone1:
      return 'tone1';
    case AlarmTone.tone2:
      return 'tone2';
    case AlarmTone.tone3:
      return 'tone3';
    case AlarmTone.tone4:
      return 'tone4';
    case AlarmTone.tone5:
      return 'tone5';
  }
}
