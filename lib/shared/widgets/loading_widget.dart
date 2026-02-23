import 'package:flutter/material.dart';

/// Hiển thị loading indicator toàn màn hình hoặc inline
class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool fullScreen;

  const LoadingWidget({super.key, this.message, this.fullScreen = false});

  const LoadingWidget.fullScreen({super.key, this.message = 'Đang tải...'})
      : fullScreen = true;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(message!, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ],
    );

    if (fullScreen) {
      return Scaffold(
        body: Center(child: content),
      );
    }
    return Center(child: Padding(padding: const EdgeInsets.all(24), child: content));
  }
}
