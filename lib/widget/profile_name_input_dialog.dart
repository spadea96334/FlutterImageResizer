import 'package:flutter/material.dart';

class ProfileNameInputDialog extends StatelessWidget {
  ProfileNameInputDialog({super.key, required this.onFinished});

  final TextEditingController _controller = TextEditingController();
  final Function(String value) onFinished;

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Container(
            padding: const EdgeInsets.all(16),
            width: 300,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Input profile name'),
              TextField(controller: _controller),
              const SizedBox(height: 5),
              Row(
                children: [const Spacer(), TextButton(onPressed: onPressed, child: const Text('OK'))],
              )
            ])));
  }

  void onPressed() {
    onFinished(_controller.text);
  }
}
