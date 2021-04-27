enum ConnectionStatus { connected, connecting, disconnected }

class ConnectionManager {
  static final ConnectionManager _instance = ConnectionManager._();

  ConnectionManager._();

  final List<Stream> streams = [];

  factory ConnectionManager() {
    return _instance;
  }
}
