### Flutter App Example

```dart
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
        _statusMessage = 'Connected to ${serverUrl}';
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('URI: $uri'),
              const SizedBox(height: 8),
              const Text('Contents:'),
              ...contents.map((content) => Text('- ${content.text}')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );

      setState(() {
        _statusMessage = 'Resource read successfully';
      });
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

  Future<void> _callTool(ToolInfo tool) async {
    // This is a simple example that calls the 'add' tool with fixed arguments
    // In a real app, you would collect the arguments from the user

    setState(() {
      _isLoading = true;
      _statusMessage = 'Calling tool ${tool.name}...';
    });

    try {
      Map<String, dynamic> args = {};

      // Simple example for the 'add' tool
      if (tool.name == 'add') {
        args = {'a': '5', 'b': '7'};
      }
      // Simple example for the 'echo' tool
      else if (tool.name == 'echo') {
        args = {'message': 'Hello from Flutter MCP Demo!'};
      }

      final result = await _client!.callTool(tool.name, args);

      // Show the tool result in a dialog
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Tool: ${tool.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Arguments: $args'),
              const SizedBox(height: 8),
              const Text('Result:'),
              ...result.content.map((content) => Text('- ${content.text}')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );

      setState(() {
        _statusMessage = 'Tool called successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to call tool: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getPrompt(PromptInfo prompt) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Getting prompt ${prompt.name}...';
    });

    try {
      // Simple example for the 'greeting' prompt
      final args = {'name': 'Flutter Developer'};

      final result = await _client!.getPrompt(prompt.name, args);

      // Show the prompt result in a dialog
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Prompt: ${prompt.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Arguments: $args'),
              const SizedBox(height: 8),
              Text('Description: ${result.description}'),
              const SizedBox(height: 8),
              const Text('Messages:'),
              ...result.messages.map((message) =>
                Text('- ${message.role}: ${message.content.text}')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );

      setState(() {
        _statusMessage = 'Prompt retrieved successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to get prompt: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _serverUrlController,
              decoration: const InputDecoration(
                labelText: 'Server URL',
                border: OutlineInputBorder(),
              ),
              enabled: !_isConnected && !_isLoading,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading
                ? null
                : (_isConnected ? _disconnect : _connect),
              child: Text(_isConnected ? 'Disconnect' : 'Connect'),
            ),
            const SizedBox(height: 16),
            Text(
              _statusMessage,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_isConnected)
              Expanded(
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      const TabBar(
                        tabs: [
                          Tab(text: 'Resources'),
                          Tab(text: 'Tools'),
                          Tab(text: 'Prompts'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Resources tab
                            _resources.isEmpty
                              ? const Center(child: Text('No resources available'))
                              : ListView.builder(
                                  itemCount: _resources.length,
                                  itemBuilder: (context, index) {
                                    final resource = _resources[index];
                                    return ListTile(
                                      title: Text(resource.name),
                                      subtitle: Text(resource.description),
                                      trailing: const Icon(Icons.arrow_forward),
                                      onTap: () => _readResource(resource),
                                    );
                                  },
                                ),

                            // Tools tab
                            _tools.isEmpty
                              ? const Center(child: Text('No tools available'))
                              : ListView.builder(
                                  itemCount: _tools.length,
                                  itemBuilder: (context, index) {
                                    final tool = _tools[index];
                                    return ListTile(
                                      title: Text(tool.name),
                                      subtitle: Text(tool.description),
                                      trailing: const Icon(Icons.arrow_forward),
                                      onTap: () => _callTool(tool),
                                    );
                                  },
                                ),

                            // Prompts tab
                            _prompts.isEmpty
                              ? const Center(child: Text('No prompts available'))
                              : ListView.builder(
                                  itemCount: _prompts.length,
                                  itemBuilder: (context, index) {
                                    final prompt = _prompts[index];
                                    return ListTile(
                                      title: Text(prompt.name),
                                      subtitle: Text(prompt.description),
                                      trailing: const Icon(Icons.arrow_forward),
                                      onTap: () => _getPrompt(prompt),
                                    );
                                  },
                                ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```
