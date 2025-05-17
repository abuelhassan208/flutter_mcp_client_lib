// Example of using the Flutter MCP Client Library
import 'package:flutter/material.dart';
import 'package:flutter_mcp_client_lib/flutter_mcp_client_lib.dart';
import 'package:logging/logging.dart';

void main() {
  // Set up logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter MCP Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const McpDemoPage(title: 'Flutter MCP Demo'),
    );
  }
}

class McpDemoPage extends StatefulWidget {
  const McpDemoPage({super.key, required this.title});

  final String title;

  @override
  State<McpDemoPage> createState() => _McpDemoPageState();
}

class _McpDemoPageState extends State<McpDemoPage> {
  final TextEditingController _serverUrlController = TextEditingController(
    text: 'ws://localhost:8080/mcp',
  );

  McpClient? _client;
  bool _isConnected = false;
  bool _isLoading = false;
  List<ResourceInfo> _resources = [];
  List<ToolInfo> _tools = [];
  List<PromptInfo> _prompts = [];
  String _statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _serverUrlController,
              decoration: const InputDecoration(
                labelText: 'MCP Server URL',
                hintText: 'ws://localhost:8080/mcp',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isLoading || _isConnected ? null : _connect,
                  child: const Text('Connect'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading || !_isConnected ? null : _disconnect,
                  child: const Text('Disconnect'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _statusMessage,
              style: TextStyle(
                color: _isConnected ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_isConnected) ...[
              const Text(
                'Resources:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _resources.length,
                  itemBuilder: (context, index) {
                    final resource = _resources[index];
                    return ListTile(
                      title: Text(resource.name),
                      subtitle: Text(resource.description),
                      trailing: IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () => _readResource(resource),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _connect() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Connecting...';
    });

    try {
      final serverUrl = _serverUrlController.text;

      _client = McpClient(
        name: 'Flutter MCP Demo',
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

      // Load resources
      final resources = await _client!.listResources();

      // Load tools
      final tools = await _client!.listTools();

      // Load prompts
      final prompts = await _client!.listPrompts();

      setState(() {
        _isConnected = true;
        _resources = resources;
        _tools = tools;
        _prompts = prompts;
        _statusMessage = 'Connected to $serverUrl';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Connection failed: $e';
      });
      _client = null;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _disconnect() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Disconnecting...';
    });

    try {
      await _client!.disconnect();

      setState(() {
        _isConnected = false;
        _resources = [];
        _tools = [];
        _prompts = [];
        _statusMessage = 'Disconnected';
      });

      _client = null;
    } catch (e) {
      setState(() {
        _statusMessage = 'Disconnection failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _readResource(ResourceInfo resource) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Reading resource ${resource.name}...';
    });

    try {
      // For template URIs, we need to replace parameters with actual values
      // This is a simple example that replaces {name} with 'Flutter'
      final uri = resource.uriTemplate.replaceAll('{name}', 'Flutter');

      final contents = await _client!.readResource(uri);

      // Show the resource contents in a dialog
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Resource: ${resource.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('URI: $uri'),
                const SizedBox(height: 8),
                const Text('Contents:'),
                ...contents.map((content) => Text('- ${content.text}')),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to read resource: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
