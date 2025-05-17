# Flutter MCP Client Library

[![pub package](https://img.shields.io/pub/v/flutter_mcp_client_lib.svg)](https://pub.dev/packages/flutter_mcp_client_lib)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A Flutter implementation of the [Model Context Protocol (MCP)](https://github.com/anthropics/model-context-protocol-spec) for integrating with AI tools like Windsurf, Cursor, and Claude.

## Overview

The Model Context Protocol (MCP) is an open protocol that enables seamless integration between LLM applications and external data sources and tools. This Flutter package implements the MCP specification, making it easy to:

- Connect to MCP servers using WebSocket or HTTP
- List and read resources (files, documents, etc.)
- List and call tools (functions, commands, etc.)
- List and retrieve prompts (templates for LLM interactions)
- Render MCP responses in Flutter UI



## Features

- **Complete MCP Implementation**: Full implementation of the MCP protocol version 2025-03-26
- **Multiple Transport Layers**: Support for WebSocket and HTTP connections
- **Type-Safe API**: Strongly typed models and interfaces for MCP components
- **UI Components**: Ready-to-use widgets for displaying MCP responses
- **Error Handling**: Comprehensive error handling and recovery strategies
- **Extensible Architecture**: Easy to extend with custom functionality
- **Cross-Platform**: Works on iOS, Android, web, and desktop platforms
- **Well-Documented**: Comprehensive documentation and examples

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_mcp_client_lib: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

### Connecting to an MCP Server

```dart
import 'package:flutter_mcp_client_lib/flutter_mcp_client_lib.dart';

Future<void> connectToServer() async {
  // Create a client
  final client = McpClient(
    name: 'My App',
    version: '1.0.0',
    capabilities: const ClientCapabilities(
      sampling: SamplingCapabilityConfig(sample: true),
      resources: ResourceCapabilityConfig(list: true, read: true),
      tools: ToolCapabilityConfig(list: true, call: true),
      prompts: PromptCapabilityConfig(list: true, get: true),
    ),
  );

  // Connect to a server using WebSocket
  final transport = McpWebSocketClientTransport(
    Uri.parse('ws://localhost:8080/mcp'),
  );

  try {
    await client.connect(transport);
    print('Connected to MCP server');
    print('Server capabilities: ${client.serverCapabilities}');
  } catch (e) {
    print('Failed to connect: $e');
  }
}
```

### Working with Resources

```dart
// List available resources
final resources = await client.listResources();
for (final resource in resources) {
  print('Resource: ${resource.name} (${resource.uriTemplate})');
}

// Read a resource
final contents = await client.readResource('file://path/to/file.txt');
for (final content in contents) {
  print('Content: ${content.text}');
}
```

### Working with Tools

```dart
// List available tools
final tools = await client.listTools();
for (final tool in tools) {
  print('Tool: ${tool.name} (${tool.description})');
}

// Call a tool
final result = await client.callTool('calculator.add', {
  'a': 5,
  'b': 7,
});
print('Result: ${result.content.first.text}'); // Output: 12
```

### Working with Prompts

```dart
// List available prompts
final prompts = await client.listPrompts();
for (final prompt in prompts) {
  print('Prompt: ${prompt.name} (${prompt.description})');
}

// Get a prompt
final result = await client.getPrompt('greeting', {
  'name': 'John',
});
for (final message in result.messages) {
  print('${message.role}: ${message.content.text}');
}
```

### Rendering MCP Responses in UI

```dart
import 'package:flutter/material.dart';
import 'package:flutter_mcp_client_lib/flutter_mcp_client_lib.dart';

class McpResponseView extends StatelessWidget {
  final McpResponse response;

  const McpResponseView({Key? key, required this.response}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final theme = McpTheme.fromTheme(context);
        final renderer = McpResponseRenderer(theme: theme);
        return renderer.render(context, response);
      },
    );
  }
}
```

## Architecture

The Flutter MCP package is organized into several components:

- **Client**: Handles communication with MCP servers
- **Transports**: Implements different transport protocols (WebSocket, HTTP)
- **Models**: Defines data structures for MCP messages and objects
- **UI**: Provides widgets for rendering MCP responses
- **Utils**: Offers utility functions and helpers



## Examples

The package includes several examples:

- **Basic Client**: Simple example of connecting to an MCP server
- **Resource Browser**: Example of browsing and viewing resources
- **Tool Explorer**: Example of discovering and calling tools
- **Prompt Manager**: Example of working with prompts
- **UI Components**: Example of rendering MCP responses in UI

To run the examples:

```bash
cd example
flutter run -t mcp_client_example.dart  # For client example
flutter run -t mcp_ui_example.dart      # For UI example
```

## Documentation

- [API Reference](https://pub.dev/documentation/flutter_mcp_client_lib/latest/)

For more information about the Model Context Protocol, see:

- [Model Context Protocol Specification](https://github.com/anthropics/model-context-protocol-spec)
- [MCP Protocol Version 2025-03-26](https://github.com/anthropics/model-context-protocol-spec/blob/main/spec/2025-03-26.md)

## Platform Support

| Platform | Support |
|----------|---------|
| Android  | ✅      |
| iOS      | ✅      |
| Web      | ✅      |
| Windows  | ✅      |
| macOS    | ✅      |
| Linux    | ✅      |

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.



## Usage

### MCP Client

```dart
import 'package:flutter_mcp_client_lib/flutter_mcp_client_lib.dart';
import 'package:logging/logging.dart';

void main() async {
  // Set up logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  // Create a client
  final client = McpClient(
    name: 'Example Client',
    version: '1.0.0',
    capabilities: const ClientCapabilities(
      sampling: SamplingCapabilityConfig(sample: true),
      resources: ResourceCapabilityConfig(list: true, read: true),
      tools: ToolCapabilityConfig(list: true, call: true),
      prompts: PromptCapabilityConfig(list: true, get: true),
    ),
  );

  try {
    // Connect to a server using WebSocket
    final transport = McpWebSocketClientTransport(
      Uri.parse('ws://localhost:8080/mcp'),
    );
    await client.connect(transport);

    // After connection, the client will automatically initialize
    // and negotiate capabilities with the server

    // List resources
    final resources = await client.listResources();
    print('Resources:');
    for (final resource in resources) {
      print('- ${resource.name}: ${resource.description}');
      print('  URI Template: ${resource.uriTemplate}');
    }

    // Read a resource
    // For template URIs, replace parameters with actual values
    final greetingUri = 'greeting://John';
    final contents = await client.readResource(greetingUri);
    print('Resource contents:');
    for (final content in contents) {
      print('- ${content.uri}: ${content.text}');
    }

    // List tools
    final tools = await client.listTools();
    print('Tools:');
    for (final tool in tools) {
      print('- ${tool.name}: ${tool.description}');
      print('  Arguments:');
      for (final arg in tool.arguments) {
        print('    - ${arg.name}: ${arg.description} (required: ${arg.required})');
      }
    }

    // Call a tool
    final addResult = await client.callTool(
      'add',
      {'a': '5', 'b': '7'},
    );
    print('Add tool result:');
    for (final content in addResult.content) {
      print('- ${content.type}: ${content.text}');
    }

    // Call another tool
    final echoResult = await client.callTool(
      'echo',
      {'message': 'Hello from MCP client!'},
    );
    print('Echo tool result:');
    for (final content in echoResult.content) {
      print('- ${content.type}: ${content.text}');
    }

    // List prompts
    final prompts = await client.listPrompts();
    print('Prompts:');
    for (final prompt in prompts) {
      print('- ${prompt.name}: ${prompt.description}');
      print('  Arguments:');
      for (final arg in prompt.arguments) {
        print('    - ${arg.name}: ${arg.description} (required: ${arg.required})');
      }
    }

    // Get a prompt
    final promptResult = await client.getPrompt(
      'greeting',
      {'name': 'John'},
    );
    print('Greeting prompt:');
    print('Description: ${promptResult.description}');
    print('Messages:');
    for (final message in promptResult.messages) {
      print('- ${message.role}: ${message.content.text}');
    }
  } catch (e, stackTrace) {
    print('Error: $e');
    print('Stack trace: $stackTrace');
  } finally {
    // Disconnect from the server
    await client.disconnect();
  }
}
```

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

## Configuration Reference

### McpClient Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| name | String | required | The name of the client |
| version | String | required | The version of the client |
| capabilities | ClientCapabilities | required | The capabilities of the client |
| timeout | Duration | 30 seconds | The timeout for requests |

### ClientCapabilities Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| sampling | SamplingCapabilityConfig | null | Configuration for sampling capabilities |
| resources | ResourceCapabilityConfig | null | Configuration for resource capabilities |
| tools | ToolCapabilityConfig | null | Configuration for tool capabilities |
| prompts | PromptCapabilityConfig | null | Configuration for prompt capabilities |

### SamplingCapabilityConfig

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| sample | bool | false | Whether the client can handle sample requests |

### ResourceCapabilityConfig

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| list | bool | false | Whether the client can list resources |
| read | bool | false | Whether the client can read resources |

### ToolCapabilityConfig

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| list | bool | false | Whether the client can list tools |
| call | bool | false | Whether the client can call tools |

### PromptCapabilityConfig

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| list | bool | false | Whether the client can list prompts |
| get | bool | false | Whether the client can get prompts |

## Troubleshooting Guide

### Connection Issues

- **WebSocket connection failed**:
  - Check that the server is running and the URI is correct
  - Verify that the port is not blocked by a firewall
  - Ensure the server is configured to accept WebSocket connections
  - Check for SSL/TLS certificate issues if using wss://

- **Connection timeout**:
  - Increase the timeout value in the client configuration
  - Check network latency between client and server
  - Verify server is not overloaded

- **Connection refused**:
  - Check firewall settings and server port configuration
  - Verify the server is running and listening on the specified port
  - Check if the server has reached its connection limit

### Protocol Errors

- **Invalid request**:
  - Check that the request parameters are correct
  - Verify that the request format follows the JSON-RPC 2.0 specification
  - Ensure all required fields are provided

- **Method not found**:
  - Verify that the server supports the requested method
  - Check capability negotiation to ensure the method is supported
  - Verify method name spelling and case sensitivity

- **Invalid params**:
  - Ensure that the parameters match the expected format
  - Check parameter types and values
  - Verify that all required parameters are provided

### Performance Optimization

- Use WebSocket transport for long-lived connections
- Implement caching for frequently used resources
- Use connection pooling for HTTP transport
- Batch requests when possible to reduce network overhead
- Implement retry logic with exponential backoff for transient errors

## Documentation

For more information about the Model Context Protocol, see:

- [Model Context Protocol Specification](https://github.com/anthropics/model-context-protocol-spec)
- [MCP Protocol Version 2025-03-26](https://github.com/anthropics/model-context-protocol-spec/blob/main/spec/2025-03-26.md)

For detailed API documentation, see the [API Reference](https://pub.dev/documentation/flutter_mcp/latest/).

## License

This project is licensed under the MIT License - see the LICENSE file for details.
