import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String content, bool isSuccess) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSuccess ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              isSuccess
                  ? Image.asset('assets/checked.png', width: 30, height: 30)
                  : Image.asset('assets/close.png', width: 30, height: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  content,
                  maxLines: null,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        duration: const Duration(seconds: 4),
      ),
    );
}
