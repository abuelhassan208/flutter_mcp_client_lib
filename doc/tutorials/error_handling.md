# Error Handling Tutorial

This tutorial explains how to handle errors in the Model Context Protocol (MCP) using the Flutter MCP package.

## Understanding MCP Errors

The MCP protocol defines a standard error format based on JSON-RPC 2.0. Errors include:

- Error code: A numeric code identifying the error type
- Error message: A human-readable description of the error
- Error data: Optional additional information about the error

The Flutter MCP package represents errors using the `McpError` class:

```dart
class McpError extends Error {
  final int code;
  final String message;
  final Map<String, dynamic>? data;
  
  McpError({
    required this.code,
    required this.message,
    this.data,
  });
  
  @override
  String toString() => 'McpError: $message (code: $code)';
}
```

## Error Taxonomy

### JSON-RPC Error Codes

The MCP protocol uses standard JSON-RPC 2.0 error codes:

| Code | Name | Description |
|------|------|-------------|
| -32700 | Parse error | Invalid JSON was received |
| -32600 | Invalid request | The JSON sent is not a valid Request object |
| -32601 | Method not found | The method does not exist / is not available |
| -32602 | Invalid params | Invalid method parameter(s) |
| -32603 | Internal error | Internal JSON-RPC error |
| -32000 to -32099 | Server error | Reserved for implementation-defined server-errors |

These are defined in the `JsonRpcErrorCodes` class:

```dart
class JsonRpcErrorCodes {
  static const int parseError = -32700;
  static const int invalidRequest = -32600;
  static const int methodNotFound = -32601;
  static const int invalidParams = -32602;
  static const int internalError = -32603;
  static const int serverErrorStart = -32099;
  static const int serverErrorEnd = -32000;
}
```

### MCP-Specific Error Codes

The MCP protocol defines additional error codes for MCP-specific errors:

| Code | Name | Description |
|------|------|-------------|
| -33000 | Resource not found | The requested resource was not found |
| -33001 | Tool not found | The requested tool was not found |
| -33002 | Prompt not found | The requested prompt was not found |
| -33003 | Cancelled | The operation was cancelled |
| -33004 | Timeout | The operation timed out |
| -33005 | Unauthorized | The client is not authorized to perform the operation |
| -33006 | Not supported | The operation is not supported |

These are defined in the `McpErrorCodes` class:

```dart
class McpErrorCodes {
  static const int resourceNotFound = -33000;
  static const int toolNotFound = -33001;
  static const int promptNotFound = -33002;
  static const int cancelled = -33003;
  static const int timeout = -33004;
  static const int unauthorized = -33005;
  static const int notSupported = -33006;
}
```

## Client-Side Error Handling

### Basic Error Handling

When using the MCP client, you should always handle potential errors:

```dart
import 'package:flutter_mcp/flutter_mcp.dart';

Future<void> listResources(McpClient client) async {
  try {
    final resources = await client.listResources();
    // Process resources...
  } on McpError catch (e) {
    print('MCP error: ${e.message} (code: ${e.code})');
    if (e.data != null) {
      print('Additional data: ${e.data}');
    }
  } catch (e) {
    print('Unexpected error: $e');
  }
}
```

### Error Type Checking

You can check the error code to handle specific error types:

```dart
Future<List<ResourceInfo>> listResourcesSafely(McpClient client) async {
  try {
    return await client.listResources();
  } on McpError catch (e) {
    if (e.code == JsonRpcErrorCodes.methodNotFound) {
      print('The server does not support listing resources');
      return [];
    } else if (e.code == McpErrorCodes.unauthorized) {
      print('Not authorized to list resources');
      throw e; // Rethrow for higher-level handling
    } else {
      print('Failed to list resources: ${e.message}');
      return [];
    }
  } catch (e) {
    print('Unexpected error: $e');
    return [];
  }
}
```

### Timeout Handling

The MCP client has a configurable timeout for requests:

```dart
final client = McpClient(
  name: 'My App',
  version: '1.0.0',
  capabilities: ClientCapabilities(...),
  timeout: Duration(seconds: 10), // Set a 10-second timeout
);
```

You can handle timeout errors specifically:

```dart
Future<void> callToolWithTimeout(McpClient client, String name, Map<String, dynamic> args) async {
  try {
    final result = await client.callTool(name, args);
    // Process result...
  } on McpError catch (e) {
    if (e.code == McpErrorCodes.timeout) {
      print('Tool call timed out');
      // Implement retry logic or fallback
    } else {
      print('Tool call failed: ${e.message}');
    }
  }
}
```

### Retry Logic

For transient errors, you can implement retry logic:

```dart
Future<T> withRetry<T>(
  Future<T> Function() operation, {
  int maxRetries = 3,
  Duration initialDelay = const Duration(milliseconds: 100),
}) async {
  int retries = 0;
  Duration delay = initialDelay;
  
  while (true) {
    try {
      return await operation();
    } on McpError catch (e) {
      // Only retry for certain error types
      if (e.code == McpErrorCodes.timeout ||
          e.code == JsonRpcErrorCodes.serverErrorStart ||
          (e.code >= JsonRpcErrorCodes.serverErrorStart && 
           e.code <= JsonRpcErrorCodes.serverErrorEnd)) {
        retries++;
        if (retries > maxRetries) {
          rethrow; // Max retries exceeded
        }
        
        print('Retrying after error: ${e.message} (retry $retries of $maxRetries)');
        await Future.delayed(delay);
        delay *= 2; // Exponential backoff
      } else {
        rethrow; // Non-retryable error
      }
    }
  }
}

// Usage
Future<List<ResourceInfo>> listResourcesWithRetry(McpClient client) async {
  return withRetry(() => client.listResources());
}
```

