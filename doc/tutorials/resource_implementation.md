# Resource Implementation Tutorial

This tutorial explains how to work with resources in the Model Context Protocol (MCP) using the Flutter MCP package.

## What are MCP Resources?

Resources in MCP are contextual information that can be provided to language models. They can include:

- Code files
- Documentation
- User profiles
- System information
- Any other contextual data

Resources are identified by URIs and can be listed and read by clients.

## Client-Side: Using Resources

### Listing Available Resources

To list the resources available on an MCP server:

```dart
import 'package:flutter_mcp/flutter_mcp.dart';

Future<void> listResources(McpClient client) async {
  try {
    final resources = await client.listResources();
    
    print('Available resources:');
    for (final resource in resources) {
      print('- ${resource.name}: ${resource.uriTemplate}');
      print('  Description: ${resource.description}');
    }
  } catch (e) {
    print('Failed to list resources: $e');
  }
}
```

The `listResources()` method returns a list of `ResourceInfo` objects, each containing:
- `name`: The name of the resource
- `description`: A description of the resource
- `uriTemplate`: A template for the resource URI, which may contain parameters

### Reading Resources

To read a resource from an MCP server:

```dart
Future<void> readResource(McpClient client, String uri) async {
  try {
    final contents = await client.readResource(uri);
    
    print('Resource contents:');
    for (final content in contents) {
      print('- URI: ${content.uri}');
      print('  Type: ${content.type}');
      print('  Text: ${content.text}');
    }
  } catch (e) {
    print('Failed to read resource: $e');
  }
}
```

The `readResource()` method returns a list of `ResourceContent` objects, each containing:
- `uri`: The URI of the resource
- `type`: The content type (e.g., `ContentType.text`)
- `text`: The text content of the resource

### Handling URI Templates

Resource URIs may contain parameters that need to be replaced with actual values. For example, a resource with URI template `greeting://{name}` requires a `name` parameter:

```dart
Future<void> readGreetingResource(McpClient client, String name) async {
  // Replace the {name} parameter in the URI template
  final uri = 'greeting://$name';
  
  try {
    final contents = await client.readResource(uri);
    // Process contents...
  } catch (e) {
    print('Failed to read greeting resource: $e');
  }
}
```

## Server-Side: Implementing Resources

### Defining Resource Providers

When implementing an MCP server, you need to define resource providers that can handle resource requests:

```dart
class GreetingResourceProvider {
  ResourceInfo getResourceInfo() {
    return ResourceInfo(
      name: 'greeting',
      description: 'A greeting resource',
      uriTemplate: 'greeting://{name}',
    );
  }
  
  List<ResourceContent> getResourceContent(String uri) {
    // Extract the name from the URI
    final name = uri.replaceFirst('greeting://', '');
    
    return [
      ResourceContent(
        uri: uri,
        type: ContentType.text,
        text: 'Hello, $name!',
      ),
    ];
  }
}
```

### Registering Resource Providers

In your server implementation, register the resource providers:

```dart
class MyMcpServer {
  final List<dynamic> _resourceProviders = [];
  
  void registerResourceProvider(dynamic provider) {
    _resourceProviders.add(provider);
  }
  
  List<ResourceInfo> listResources() {
    return _resourceProviders
        .map((provider) => provider.getResourceInfo())
        .toList();
  }
  
  List<ResourceContent> readResource(String uri) {
    // Find a provider that can handle this URI
    for (final provider in _resourceProviders) {
      if (uri.startsWith(provider.getResourceInfo().uriTemplate.split('{')[0])) {
        return provider.getResourceContent(uri);
      }
    }
    
    throw McpError(
      code: McpErrorCodes.resourceNotFound,
      message: 'Resource not found: $uri',
    );
  }
  
  // Other server methods...
}
```

### Handling Resource Requests

In your server's request handler, handle resource-related requests:

```dart
void handleRequest(McpRequest request) {
  switch (request.method) {
    case 'listResources':
      final resources = listResources();
      sendResponse(McpResponse(
        id: request.id,
        result: {'resources': resources.map((r) => r.toJson()).toList()},
      ));
      break;
      
    case 'readResource':
      final uri = request.params['uri'] as String;
      try {
        final contents = readResource(uri);
        sendResponse(McpResponse(
          id: request.id,
          result: {'contents': contents.map((c) => c.toJson()).toList()},
        ));
      } catch (e) {
        sendErrorResponse(request.id, e);
      }
      break;
      
    // Handle other methods...
  }
}
```

## Best Practices for Resource Implementation

### URI Design

- Use a consistent URI scheme for your resources
- Include a prefix that identifies the resource type (e.g., `file://`, `user://`)
- Use parameters in URI templates to make resources flexible
- Document the URI format and parameters

### Content Types

The MCP specification defines several content types:

- `ContentType.text`: Plain text content
- `ContentType.markdown`: Markdown-formatted content
- `ContentType.html`: HTML-formatted content
- `ContentType.json`: JSON-formatted content
- `ContentType.code`: Code content (with optional language)

Choose the appropriate content type for your resources:

```dart
ResourceContent(
  uri: 'code://example.dart',
  type: ContentType.code,
  text: 'void main() { print("Hello, world!"); }',
  language: 'dart',
)
```

### Error Handling

Implement proper error handling for resource operations:

```dart
Future<List<ResourceContent>> readResourceSafely(McpClient client, String uri) async {
  try {
    return await client.readResource(uri);
  } on McpError catch (e) {
    if (e.code == McpErrorCodes.resourceNotFound) {
      print('Resource not found: $uri');
      return [];
    } else {
      rethrow;
    }
  } catch (e) {
    print('Unexpected error: $e');
    return [];
  }
}
```

## Conclusion

In this tutorial, you learned how to:
- List and read resources as an MCP client
- Handle URI templates and parameters
- Implement resource providers in an MCP server
- Design effective resource URIs
- Use appropriate content types
- Handle resource-related errors

Resources are a powerful way to provide contextual information to language models through the MCP protocol.
