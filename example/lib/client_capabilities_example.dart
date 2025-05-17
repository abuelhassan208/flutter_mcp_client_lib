// Example demonstrating the ClientCapabilities feature
import 'package:flutter_mcp_client_lib/flutter_mcp_client_lib.dart';

void main() {
  // Create a client with all capabilities enabled
  final fullClient = McpClient(
    name: 'Full Capabilities Client',
    version: '1.0.0',
    capabilities: const ClientCapabilities(
      sampling: SamplingCapabilityConfig(sample: true),
      resources: ResourceCapabilityConfig(list: true, read: true),
      tools: ToolCapabilityConfig(list: true, call: true),
      prompts: PromptCapabilityConfig(list: true, get: true),
    ),
  );
  
  print('Full Client Capabilities:');
  print('- Sampling: ${fullClient.capabilities.sampling?.sample}');
  print('- Resources: list=${fullClient.capabilities.resources?.list}, read=${fullClient.capabilities.resources?.read}');
  print('- Tools: list=${fullClient.capabilities.tools?.list}, call=${fullClient.capabilities.tools?.call}');
  print('- Prompts: list=${fullClient.capabilities.prompts?.list}, get=${fullClient.capabilities.prompts?.get}');
  
  // Create a client with limited capabilities
  final limitedClient = McpClient(
    name: 'Limited Capabilities Client',
    version: '1.0.0',
    capabilities: const ClientCapabilities(
      sampling: SamplingCapabilityConfig(sample: false),
      resources: ResourceCapabilityConfig(list: true, read: false),
      tools: null, // No tool capabilities
      prompts: PromptCapabilityConfig(list: true, get: false),
    ),
  );
  
  print('\nLimited Client Capabilities:');
  print('- Sampling: ${limitedClient.capabilities.sampling?.sample}');
  print('- Resources: list=${limitedClient.capabilities.resources?.list}, read=${limitedClient.capabilities.resources?.read}');
  print('- Tools: ${limitedClient.capabilities.tools == null ? "Not supported" : "Supported"}');
  print('- Prompts: list=${limitedClient.capabilities.prompts?.list}, get=${limitedClient.capabilities.prompts?.get}');
  
  // Convert capabilities to JSON
  final json = fullClient.capabilities.toJson();
  print('\nCapabilities as JSON:');
  print(json);
  
  // Create capabilities from JSON
  final fromJson = ClientCapabilities.fromJson(json);
  print('\nCapabilities from JSON:');
  print('- Sampling: ${fromJson.sampling?.sample}');
  print('- Resources: list=${fromJson.resources?.list}, read=${fromJson.resources?.read}');
  print('- Tools: list=${fromJson.tools?.list}, call=${fromJson.tools?.call}');
  print('- Prompts: list=${fromJson.prompts?.list}, get=${fromJson.prompts?.get}');
}
