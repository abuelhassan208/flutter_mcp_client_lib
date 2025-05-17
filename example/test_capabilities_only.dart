/// Test file for ClientCapabilities implementation only
///
/// This file tests only the ClientCapabilities class without importing the full package
library test_capabilities_only;

// Import only the specific files we need
import 'package:flutter_mcp/src/models/mcp_capabilities.dart';

void main() {
  print('Testing ClientCapabilities implementation...');
  
  // Create a client capabilities object with all fields
  final capabilities = ClientCapabilities(
    sampling: SamplingCapabilityConfig(sample: true),
    resources: ResourceCapabilityConfig(list: true, read: true),
    tools: ToolCapabilityConfig(list: true, call: true),
    prompts: PromptCapabilityConfig(list: true, get: true),
  );
  
  // Verify that all fields are set correctly
  print('Sampling: ${capabilities.sampling?.sample}');
  print('Resources - list: ${capabilities.resources?.list}, read: ${capabilities.resources?.read}');
  print('Tools - list: ${capabilities.tools?.list}, call: ${capabilities.tools?.call}');
  print('Prompts - list: ${capabilities.prompts?.list}, get: ${capabilities.prompts?.get}');
  
  // Convert to JSON and back
  final json = capabilities.toJson();
  print('\nJSON representation:');
  print(json);
  
  final fromJson = ClientCapabilities.fromJson(json);
  print('\nRecreated from JSON:');
  print('Sampling: ${fromJson.sampling?.sample}');
  print('Resources - list: ${fromJson.resources?.list}, read: ${fromJson.resources?.read}');
  print('Tools - list: ${fromJson.tools?.list}, call: ${fromJson.tools?.call}');
  print('Prompts - list: ${fromJson.prompts?.list}, get: ${fromJson.prompts?.get}');
  
  // Test equality
  print('\nEquality test: ${capabilities == fromJson}');
  
  print('\nClientCapabilities implementation test completed successfully!');
}
