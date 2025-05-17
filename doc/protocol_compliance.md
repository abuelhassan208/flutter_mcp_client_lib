# Protocol Compliance Documentation

This document details the Flutter MCP package's compliance with the Model Context Protocol (MCP) specification.

## Supported Protocol Version

The Flutter MCP package implements the MCP protocol version `2025-03-26`.

## Message Types

| Message Type | Implementation Status | Notes |
|--------------|----------------------|-------|
| Request | Full | Fully implemented with all required fields |
| Response | Full | Fully implemented with all required fields |
| Notification | Full | Fully implemented with all required fields |
| Error | Full | Fully implemented with all required fields |

## Methods

### Core Methods

| Method | Implementation Status | Notes |
|--------|----------------------|-------|
| `initialize` | Full | Fully implemented with capability negotiation |
| `initialized` | Full | Fully implemented as a notification |
| `shutdown` | Full | Fully implemented |
| `exit` | Full | Fully implemented as a notification |

### Resource Methods

| Method | Implementation Status | Notes |
|--------|----------------------|-------|
| `listResources` | Full | Fully implemented |
| `readResource` | Full | Fully implemented |

### Tool Methods

| Method | Implementation Status | Notes |
|--------|----------------------|-------|
| `listTools` | Full | Fully implemented |
| `callTool` | Full | Fully implemented |

### Prompt Methods

| Method | Implementation Status | Notes |
|--------|----------------------|-------|
| `listPrompts` | Full | Fully implemented |
| `getPrompt` | Full | Fully implemented |

### Sampling Methods

| Method | Implementation Status | Notes |
|--------|----------------------|-------|
| `sample` | Full | Fully implemented |

## Capabilities

### Client Capabilities

| Capability | Implementation Status | Notes |
|------------|----------------------|-------|
| `sampling` | Full | Fully implemented with sample flag |
| `resources` | Full | Fully implemented with list and read flags |
| `tools` | Full | Fully implemented with list and call flags |
| `prompts` | Full | Fully implemented with list and get flags |

### Server Capabilities

| Capability | Implementation Status | Notes |
|------------|----------------------|-------|
| `sampling` | Full | Fully implemented with sample flag |
| `resources` | Full | Fully implemented with list and read flags |
| `tools` | Full | Fully implemented with list and call flags |
| `prompts` | Full | Fully implemented with list and get flags |

## Extensions and Deviations

### Custom Extensions

The Flutter MCP package implements the following extensions to the standard MCP protocol:

#### Enhanced Logging

The package includes enhanced logging capabilities beyond what is required by the specification:

```dart
// Enable detailed logging
Logger.root.level = Level.FINE;
Logger.root.onRecord.listen((record) {
  print('${record.level.name}: ${record.time}: ${record.message}');
});

// Configure client with logging
final client = McpClient(
  name: 'My App',
  version: '1.0.0',
  capabilities: ClientCapabilities(...),
  logger: Logger('mcp.client'), // Custom logger
);
```

#### Connection Management

The package includes additional connection management features:

```dart
// Configure client with connection management
final client = McpClient(
  name: 'My App',
  version: '1.0.0',
  capabilities: ClientCapabilities(...),
  reconnectOptions: ReconnectOptions(
    maxAttempts: 5,
    initialDelay: Duration(seconds: 1),
    maxDelay: Duration(seconds: 30),
  ),
);
```

### Implementation-Specific Behaviors

#### Transport Layer

The Flutter MCP package provides two transport implementations:

1. **WebSocket Transport**: The primary transport mechanism, supporting bidirectional communication
2. **HTTP Transport**: An alternative transport for environments where WebSockets are not available

This differs from the specification, which does not mandate specific transport mechanisms.

#### Error Handling

The package implements more detailed error handling than required by the specification:

- Circuit breaker pattern for external dependencies
- Retry logic with exponential backoff
- Detailed error logging and reporting

#### Message Serialization

The package uses Dart's `json_serializable` package for JSON serialization, which may result in slight differences in JSON formatting compared to other implementations.

### Error Codes

The package implements all standard JSON-RPC 2.0 error codes and MCP-specific error codes:

#### JSON-RPC Error Codes

| Code | Name | Description | Handling Recommendation |
|------|------|-------------|-------------------------|
| -32700 | Parse error | Invalid JSON was received | Check the format of your JSON messages |
| -32600 | Invalid request | The JSON sent is not a valid Request object | Verify your request structure |
| -32601 | Method not found | The method does not exist / is not available | Check method name and server capabilities |
| -32602 | Invalid params | Invalid method parameter(s) | Verify parameter names and types |
| -32603 | Internal error | Internal JSON-RPC error | Check server logs for details |
| -32000 to -32099 | Server error | Reserved for implementation-defined server-errors | Refer to server documentation |

#### MCP-Specific Error Codes

| Code | Name | Description | Handling Recommendation |
|------|------|-------------|-------------------------|
| -33000 | Resource not found | The requested resource was not found | Check resource URI |
| -33001 | Tool not found | The requested tool was not found | Check tool name |
| -33002 | Prompt not found | The requested prompt was not found | Check prompt name |
| -33003 | Cancelled | The operation was cancelled | Retry if appropriate |
| -33004 | Timeout | The operation timed out | Increase timeout or optimize operation |
| -33005 | Unauthorized | The client is not authorized to perform the operation | Check authentication |
| -33006 | Not supported | The operation is not supported | Check server capabilities |

#### Custom Error Codes

The package defines the following custom error codes:

| Code | Name | Description | Handling Recommendation |
|------|------|-------------|-------------------------|
| -34000 | Connection error | Error establishing connection | Check network and server status |
| -34001 | Transport error | Error in transport layer | Check transport configuration |
| -34002 | Protocol error | Error in protocol implementation | Check client and server versions |

## Compatibility Information

### Protocol Versions

The Flutter MCP package is compatible with the following MCP protocol versions:

| Protocol Version | Compatibility | Notes |
|------------------|---------------|-------|
| 2025-03-26 | Full | Primary supported version |
| Future versions | Unknown | May require updates |

### Platform Support

The Flutter MCP package has been tested on the following platforms:

| Platform | Support Level | Notes |
|----------|--------------|-------|
| Android | Full | Tested on Android 10+ |
| iOS | Full | Tested on iOS 14+ |
| Web | Full | Tested on Chrome, Firefox, Safari |
| macOS | Full | Tested on macOS 11+ |
| Windows | Full | Tested on Windows 10+ |
| Linux | Full | Tested on Ubuntu 20.04+ |

### Version Requirements

The Flutter MCP package has the following version requirements:

| Dependency | Minimum Version | Recommended Version | Notes |
|------------|----------------|---------------------|-------|
| Flutter SDK | 3.0.0 | 3.10.0 or higher | Required for null safety |
| Dart SDK | 3.0.0 | 3.0.0 or higher | Required for null safety |
| web_socket_channel | 2.2.0 | 2.4.0 or higher | Required for WebSocket support |
| http | 0.13.0 | 1.1.0 or higher | Required for HTTP support |
| json_serializable | 6.0.0 | 6.7.0 or higher | Required for JSON serialization |
| equatable | 2.0.0 | 2.0.5 or higher | Required for value equality |
| meta | 1.7.0 | 1.9.1 or higher | Required for annotations |
| logging | 1.0.0 | 1.2.0 or higher | Required for logging |

## Conclusion

The Flutter MCP package provides a complete and compliant implementation of the Model Context Protocol (MCP) specification version 2025-03-26. It includes all required message types, methods, and capabilities, with some extensions for enhanced functionality and platform-specific optimizations.
