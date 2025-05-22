# Flutter MCP Client Library

[![pub package](https://img.shields.io/pub/v/flutter_mcp_client_lib.svg)](https://pub.dev/packages/flutter_mcp_client_lib)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A Flutter implementation of the [Model Context Protocol (MCP)](https://github.com/anthropics/model-context-protocol-spec) for integrating with AI tools like Windsurf, Cursor, and Claude.

## Table of Contents

- [Latest Updates](#latest-updates)
- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Getting Started](#getting-started)
- [Architecture](#architecture)
- [Examples](#examples)
- [Documentation](#documentation)
- [Platform Support](#platform-support)
- [Contributing](#contributing)
- [License](#license)
- [Troubleshooting Guide](#troubleshooting-guide)

## Latest Updates

- Enhanced ClientCapabilities with resources, tools, and prompts fields
- Improved error handling and timeout management
- Added comprehensive documentation and examples

## Overview

The Model Context Protocol (MCP) is an open protocol that enables seamless integration between LLM applications and external data sources and tools. This Flutter package implements the MCP specification, making it easy to:

- Connect to MCP servers using WebSocket or HTTP
- List and read resources (files, documents, etc.)
- List and call tools (functions, commands, etc.)
- List and retrieve prompts (templates for LLM interactions)
- Render MCP responses in Flutter UI



## Features

- **Full MCP v2025-03-26 Support**: Implements the complete Model Context Protocol version 2025-03-26.
- **WebSocket & HTTP Support**: Offers flexibility with support for both WebSocket and HTTP transport layers.
- **Type-Safe API**: Features strongly typed models and interfaces for robust MCP component interaction.
- **Ready-to-Use UI Widgets**: Includes pre-built Flutter widgets for easy display of MCP responses.
- **Robust Error Handling**: Provides comprehensive error handling and recovery mechanisms.
- **Extensible Design**: Built with an extensible architecture, allowing for easy custom functional additions.
- **Cross-Platform Compatibility**: Ensures wide reach, working seamlessly on iOS, Android, web, and desktop platforms.
- **Comprehensive Documentation**: Comes with thorough documentation and illustrative examples.

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

## Getting Started

### MCP Client Setup and Connection

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
    print('Connected to MCP server');
    print('Server capabilities: ${client.serverCapabilities}');

    // After a successful connection, the client automatically initializes
    // and negotiates capabilities with the server.
    // This handshake ensures both client and server understand each other's supported features.

    // --- Working with Resources ---

    // List available resources that the server provides.
    // Resources can be files, database entries, or any other data source.
    final resources = await client.listResources();
    print('Resources:');
    for (final resource in resources) {
      print('- ${resource.name}: ${resource.description}');
      print('  URI Template: ${resource.uriTemplate}');
    }

    // Read a resource
    // For template URIs, replace parameters with actual values.
    // For example, if a resource URI is 'user/{userId}/profile',
    // you would replace {userId} with an actual ID like 'user/123/profile'.
    final exampleResourceUri = 'greeting://John'; // Replace with a valid URI from your server
    try {
      final contents = await client.readResource(exampleResourceUri);
      print('Resource contents for $exampleResourceUri:');
      for (final content in contents) {
        // Content can be text, image, or other data types.
        print('- URI: ${content.uri}, Type: ${content.type}, Text: ${content.text ?? "N/A"}');
      }
    } catch (e) {
      print('Error reading resource "$exampleResourceUri": $e');
    }

    // --- Working with Tools ---

    // List available tools. Tools are functions or commands the server can execute.
    final tools = await client.listTools();
    print('Tools:');
    for (final tool in tools) {
      print('- ${tool.name}: ${tool.description}');
      print('  Arguments:');
      for (final arg in tool.arguments) {
        print('    - ${arg.name}: ${arg.description} (required: ${arg.required})');
      }
    }

    // Call a specific tool with arguments.
    // Replace 'calculator.add' with an actual tool name from your server
    // and provide the necessary arguments as a Map<String, dynamic>.
    final toolName = 'add'; // Example: 'calculator.add'
    final toolArguments = {'a': '5', 'b': '7'}; // Example arguments

    try {
      final toolResult = await client.callTool(toolName, toolArguments);
      print('Tool "$toolName" result:');
      for (final content in toolResult.content) {
        // The result's content can be of various types (text, image, etc.).
        // Here we assume it's text-based for simplicity.
        print('- Type: ${content.type}, Text: ${content.text ?? "N/A"}'); // Example: prints 'text: 12'
      }
    } catch (e) {
      print('Error calling tool "$toolName": $e');
    }

    // --- Working with Prompts ---

    // List available prompts. Prompts are templates for LLM interactions.
    final prompts = await client.listPrompts();
    print('Prompts:');
    for (final prompt in prompts) {
      print('- ${prompt.name}: ${prompt.description}');
      print('  Arguments:');
      for (final arg in prompt.arguments) {
        print('    - ${arg.name}: ${arg.description} (required: ${arg.required})');
      }
    }

    // Get a specific prompt by name, providing any necessary arguments.
    // Replace 'mood_reflector' with an actual prompt name from your server
    // and provide the appropriate arguments as a Map<String, dynamic>.
    final promptName = 'greeting'; // Example: 'mood_reflector'
    final promptArguments = {'name': 'John'}; // Example arguments

    try {
      final promptResult = await client.getPrompt(promptName, promptArguments);
      print('Prompt "$promptName" result:');
      // Prompts typically result in a sequence of messages (e.g., system, user, assistant).
      print('Description: ${promptResult.description ?? "No description"}');
      print('Messages:');
      for (final message in promptResult.messages) {
        print('- Role: ${message.role}, Content: ${message.content.text}');
      }
    } catch (e) {
      print('Error getting prompt "$promptName": $e');
    }

  } catch (e, stackTrace) {
    // General error handling for the main try block
    print('An error occurred during MCP operations: $e');
    print('Stack trace: $stackTrace');
  } finally {
    // Always ensure to disconnect the client when it's no longer needed
    // to free up resources on both client and server.
    print('Disconnecting from the server...');
    await client.disconnect();
    print('Disconnected.');
  }
}
```

### Rendering MCP Responses in UI

This example demonstrates how to render MCP (Model Context Protocol) responses within a Flutter application. For a comprehensive, runnable Flutter application example, please refer to the [Flutter App Example](doc/flutter_app_example.md) document.

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

The Flutter MCP client library is structured into the following core components:

- **Client**: Manages all communication with MCP servers, acting as the primary interface for interactions.
- **Transports**: Implements the underlying transport protocols (WebSocket and HTTP) for message exchange.
- **Models**: Defines the Dart classes representing MCP messages and data structures, ensuring type safety.
- **UI**: Contains pre-built Flutter widgets designed to render MCP responses effectively within your application.
- **Utils**: Provides a collection of utility functions and helper classes to support various operations.



## Examples

The package includes several examples:

- **Basic Client**: Demonstrates a simple connection to an MCP server.
- **Resource Browser**: Shows how to browse and view available resources.
- **Tool Explorer**: Illustrates discovering and executing tools.
- **Prompt Manager**: Provides an example of working with prompts.
- **UI Components**: Showcases how to use the included widgets to render MCP responses in a Flutter UI.

To run the examples:

```bash
cd example
flutter run -t mcp_client_example.dart  # For client example
flutter run -t mcp_ui_example.dart      # For UI example
```

## Documentation

- [API Reference](https://pub.dev/documentation/flutter_mcp_client_lib/latest/)
- [Configuration Reference](doc/configuration_reference.md)
- [Flutter App Example](doc/flutter_app_example.md)

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

For detailed API documentation, refer to the [API Reference](https://pub.dev/documentation/flutter_mcp_client_lib/latest/).
For configuration options and details, see the [Configuration Reference](doc/configuration_reference.md).
For a runnable Flutter application example, see the [Flutter App Example](doc/flutter_app_example.md).

## License

This project is licensed under the MIT License - see the LICENSE file for details.
