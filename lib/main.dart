import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
// Import our local MCP implementation
import 'flutter_mcp.dart';

void main() {
  // Set up logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    // Using debugPrint which is safe for production code
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MCP Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const McpDemoPage(title: 'MCP Demo'),
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
  String _statusMessage = 'Not connected';
  List<ResourceInfo> _resources = [];
  List<ToolInfo> _tools = [];
  List<PromptInfo> _prompts = [];

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
        name: 'Flutter MCP Demo',
        version: '1.0.0',
        capabilities: const ClientCapabilities(
          sampling: SamplingCapabilityConfig(sample: true),
        ),
      );

      final transport = McpWebSocketClientTransport(Uri.parse(serverUrl));
      await _client!.connect(transport);

      setState(() {
        _isConnected = true;
        _statusMessage = 'Connected to $serverUrl';
      });

      await _refreshData();
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

    setState(() {
      _statusMessage = 'Disconnecting...';
    });

    try {
      await _client!.disconnect();

      setState(() {
        _isConnected = false;
        _statusMessage = 'Disconnected';
        _resources = [];
        _tools = [];
        _prompts = [];
      });

      _client = null;
    } catch (e) {
      setState(() {
        _statusMessage = 'Disconnection failed: $e';
      });
    }
  }

  Future<void> _refreshData() async {
    if (!_isConnected || _client == null) {
      return;
    }

    setState(() {
      _statusMessage = 'Loading data...';
    });

    try {
      // Get resources
      if (_client!.serverCapabilities?.resources?.list == true) {
        final resources = await _client!.listResources();
        setState(() {
          _resources = resources;
        });
      }

      // Get tools
      if (_client!.serverCapabilities?.tools?.list == true) {
        final tools = await _client!.listTools();
        setState(() {
          _tools = tools;
        });
      }

      // Get prompts
      if (_client!.serverCapabilities?.prompts?.list == true) {
        final prompts = await _client!.listPrompts();
        setState(() {
          _prompts = prompts;
        });
      }

      setState(() {
        _statusMessage = 'Data loaded';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to load data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(_isConnected ? Icons.link_off : Icons.link),
            onPressed: _isConnected ? _disconnect : _connect,
            tooltip: _isConnected ? 'Disconnect' : 'Connect',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isConnected ? _refreshData : null,
            tooltip: 'Refresh data',
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
                        _buildResourcesList(),
                        _buildToolsList(),
                        _buildPromptsList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesList() {
    if (!_isConnected) {
      return const Center(child: Text('Not connected'));
    }

    if (_resources.isEmpty) {
      return const Center(child: Text('No resources available'));
    }

    return ListView.builder(
      itemCount: _resources.length,
      itemBuilder: (context, index) {
        final resource = _resources[index];
        return ListTile(
          title: Text(resource.name),
          subtitle: Text(resource.uriTemplate),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () => _showResourceDetails(resource),
        );
      },
    );
  }

  Widget _buildToolsList() {
    if (!_isConnected) {
      return const Center(child: Text('Not connected'));
    }

    if (_tools.isEmpty) {
      return const Center(child: Text('No tools available'));
    }

    return ListView.builder(
      itemCount: _tools.length,
      itemBuilder: (context, index) {
        final tool = _tools[index];
        return ListTile(
          title: Text(tool.name),
          subtitle: Text(tool.description ?? 'No description'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () => _showToolDetails(tool),
        );
      },
    );
  }

  Widget _buildPromptsList() {
    if (!_isConnected) {
      return const Center(child: Text('Not connected'));
    }

    if (_prompts.isEmpty) {
      return const Center(child: Text('No prompts available'));
    }

    return ListView.builder(
      itemCount: _prompts.length,
      itemBuilder: (context, index) {
        final prompt = _prompts[index];
        return ListTile(
          title: Text(prompt.name),
          subtitle: Text(prompt.description ?? 'No description'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () => _showPromptDetails(prompt),
        );
      },
    );
  }

  void _showResourceDetails(ResourceInfo resource) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(resource.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('URI Template: ${resource.uriTemplate}'),
                if (resource.description != null)
                  Text('Description: ${resource.description}'),
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
  }

  void _showToolDetails(ToolInfo tool) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(tool.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (tool.description != null)
                  Text('Description: ${tool.description}'),
                const SizedBox(height: 8),
                const Text('Arguments:'),
                ...tool.arguments.map(
                  (arg) => Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      '${arg.name}${arg.required ? ' (required)' : ''}: '
                      '${arg.description ?? 'No description'}',
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showCallToolDialog(tool);
                },
                child: const Text('Call Tool'),
              ),
            ],
          ),
    );
  }

  void _showPromptDetails(PromptInfo prompt) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(prompt.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (prompt.description != null)
                  Text('Description: ${prompt.description}'),
                const SizedBox(height: 8),
                const Text('Arguments:'),
                ...prompt.arguments.map(
                  (arg) => Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      '${arg.name}${arg.required ? ' (required)' : ''}: '
                      '${arg.description ?? 'No description'}',
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showGetPromptDialog(prompt);
                },
                child: const Text('Get Prompt'),
              ),
            ],
          ),
    );
  }

  void _showCallToolDialog(ToolInfo tool) {
    final argumentControllers = <String, TextEditingController>{};
    for (final arg in tool.arguments) {
      argumentControllers[arg.name] = TextEditingController();
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Call Tool: ${tool.name}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...tool.arguments.map(
                    (arg) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: TextField(
                        controller: argumentControllers[arg.name],
                        decoration: InputDecoration(
                          labelText: arg.name,
                          hintText: arg.description,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();

                  final arguments = <String, dynamic>{};
                  for (final entry in argumentControllers.entries) {
                    arguments[entry.key] = entry.value.text;
                  }

                  try {
                    setState(() {
                      _statusMessage = 'Calling tool ${tool.name}...';
                    });

                    final result = await _client!.callTool(
                      tool.name,
                      arguments,
                    );

                    setState(() {
                      _statusMessage = 'Tool ${tool.name} called successfully';
                    });

                    _showToolResultDialog(tool.name, result);
                  } catch (e) {
                    setState(() {
                      _statusMessage = 'Failed to call tool: $e';
                    });
                  }
                },
                child: const Text('Call'),
              ),
            ],
          ),
    );
  }

  void _showGetPromptDialog(PromptInfo prompt) {
    final argumentControllers = <String, TextEditingController>{};
    for (final arg in prompt.arguments) {
      argumentControllers[arg.name] = TextEditingController();
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Get Prompt: ${prompt.name}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...prompt.arguments.map(
                    (arg) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: TextField(
                        controller: argumentControllers[arg.name],
                        decoration: InputDecoration(
                          labelText: arg.name,
                          hintText: arg.description,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();

                  final arguments = <String, dynamic>{};
                  for (final entry in argumentControllers.entries) {
                    arguments[entry.key] = entry.value.text;
                  }

                  try {
                    setState(() {
                      _statusMessage = 'Getting prompt ${prompt.name}...';
                    });

                    final result = await _client!.getPrompt(
                      prompt.name,
                      arguments,
                    );

                    setState(() {
                      _statusMessage =
                          'Prompt ${prompt.name} retrieved successfully';
                    });

                    _showPromptResultDialog(prompt.name, result);
                  } catch (e) {
                    setState(() {
                      _statusMessage = 'Failed to get prompt: $e';
                    });
                  }
                },
                child: const Text('Get'),
              ),
            ],
          ),
    );
  }

  void _showToolResultDialog(String toolName, CallToolResult result) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Tool Result: $toolName'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (result.isError == true)
                    const Text(
                      'Error:',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ...result.content.map(
                    (content) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Type: ${content.type.toString().split('.').last}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(content.text),
                        ],
                      ),
                    ),
                  ),
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
  }

  void _showPromptResultDialog(String promptName, GetPromptResult result) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Prompt Result: $promptName'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (result.description != null)
                    Text('Description: ${result.description}'),
                  const SizedBox(height: 8),
                  const Text(
                    'Messages:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...result.messages.map(
                    (message) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Role: ${message.role.toString().split('.').last}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(message.content.text),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();

                  // Convert the prompt to JSON for easy copying
                  final json = jsonEncode({
                    'description': result.description,
                    'messages':
                        result.messages
                            .map(
                              (m) => {
                                'role': m.role.toString().split('.').last,
                                'content': {
                                  'type': m.content.type,
                                  'text': m.content.text,
                                },
                              },
                            )
                            .toList(),
                  });

                  // Show the JSON
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Prompt JSON'),
                          content: SingleChildScrollView(child: Text(json)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                  );
                },
                child: const Text('Show JSON'),
              ),
            ],
          ),
    );
  }
}
