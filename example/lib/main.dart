// Example of using the Flutter MCP Client Library
import 'dart:convert';
import 'dart:io';

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
  Process? _serverProcess;

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
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _startServer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Start Server'),
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
              DefaultTabController(
                length: 3,
                child: Expanded(
                  child: Column(
                    children: [
                      TabBar(
                        labelColor: Theme.of(context).primaryColor,
                        tabs: const [
                          Tab(text: 'Resources'),
                          Tab(text: 'Tools'),
                          Tab(text: 'Prompts'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Resources Tab
                            ListView.builder(
                              itemCount: _resources.length,
                              itemBuilder: (context, index) {
                                final resource = _resources[index];
                                return ListTile(
                                  title: Text(resource.name),
                                  subtitle: Text(resource.description ??
                                      'No description available'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.visibility),
                                    onPressed: () => _readResource(resource),
                                  ),
                                );
                              },
                            ),

                            // Tools Tab
                            ListView.builder(
                              itemCount: _tools.length,
                              itemBuilder: (context, index) {
                                final tool = _tools[index];
                                return ListTile(
                                  title: Text(tool.name),
                                  subtitle: Text(tool.description ??
                                      'No description available'),
                                );
                              },
                            ),

                            // Prompts Tab
                            ListView.builder(
                              itemCount: _prompts.length,
                              itemBuilder: (context, index) {
                                final prompt = _prompts[index];
                                return ListTile(
                                  title: Text(prompt.name),
                                  subtitle: Text(prompt.description ??
                                      'No description available'),
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

      // Show a dialog with instructions on how to start the server
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Connection Failed'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Could not connect to the MCP server. Make sure the server is running.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text('To start the server, run:'),
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.grey[200],
                  child: const Text(
                    'dart run example/mcp_server_example.dart',
                    style: TextStyle(fontFamily: 'monospace'),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'The server will start on localhost:8080/mcp by default.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
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

  Future<void> _startServer() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Starting server...';
    });

    try {
      // Get the current directory
      final currentDir = Directory.current.path;

      // Start the server process
      _serverProcess = await Process.start(
        'dart',
        ['run', '$currentDir/example/mcp_server_example.dart'],
      );

      // Listen for server output
      _serverProcess!.stdout.transform(const Utf8Decoder()).listen((data) {
        debugPrint('Server output: $data');
        if (data.contains('Server listening')) {
          setState(() {
            _statusMessage = 'Server started on localhost:8080';
          });
        }
      });

      // Listen for server errors
      _serverProcess!.stderr.transform(const Utf8Decoder()).listen((data) {
        debugPrint('Server error: $data');
        setState(() {
          _statusMessage = 'Server error: $data';
        });
      });

      // Wait a bit for the server to start
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _statusMessage = 'Server started. You can now connect.';
      });

      // Show a success dialog
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Server Started'),
          content: const Text(
            'The MCP server has been started on localhost:8080.\n\n'
            'You can now click "Connect" to connect to it.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _connect(); // Auto-connect
              },
              child: const Text('Connect Now'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to start server: $e';
      });

      // Show an error dialog
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Server Start Failed'),
          content: Text('Failed to start the MCP server: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _serverProcess?.kill();
    super.dispose();
  }
}
