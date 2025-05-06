// lib/components/live_time_widget.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LiveTimeWidget extends StatefulWidget {
  const LiveTimeWidget({super.key});

  @override
  State<LiveTimeWidget> createState() => _LiveTimeWidgetState();
}

class _LiveTimeWidgetState extends State<LiveTimeWidget> {
  late Timer _timer;
  String _formattedTime = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy년 M월 d일 a h:mm:ss', 'ko');
    setState(() {
      _formattedTime = formatter.format(now);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formattedTime,
      style: const TextStyle(fontSize: 16, color: Colors.black),
    );
  }
}
