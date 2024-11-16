import 'dart:async';

class UserDataNotifier {
  static final _controller = StreamController<void>.broadcast();

  static Stream<void> get stream => _controller.stream;

  static void notifyDataChanged() {
    _controller.add(null);
  }

  static void dispose() {
    _controller.close();
  }
}
