# Flutter MCP Client Library Example

This example demonstrates how to use the Flutter MCP Client Library to connect to an MCP server and interact with resources, tools, and prompts.

## Features

- Connect to an MCP server using WebSocket
- List and view resources
- List tools and prompts
- Display MCP responses in a Flutter UI

## Getting Started

1. Start an MCP server (you can use the `mcp_server_example.dart` in this directory)
2. Run this example app
3. Enter the server URL (default: `ws://localhost:8080/mcp`)
4. Click "Connect" to establish a connection
5. Browse resources, tools, and prompts

## Additional Examples

This directory also contains several other example files:

- `mcp_client_example.dart`: A simple command-line example of connecting to an MCP server
- `mcp_server_example.dart`: A simple MCP server implementation for testing
- `mcp_ui_example.dart`: An example of rendering MCP responses in a Flutter UI
- `test_client_capabilities.dart`: A test file for ClientCapabilities

## Running the Examples

To run this example:

```bash
cd example
flutter run -t lib/main.dart
```

To run the other examples:

```bash
cd example
flutter run -t mcp_client_example.dart
flutter run -t mcp_ui_example.dart
```

To run the server example:

```bash
cd example
dart run mcp_server_example.dart
```
