# Tool Development Tutorial

This tutorial explains how to work with tools in the Model Context Protocol (MCP) using the Flutter MCP package.

## What are MCP Tools?

Tools in MCP are functions that can be called by clients to perform specific tasks. They can:

- Perform calculations
- Access external data
- Execute commands
- Interact with APIs
- Process information

Tools have names, descriptions, arguments, and return results.

## Client-Side: Using Tools

### Listing Available Tools

To list the tools available on an MCP server:

```dart
import 'package:flutter_mcp/flutter_mcp.dart';

Future<void> listTools(McpClient client) async {
  try {
    final tools = await client.listTools();
    
    print('Available tools:');
    for (final tool in tools) {
      print('- ${tool.name}: ${tool.description}');
      
      print('  Arguments:');
      for (final arg in tool.arguments) {
        print('    - ${arg.name}: ${arg.description}');
        print('      Required: ${arg.required}');
        print('      Type: ${arg.type}');
      }
    }
  } catch (e) {
    print('Failed to list tools: $e');
  }
}
```

The `listTools()` method returns a list of `ToolInfo` objects, each containing:
- `name`: The name of the tool
- `description`: A description of the tool
- `arguments`: A list of `ToolArgument` objects describing the tool's arguments

### Calling Tools

To call a tool on an MCP server:

```dart
Future<void> callTool(McpClient client, String name, Map<String, dynamic> args) async {
  try {
    final result = await client.callTool(name, args);
    
    print('Tool result:');
    for (final content in result.content) {
      print('- Type: ${content.type}');
      print('  Text: ${content.text}');
    }
    
    if (result.isError == true) {
      print('Tool execution resulted in an error');
    }
  } catch (e) {
    print('Failed to call tool: $e');
  }
}
```

The `callTool()` method returns a `CallToolResult` object containing:
- `content`: A list of `ContentItem` objects with the tool's output
- `isError`: A boolean indicating whether the tool execution resulted in an error

### Example: Calling Specific Tools

Here's an example of calling specific tools:

```dart
// Call the 'add' tool
Future<void> addNumbers(McpClient client, int a, int b) async {
  final result = await client.callTool('add', {
    'a': a.toString(),
    'b': b.toString(),
  });
  
  final sum = result.content.first.text;
  print('Sum: $sum');
}

// Call the 'echo' tool
Future<void> echoMessage(McpClient client, String message) async {
  final result = await client.callTool('echo', {
    'message': message,
  });
  
  final echo = result.content.first.text;
  print('Echo: $echo');
}
```

## Server-Side: Implementing Tools

### Defining Tool Providers

When implementing an MCP server, you need to define tool providers that can handle tool requests:

```dart
class AddToolProvider {
  ToolInfo getToolInfo() {
    return ToolInfo(
      name: 'add',
      description: 'Add two numbers',
      arguments: [
        ToolArgument(
          name: 'a',
          description: 'First number',
          required: true,
          type: 'string',
        ),
        ToolArgument(
          name: 'b',
          description: 'Second number',
          required: true,
          type: 'string',
        ),
      ],
    );
  }
  
  CallToolResult callTool(Map<String, dynamic> args) {
    // Validate arguments
    if (!args.containsKey('a') || !args.containsKey('b')) {
      return CallToolResult(
        content: [
          ContentItem(
            type: ContentType.text,
            text: 'Missing required arguments',
          ),
        ],
        isError: true,
      );
    }
    
    // Parse arguments
    int? a, b;
    try {
      a = int.parse(args['a'] as String);
      b = int.parse(args['b'] as String);
    } catch (e) {
      return CallToolResult(
        content: [
          ContentItem(
            type: ContentType.text,
            text: 'Invalid arguments: $e',
          ),
        ],
        isError: true,
      );
    }
    
    // Perform calculation
    final sum = a + b;
    
    // Return result
    return CallToolResult(
      content: [
        ContentItem(
          type: ContentType.text,
          text: sum.toString(),
        ),
      ],
    );
  }
}
```

### Registering Tool Providers

In your server implementation, register the tool providers:

