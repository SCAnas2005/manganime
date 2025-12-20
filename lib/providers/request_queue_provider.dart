import 'dart:async';

import 'package:flutter_application_1/services/jikan_service.dart';

class RequestQueue {
  RequestQueue._();
  static final RequestQueue instance = RequestQueue._();

  final _queue = <_RequestJob>[];
  bool _processing = false;

  // delay entre chaque requête
  Duration spacing = Duration(
    milliseconds: (1000 / JikanService().reqPerSec).toInt() + 100,
  );

  Future<T> enqueue<T>(Future<T> Function() task) {
    final job = _RequestJob<T>(task);
    _queue.add(job);

    _process();

    return job.completer.future;
  }

  Future<void> _process() async {
    if (_processing) return;
    _processing = true;

    while (_queue.isNotEmpty) {
      final job = _queue.removeAt(0);

      try {
        final result = await job.task();
        job.completer.complete(result);
      } catch (e, st) {
        job.completer.completeError(e, st);
      }

      // espacer les requêtes
      await Future.delayed(spacing);
    }

    _processing = false;
  }
}

class _RequestJob<T> {
  final Future<T> Function() task;
  final Completer<T> completer = Completer<T>();

  _RequestJob(this.task);
}