## Server-Side Error Handling

### Sending Error Responses

When implementing an MCP server, you need to send appropriate error responses:

```dart
void handleRequest(McpRequest request) {
  try {
    switch (request.method) {
      case 'listResources':
        final resources = listResources();
        sendResponse(McpResponse(
          id: request.id,
          result: {'resources': resources.map((r) => r.toJson()).toList()},
        ));
        break;
        
      case 'readResource':
        if (!request.params.containsKey('uri')) {
          sendErrorResponse(
            request.id,
            McpError(
              code: JsonRpcErrorCodes.invalidParams,
              message: 'Missing required parameter: uri',
            ),
          );
          return;
        }
        
        final uri = request.params['uri'] as String;
        try {
          final contents = readResource(uri);
          sendResponse(McpResponse(
            id: request.id,
            result: {'contents': contents.map((c) => c.toJson()).toList()},
          ));
        } catch (e) {
          if (e is ResourceNotFoundException) {
            sendErrorResponse(
              request.id,
              McpError(
                code: McpErrorCodes.resourceNotFound,
                message: 'Resource not found: $uri',
              ),
            );
          } else {
            sendErrorResponse(
              request.id,
              McpError(
                code: JsonRpcErrorCodes.internalError,
                message: 'Internal error: $e',
              ),
            );
          }
        }
        break;
        
      default:
        sendErrorResponse(
          request.id,
          McpError(
            code: JsonRpcErrorCodes.methodNotFound,
            message: 'Method not found: ${request.method}',
          ),
        );
        break;
    }
  } catch (e) {
    sendErrorResponse(
      request.id,
      McpError(
        code: JsonRpcErrorCodes.internalError,
        message: 'Internal error: $e',
      ),
    );
  }
}

void sendErrorResponse(String id, McpError error) {
  sendResponse(McpResponse(
    id: id,
    error: error,
  ));
}
```

### Error Mapping

Map application-specific exceptions to MCP errors:

```dart
McpError mapExceptionToMcpError(dynamic exception) {
  if (exception is McpError) {
    return exception;
  } else if (exception is ResourceNotFoundException) {
    return McpError(
      code: McpErrorCodes.resourceNotFound,
      message: exception.message,
    );
  } else if (exception is ToolNotFoundException) {
    return McpError(
      code: McpErrorCodes.toolNotFound,
      message: exception.message,
    );
  } else if (exception is PromptNotFoundException) {
    return McpError(
      code: McpErrorCodes.promptNotFound,
      message: exception.message,
    );
  } else if (exception is TimeoutException) {
    return McpError(
      code: McpErrorCodes.timeout,
      message: 'Operation timed out',
    );
  } else if (exception is UnauthorizedException) {
    return McpError(
      code: McpErrorCodes.unauthorized,
      message: exception.message,
    );
  } else {
    return McpError(
      code: JsonRpcErrorCodes.internalError,
      message: 'Internal error: $exception',
    );
  }
}
```

## Best Practices for Error Handling

### Provide Detailed Error Messages

Error messages should be clear and actionable:

```dart
// Bad
throw McpError(
  code: JsonRpcErrorCodes.invalidParams,
  message: 'Invalid params',
);

// Good
throw McpError(
  code: JsonRpcErrorCodes.invalidParams,
  message: 'Invalid parameter "temperature": expected a number between 0 and 1, got 2.5',
);
```

### Include Additional Error Data

Use the `data` field to provide additional information:

```dart
throw McpError(
  code: JsonRpcErrorCodes.invalidParams,
  message: 'Invalid parameters',
  data: {
    'invalidParams': ['temperature', 'model'],
    'validationErrors': {
      'temperature': 'Must be between 0 and 1',
      'model': 'Unknown model name',
    },
  },
);
```

### Log Errors

Log errors for debugging and monitoring:

```dart
void handleRequestWithLogging(McpRequest request) {
  try {
    handleRequest(request);
  } catch (e, stackTrace) {
    logger.severe('Error handling request: $e\n$stackTrace');
    
    sendErrorResponse(
      request.id,
      McpError(
        code: JsonRpcErrorCodes.internalError,
        message: 'Internal error',
      ),
    );
  }
}
```

### Implement Circuit Breakers

For external dependencies, implement circuit breakers to prevent cascading failures:

```dart
class CircuitBreaker {
  final int failureThreshold;
  final Duration resetTimeout;
  
  int _failureCount = 0;
  bool _isOpen = false;
  DateTime? _lastFailure;
  
  CircuitBreaker({
    this.failureThreshold = 3,
    this.resetTimeout = const Duration(seconds: 30),
  });
  
  Future<T> execute<T>(Future<T> Function() operation) async {
    if (_isOpen) {
      if (_lastFailure != null && 
          DateTime.now().difference(_lastFailure!) > resetTimeout) {
        // Half-open state: allow one request to try again
        _isOpen = false;
      } else {
        throw McpError(
          code: McpErrorCodes.cancelled,
          message: 'Circuit breaker is open',
        );
      }
    }
    
    try {
      final result = await operation();
      // Success: reset failure count
      _failureCount = 0;
      return result;
    } catch (e) {
      _failureCount++;
      _lastFailure = DateTime.now();
      
      if (_failureCount >= failureThreshold) {
        _isOpen = true;
      }
      
      rethrow;
    }
  }
}
```

## Conclusion

In this tutorial, you learned how to:
- Understand the MCP error taxonomy
- Handle errors on the client side
- Send error responses from the server
- Implement retry logic and circuit breakers
- Follow best practices for error handling

Proper error handling is essential for building robust MCP applications that can gracefully recover from failures.
