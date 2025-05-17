// Example demonstrating the ClientCapabilities feature
import 'package:flutter_mcp_client_lib/flutter_mcp_client_lib.dart';
import 'package:logging/logging.dart';

void main() {
  // Set up logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  final log = Logger('ClientCapabilitiesExample');

  // Create capabilities objects directly
  final fullCapabilities = ClientCapabilities(
    sampling: SamplingCapabilityConfig(sample: true),
    resources: ResourceCapabilityConfig(list: true, read: true),
    tools: ToolCapabilityConfig(list: true, call: true),
    prompts: PromptCapabilityConfig(list: true, get: true),
  );

  log.info('Full Capabilities:');
  log.info('- Sampling: ${fullCapabilities.sampling?.sample}');
  log.info(
      '- Resources: list=${fullCapabilities.resources?.list}, read=${fullCapabilities.resources?.read}');
  log.info(
      '- Tools: list=${fullCapabilities.tools?.list}, call=${fullCapabilities.tools?.call}');
  log.info(
      '- Prompts: list=${fullCapabilities.prompts?.list}, get=${fullCapabilities.prompts?.get}');

  // Create limited capabilities
  final limitedCapabilities = ClientCapabilities(
    sampling: SamplingCapabilityConfig(sample: false),
    resources: ResourceCapabilityConfig(list: true, read: false),
    tools: null, // No tool capabilities
    prompts: PromptCapabilityConfig(list: true, get: false),
  );

  log.info('\nLimited Capabilities:');
  log.info('- Sampling: ${limitedCapabilities.sampling?.sample}');
  log.info(
      '- Resources: list=${limitedCapabilities.resources?.list}, read=${limitedCapabilities.resources?.read}');
  log.info(
      '- Tools: ${limitedCapabilities.tools == null ? "Not supported" : "Supported"}');
  log.info(
      '- Prompts: list=${limitedCapabilities.prompts?.list}, get=${limitedCapabilities.prompts?.get}');

  // Convert capabilities to JSON
  final json = fullCapabilities.toJson();
  log.info('\nCapabilities as JSON:');
  log.info(json.toString());

  // Create capabilities from JSON
  final fromJson = ClientCapabilities.fromJson(json);
  log.info('\nCapabilities from JSON:');
  log.info('- Sampling: ${fromJson.sampling?.sample}');
  log.info(
      '- Resources: list=${fromJson.resources?.list}, read=${fromJson.resources?.read}');
  log.info(
      '- Tools: list=${fromJson.tools?.list}, call=${fromJson.tools?.call}');
  log.info(
      '- Prompts: list=${fromJson.prompts?.list}, get=${fromJson.prompts?.get}');

  // Create a client with these capabilities and use it
  McpClient(
    name: 'Example Client',
    version: '1.0.0',
    capabilities: fullCapabilities,
  );

  log.info('\nClient created with capabilities successfully!');
}