```dart
class MyMcpServer {
  final List<dynamic> _toolProviders = [];
  
  void registerToolProvider(dynamic provider) {
    _toolProviders.add(provider);
  }
  
  List<ToolInfo> listTools() {
    return _toolProviders
        .map((provider) => provider.getToolInfo())
        .toList();
  }
  
  CallToolResult callTool(String name, Map<String, dynamic> args) {
    // Find a provider that can handle this tool
    for (final provider in _toolProviders) {
      if (provider.getToolInfo().name == name) {
        return provider.callTool(args);
      }
    }
    
    throw McpError(
      code: McpErrorCodes.toolNotFound,
      message: 'Tool not found: $name',
    );
  }
  
  // Other server methods...
}
```

### Handling Tool Requests

In your server's request handler, handle tool-related requests:

```dart
void handleRequest(McpRequest request) {
  switch (request.method) {
    case 'listTools':
      final tools = listTools();
      sendResponse(McpResponse(
        id: request.id,
        result: {'tools': tools.map((t) => t.toJson()).toList()},
      ));
      break;
      
    case 'callTool':
      final name = request.params['name'] as String;
      final args = request.params['arguments'] as Map<String, dynamic>;
      
      try {
        final result = callTool(name, args);
        sendResponse(McpResponse(
          id: request.id,
          result: result.toJson(),
        ));
      } catch (e) {
        sendErrorResponse(request.id, e);
      }
      break;
      
    // Handle other methods...
  }
}
```

## Best Practices for Tool Implementation

### Argument Validation

Always validate tool arguments before using them:

```dart
void validateArguments(Map<String, dynamic> args, List<ToolArgument> expectedArgs) {
  // Check for required arguments
  for (final arg in expectedArgs) {
    if (arg.required && !args.containsKey(arg.name)) {
      throw ArgumentError('Missing required argument: ${arg.name}');
    }
  }
  
  // Check for unexpected arguments
  for (final argName in args.keys) {
    if (!expectedArgs.any((arg) => arg.name == argName)) {
      throw ArgumentError('Unexpected argument: $argName');
    }
  }
}
```

### Type Conversion

Convert string arguments to the appropriate types:

```dart
int parseIntArg(Map<String, dynamic> args, String name) {
  final value = args[name];
  if (value is String) {
    try {
      return int.parse(value);
    } catch (e) {
      throw ArgumentError('Invalid integer for $name: $value');
    }
  } else if (value is int) {
    return value;
  } else {
    throw ArgumentError('Expected string or int for $name, got ${value.runtimeType}');
  }
}

double parseDoubleArg(Map<String, dynamic> args, String name) {
  final value = args[name];
  if (value is String) {
    try {
      return double.parse(value);
    } catch (e) {
      throw ArgumentError('Invalid double for $name: $value');
    }
  } else if (value is num) {
    return value.toDouble();
  } else {
    throw ArgumentError('Expected string or num for $name, got ${value.runtimeType}');
  }
}

bool parseBoolArg(Map<String, dynamic> args, String name) {
  final value = args[name];
  if (value is String) {
    if (value.toLowerCase() == 'true') return true;
    if (value.toLowerCase() == 'false') return false;
    throw ArgumentError('Invalid boolean for $name: $value');
  } else if (value is bool) {
    return value;
  } else {
    throw ArgumentError('Expected string or bool for $name, got ${value.runtimeType}');
  }
}
```

### Error Handling

Return appropriate error responses for tool execution failures:

```dart
CallToolResult executeToolSafely(Function toolFunction, Map<String, dynamic> args) {
  try {
    return toolFunction(args);
  } catch (e) {
    return CallToolResult(
      content: [
        ContentItem(
          type: ContentType.text,
          text: 'Tool execution failed: $e',
        ),
      ],
      isError: true,
    );
  }
}
```

### Rich Content Results

Tools can return rich content using different content types:

```dart
CallToolResult getWeatherResult(String location) {
  // ... fetch weather data ...
  
  return CallToolResult(
    content: [
      ContentItem(
        type: ContentType.text,
        text: 'Weather for $location: 72°F, Sunny',
      ),
      ContentItem(
        type: ContentType.markdown,
        text: '## Weather for $location\n\n- Temperature: 72°F\n- Conditions: Sunny\n- Humidity: 45%',
      ),
      ContentItem(
        type: ContentType.json,
        text: '{"location":"$location","temperature":72,"conditions":"Sunny","humidity":45}',
      ),
    ],
  );
}
```

## Conclusion

In this tutorial, you learned how to:
- List and call tools as an MCP client
- Implement tool providers in an MCP server
- Validate and convert tool arguments
- Handle tool-related errors
- Return rich content from tools

Tools are a powerful way to extend the capabilities of language models through the MCP protocol.
