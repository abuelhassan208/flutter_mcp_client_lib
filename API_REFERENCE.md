# Flutter MCP API Reference

This document provides a comprehensive reference for the Flutter MCP package API.

## Table of Contents

- [McpClient](#mcpclient)
- [Transports](#transports)
  - [McpClientTransport](#mcpclienttransport)
  - [McpWebSocketClientTransport](#mcpwebsocketclienttransport)
- [Models](#models)
  - [McpMessage](#mcpmessage)
  - [McpRequest](#mcprequest)
  - [McpResponse](#mcpresponse)
  - [McpNotification](#mcpnotification)
  - [McpError](#mcperror)
- [Resources](#resources)
  - [ResourceInfo](#resourceinfo)
  - [ResourceContent](#resourcecontent)
- [Tools](#tools)
  - [ToolInfo](#toolinfo)
  - [ToolArgument](#toolargument)
  - [CallToolResult](#calltoolresult)
- [Prompts](#prompts)
  - [PromptInfo](#promptinfo)
  - [PromptArgument](#promptargument)
  - [GetPromptResult](#getpromptresult)
  - [Message](#message)
  - [MessageContent](#messagecontent)
- [Capabilities](#capabilities)
  - [ClientCapabilities](#clientcapabilities)
  - [ServerCapabilities](#servercapabilities)
  - [SamplingCapabilityConfig](#samplingcapabilityconfig)
  - [ResourceCapabilityConfig](#resourcecapabilityconfig)
  - [ToolCapabilityConfig](#toolcapabilityconfig)
  - [PromptCapabilityConfig](#promptcapabilityconfig)
- [Error Codes](#error-codes)
  - [JsonRpcErrorCodes](#jsonrpcerrorcodes)
  - [McpErrorCodes](#mcperrorcodes)

## McpClient

```dart
/// Creates a new MCP client with the specified configuration.
///
/// The [name] parameter identifies this client to the server.
/// The [version] should follow semantic versioning.
/// The [capabilities] define what features this client supports.
///
/// Throws [McpConfigurationError] if the configuration is invalid.
///
/// Example:
/// ```dart
/// final client = McpClient(
///   name: 'MyApp',
///   version: '1.0.0',
///   capabilities: ClientCapabilities(
///     sampling: SamplingCapabilityConfig(sample: true),
///     resources: ResourceCapabilityConfig(list: true, read: true),
///     tools: ToolCapabilityConfig(list: true, call: true),
///     prompts: PromptCapabilityConfig(list: true, get: true),
///   ),
/// );
/// ```
McpClient({
  required String name,
  required String version,
  ClientCapabilities? capabilities,
});

/// Connects the client to an MCP server using the provided transport.
///
/// This method establishes a connection to the server and performs
/// the initial handshake and capability negotiation.
///
/// Throws [McpConnectionError] if the connection fails.
///
/// Example:
/// ```dart
/// final transport = McpWebSocketClientTransport(
///   Uri.parse('ws://localhost:8080/mcp'),
/// );
/// await client.connect(transport);
/// ```
Future<void> connect(McpClientTransport transport);

/// Disconnects the client from the MCP server.
///
/// This method closes the connection to the server and cleans up
/// any resources used by the client.
///
/// Example:
/// ```dart
/// await client.disconnect();
/// ```
Future<void> disconnect();

/// Lists the resources available on the server.
///
/// Returns a list of [ResourceInfo] objects describing the available resources.
///
/// Throws [McpRequestError] if the request fails.
///
/// Example:
/// ```dart
/// final resources = await client.listResources();
/// for (final resource in resources) {
///   print('${resource.name}: ${resource.uriTemplate}');
/// }
/// ```
Future<List<ResourceInfo>> listResources();

/// Reads a resource from the server.
///
/// The [uri] parameter specifies the URI of the resource to read.
/// For template URIs, replace parameters with actual values.
///
/// Returns a list of [ResourceContent] objects containing the resource content.
///
/// Throws [McpRequestError] if the request fails.
///
/// Example:
/// ```dart
/// final contents = await client.readResource('greeting://John');
/// for (final content in contents) {
///   print('${content.uri}: ${content.text}');
/// }
/// ```
Future<List<ResourceContent>> readResource(String uri);

/// Lists the tools available on the server.
///
/// Returns a list of [ToolInfo] objects describing the available tools.
///
/// Throws [McpRequestError] if the request fails.
///
/// Example:
/// ```dart
/// final tools = await client.listTools();
/// for (final tool in tools) {
///   print('${tool.name}: ${tool.description}');
/// }
/// ```
Future<List<ToolInfo>> listTools();

/// Calls a tool on the server.
///
/// The [name] parameter specifies the name of the tool to call.
/// The [arguments] parameter contains the arguments to pass to the tool.
///
/// Returns a [CallToolResult] object containing the result of the tool call.
///
/// Throws [McpRequestError] if the request fails.
///
/// Example:
/// ```dart
/// final result = await client.callTool('add', {'a': '5', 'b': '7'});
/// for (final content in result.content) {
///   print('${content.type}: ${content.text}');
/// }
/// ```
Future<CallToolResult> callTool(String name, Map<String, dynamic> arguments);

/// Lists the prompts available on the server.
///
/// Returns a list of [PromptInfo] objects describing the available prompts.
///
/// Throws [McpRequestError] if the request fails.
///
/// Example:
/// ```dart
/// final prompts = await client.listPrompts();
/// for (final prompt in prompts) {
///   print('${prompt.name}: ${prompt.description}');
/// }
/// ```
Future<List<PromptInfo>> listPrompts();

/// Gets a prompt from the server.
///
/// The [name] parameter specifies the name of the prompt to get.
/// The [arguments] parameter contains the arguments to pass to the prompt.
///
/// Returns a [GetPromptResult] object containing the prompt messages.
///
/// Throws [McpRequestError] if the request fails.
///
/// Example:
/// ```dart
/// final result = await client.getPrompt('greeting', {'name': 'John'});
/// for (final message in result.messages) {
///   print('${message.role}: ${message.content.text}');
/// }
/// ```
Future<GetPromptResult> getPrompt(String name, Map<String, dynamic> arguments);
```

## Capabilities

### ClientCapabilities

```dart
/// Client capabilities configuration
class ClientCapabilities {
  /// Sampling capabilities
  final SamplingCapabilityConfig? sampling;

  /// Resource capabilities
  final ResourceCapabilityConfig? resources;

  /// Tool capabilities
  final ToolCapabilityConfig? tools;

  /// Prompt capabilities
  final PromptCapabilityConfig? prompts;

  const ClientCapabilities({
    this.sampling,
    this.resources,
    this.tools,
    this.prompts,
  });
}
```

### ServerCapabilities

```dart
/// Server capabilities configuration
class ServerCapabilities {
  /// Resource capabilities
  final ResourceCapabilityConfig? resources;

  /// Tool capabilities
  final ToolCapabilityConfig? tools;

  /// Prompt capabilities
  final PromptCapabilityConfig? prompts;

  const ServerCapabilities({
    this.resources,
    this.tools,
    this.prompts,
  });
}
```

### SamplingCapabilityConfig

```dart
/// Configuration for sampling capabilities
class SamplingCapabilityConfig {
  /// Whether the client supports sampling
  final bool? sample;

  const SamplingCapabilityConfig({this.sample});
}
```

### ResourceCapabilityConfig

```dart
/// Configuration for resource capabilities
class ResourceCapabilityConfig {
  /// Whether the server supports listing resources
  final bool? list;

  /// Whether the server supports reading resources
  final bool? read;

  const ResourceCapabilityConfig({this.list, this.read});
}
```

### ToolCapabilityConfig

```dart
/// Configuration for tool capabilities
class ToolCapabilityConfig {
  /// Whether the server supports listing tools
  final bool? list;

  /// Whether the server supports calling tools
  final bool? call;

  const ToolCapabilityConfig({this.list, this.call});
}
```

### PromptCapabilityConfig

```dart
/// Configuration for prompt capabilities
class PromptCapabilityConfig {
  /// Whether the server supports listing prompts
  final bool? list;

  /// Whether the server supports getting prompts
  final bool? get;

  const PromptCapabilityConfig({this.list, this.get});
}
```

For complete API documentation, run `dart doc` in the package directory and open the generated documentation in your browser.
