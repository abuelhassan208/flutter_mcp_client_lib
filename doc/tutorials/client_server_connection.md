# Client-Server Connection Tutorial

This tutorial explains how to establish a connection between an MCP client and server using the Flutter MCP package.

## Prerequisites

Before you begin, make sure you have:

- Flutter SDK installed (version 3.0.0 or higher)
- Dart SDK installed (version 3.0.0 or higher)
- Flutter MCP package added to your project
- Basic understanding of asynchronous programming in Dart

## Setting Up the Client

### 1. Create a Client Instance

First, create an instance of `McpClient` with the appropriate configuration:

```dart
import 'package:flutter_mcp/flutter_mcp.dart';
import 'package:logging/logging.dart';

void main() {
  // Set up logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  // Create a client
  final client = McpClient(
    name: 'My Flutter App',
    version: '1.0.0',
    capabilities: const ClientCapabilities(
      sampling: SamplingCapabilityConfig(sample: true),
      resources: ResourceCapabilityConfig(list: true, read: true),
      tools: ToolCapabilityConfig(list: true, call: true),
      prompts: PromptCapabilityConfig(list: true, get: true),
    ),
  );
  
  // Use the client...
}
```

The `capabilities` parameter specifies what features your client supports:
- `sampling`: Whether your client can handle sample requests
- `resources`: Whether your client can list and read resources
- `tools`: Whether your client can list and call tools
- `prompts`: Whether your client can list and get prompts

### 2. Create a Transport

Next, create a transport to connect to the server. The Flutter MCP package provides two transport implementations:

#### WebSocket Transport

```dart
final transport = McpWebSocketClientTransport(
  Uri.parse('ws://localhost:8080/mcp'),
);
```

The WebSocket transport is recommended for most applications because it provides:
- Bidirectional communication
- Lower latency
- Persistent connection
- Support for notifications

#### HTTP Transport

```dart
final transport = McpHttpClientTransport(
  Uri.parse('http://localhost:8080/mcp'),
);
```

The HTTP transport is useful in situations where WebSockets are not available or when you only need to make occasional requests.

### 3. Connect to the Server

Once you have created a client and transport, you can connect to the server:

```dart
try {
  await client.connect(transport);
  print('Connected to server');
  
  // Use the client to interact with the server...
  
} catch (e) {
  print('Failed to connect: $e');
} finally {
  // Disconnect when done
  await client.disconnect();
}
```

When you call `connect()`, the client will:
1. Establish a connection to the server using the provided transport
2. Send an `initialize` request to the server
3. Negotiate capabilities with the server
4. Set up event handlers for notifications and other messages

## Implementing Error Handling and Reconnection

In a production application, you should implement robust error handling and reconnection logic:

```dart
class McpConnectionManager {
  final McpClient client;
  final Uri serverUri;
  final Duration reconnectInterval;
  
  bool _isConnected = false;
  Timer? _reconnectTimer;
  
  McpConnectionManager({
    required this.client,
    required this.serverUri,
    this.reconnectInterval = const Duration(seconds: 5),
  });
  
  Future<void> connect() async {
    if (_isConnected) return;
    
    try {
      final transport = McpWebSocketClientTransport(serverUri);
      await client.connect(transport);
      _isConnected = true;
      _cancelReconnectTimer();
      
      print('Connected to server');
    } catch (e) {
      print('Failed to connect: $e');
      _scheduleReconnect();
    }
  }
  
  Future<void> disconnect() async {
    if (!_isConnected) return;
    
    try {
      await client.disconnect();
      _isConnected = false;
      _cancelReconnectTimer();
      
      print('Disconnected from server');
    } catch (e) {
      print('Failed to disconnect: $e');
    }
  }
  
  void _scheduleReconnect() {
    _cancelReconnectTimer();
    
    _reconnectTimer = Timer(reconnectInterval, () {
      print('Attempting to reconnect...');
      connect();
    });
  }
  
  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }
}
```

You can use this connection manager in your application:

```dart
final connectionManager = McpConnectionManager(
  client: client,
  serverUri: Uri.parse('ws://localhost:8080/mcp'),
);

await connectionManager.connect();

// Use the client...

await connectionManager.disconnect();
```

## Handling Connection Events

The `McpClient` class provides several methods for handling connection events:

```dart
client.onConnected = () {
  print('Connected to server');
};

client.onDisconnected = () {
  print('Disconnected from server');
};

client.onError = (error) {
  print('Error: $error');
};

client.onSampleRequest = (request) async {
  // Handle sample request...
  return SampleResult(...);
};
```

## Conclusion

In this tutorial, you learned how to:
- Create an MCP client with appropriate capabilities
- Choose and configure a transport (WebSocket or HTTP)
- Connect to an MCP server
- Implement error handling and reconnection logic
- Handle connection events

Next, you can explore how to use the client to interact with resources, tools, and prompts provided by the server.
