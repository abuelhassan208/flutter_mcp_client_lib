/// Example of using the MCP client
///
/// This example shows how to connect to an MCP server and use its resources,
/// tools, and prompts.
library mcp_client_example;

import 'dart:io';

// Using the package import
import 'package:flutter_mcp_client_lib/flutter_mcp_client_lib.dart';
import 'package:logging/logging.dart';

void main() async {
  // Set up logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    // Using a logger instead of print
    stderr.writeln('${record.level.name}: ${record.time}: ${record.message}');
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
    // Connect to a server
    final transport = McpWebSocketClientTransport(
      Uri.parse('ws://localhost:8080/mcp'),
    );
    await client.connect(transport);

    // List resources
    final resources = await client.listResources();
    Logger.root.info('Resources:');
    for (final resource in resources) {
      Logger.root.info('- ${resource.name}: ${resource.uriTemplate}');
    }

    // Read resources
    if (resources.isNotEmpty) {
      // Read greeting resource
      final greetingResource = resources.firstWhere(
        (resource) => resource.name == 'greeting',
        orElse: () => resources.first,
      );

      // Replace template parameter with actual value
      final greetingUri =
          greetingResource.uriTemplate.replaceAll('{name}', 'Dart');
      final greetingContents = await client.readResource(greetingUri);
      Logger.root.info('Resource ${greetingResource.name} contents:');
      for (final content in greetingContents) {
        Logger.root.info('- ${content.uri}: ${content.text}');
      }

      // Read time resource
      final timeResource = resources.firstWhere(
        (resource) => resource.name == 'time',
        orElse: () => resources.first,
      );

      final timeContents = await client.readResource('time://current');
      Logger.root.info('Resource ${timeResource.name} contents:');
      for (final content in timeContents) {
        Logger.root.info('- ${content.uri}: ${content.text}');
      }
    }

    // List tools
    final tools = await client.listTools();
    Logger.root.info('Tools:');
    for (final tool in tools) {
      Logger.root.info('- ${tool.name}: ${tool.description}');
    }

    // Call tools
    if (tools.isNotEmpty) {
      // Find the add tool
      final addTool = tools.firstWhere(
        (tool) => tool.name == 'add',
        orElse: () => tools.first,
      );

      // Call the add tool with correct arguments
      final addResult = await client.callTool(addTool.name, {
        'a': '5',
        'b': '7',
      });
      Logger.root.info('Tool ${addTool.name} result:');
      for (final content in addResult.content) {
        Logger.root.info('- ${content.type}: ${content.text}');
      }

      // Find the echo tool
      final echoTool = tools.firstWhere(
        (tool) => tool.name == 'echo',
        orElse: () => tools.first,
      );

      // Call the echo tool with correct arguments
      final echoResult = await client.callTool(echoTool.name, {
        'message': 'Hello from MCP client!',
      });
      Logger.root.info('Tool ${echoTool.name} result:');
      for (final content in echoResult.content) {
        Logger.root.info('- ${content.type}: ${content.text}');
      }
    }

    // List prompts
    final prompts = await client.listPrompts();
    Logger.root.info('Prompts:');
    for (final prompt in prompts) {
      Logger.root.info('- ${prompt.name}: ${prompt.description}');
    }

    // Get a prompt
    if (prompts.isNotEmpty) {
      final prompt = prompts.first;
      final result = await client.getPrompt(prompt.name, {
        'name': 'Dart Developer',
      });
      Logger.root.info('Prompt ${prompt.name} result:');
      for (final message in result.messages) {
        Logger.root.info('- ${message.role}: ${message.content.text}');
      }
    }
  } catch (e) {
    Logger.root.severe('Error: $e');
  } finally {
    // Disconnect from the server
    await client.disconnect();
  }
}
