/// Example of using the MCP UI components
///
/// This example shows how to use the MCP UI components to render
/// MCP responses in a Flutter application.
library;

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

// Using the package import
import 'package:flutter_mcp_client_lib/flutter_mcp.dart';

void main() {
  // Set up logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });

  runApp(const McpUiExampleApp());
}

/// Example app for demonstrating MCP UI components
class McpUiExampleApp extends StatelessWidget {
  const McpUiExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MCP UI Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const McpUiExamplePage(),
    );
  }
}

/// Main page for the MCP UI example
class McpUiExamplePage extends StatefulWidget {
  const McpUiExamplePage({super.key});

  @override
  State<McpUiExamplePage> createState() => _McpUiExamplePageState();
}

class _McpUiExamplePageState extends State<McpUiExamplePage> {
  final TextEditingController _serverUrlController = TextEditingController(
    text: 'ws://localhost:8080/mcp',
  );

  McpClient? _client;
  bool _isConnected = false;
  String _statusMessage = 'Not connected';
  McpTheme? _mcpTheme;

  // Example responses for demonstration
  final List<McpResponse> _exampleResponses = [
    // Text response example
    McpResponseImpl(
      id: 'text-example',
      result: {
        'text': 'This is an example text response from the MCP server. '
            'It demonstrates how text responses are rendered with the '
            'McpTextResponseWidget.',
      },
    ),
    // Code response example
    McpResponseImpl(
      id: 'code-example',
      result: {
        'code': '''
void main() {
  print('Hello, MCP!');

  // This is an example code block
  final client = McpClient(
    name: 'Example Client',
    version: '1.0.0',
  );

  // Connect to the server
  await client.connect(transport);
}''',
        'language': 'dart',
      },
    ),
    // Data response example
    McpResponseImpl(
      id: 'data-example',
      result: {
        'data': {
          'name': 'Example Data',
          'type': 'JSON',
          'properties': {
            'nested': true,
            'interactive': true,
            'values': [1, 2, 3, 4, 5],
          },
          'metadata': {
            'created': '2025-05-15T12:00:00Z',
            'version': '1.0.0',
          },
        },
      },
    ),
    // Error response example
    McpResponseImpl(
      id: 'error-example',
      error: McpError(
        code: McpErrorCodes.resourceNotFound,
        message: 'The requested resource was not found',
        data: {
          'uri': 'example://not-found',
          'timestamp': '2025-05-15T12:00:00Z',
        },
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _disconnect();
    _serverUrlController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    if (_isConnected) {
      return;
    }

    setState(() {
      _statusMessage = 'Connecting...';
    });

    try {
      final serverUrl = _serverUrlController.text;

      _client = McpClient(
        name: 'MCP UI Example',
        version: '1.0.0',
        capabilities: const ClientCapabilities(
          sampling: SamplingCapabilityConfig(sample: true),
          resources: ResourceCapabilityConfig(list: true, read: true),
          tools: ToolCapabilityConfig(list: true, call: true),
          prompts: PromptCapabilityConfig(list: true, get: true),
        ),
      );

      final transport = McpWebSocketClientTransport(Uri.parse(serverUrl));
      await _client!.connect(transport);

      setState(() {
        _isConnected = true;
        _statusMessage = 'Connected to $serverUrl';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Connection failed: $e';
      });
      _client = null;
    }
  }

  Future<void> _disconnect() async {
    if (!_isConnected || _client == null) {
      return;
    }

    try {
      await _client!.disconnect();
    } finally {
      setState(() {
        _isConnected = false;
        _statusMessage = 'Disconnected';
        _client = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize the MCP theme if it hasn't been initialized yet
    _mcpTheme ??= McpTheme.fromTheme(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MCP UI Example'),
        actions: [
          IconButton(
            icon: Icon(_isConnected ? Icons.link_off : Icons.link),
            onPressed: _isConnected ? _disconnect : _connect,
            tooltip: _isConnected ? 'Disconnect' : 'Connect',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _serverUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Server URL',
                      hintText: 'ws://localhost:8080/mcp',
                      border: OutlineInputBorder(),
                    ),
                    enabled: !_isConnected,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isConnected ? _disconnect : _connect,
                  child: Text(_isConnected ? 'Disconnect' : 'Connect'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              _statusMessage,
              style: TextStyle(
                color: _isConnected ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildExampleResponses(),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleResponses() {
    final renderer = McpResponseRenderer(
      theme: _mcpTheme!,
      onInteraction: _handleInteraction,
    );

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _exampleResponses.length,
      itemBuilder: (context, index) {
        final response = _exampleResponses[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: renderer.render(context, response),
        );
      },
    );
  }

  void _handleInteraction(
    String responseId,
    String interactionType,
    Map<String, dynamic> data,
  ) {
    debugPrint('Interaction: $responseId, $interactionType, $data');

    // Show a snackbar to demonstrate the interaction
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Interaction: $interactionType on $responseId'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
