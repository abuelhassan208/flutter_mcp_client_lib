import 'package:flutter_mcp_client_lib/src/utils/json_rpc.dart';
import 'package:test/test.dart';

void main() {
  group('JSON-RPC Utils', () {
    test('generateRequestId should generate unique v4 UUIDs', () {
      final uuidV4Regex = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
      );
      const numberOfIdsToGenerate = 100;
      final generatedIds = <String>{};

      for (int i = 0; i < numberOfIdsToGenerate; i++) {
        final id = generateRequestId();
        
        // Assert that the ID is a valid v4 UUID
        expect(uuidV4Regex.hasMatch(id), isTrue, reason: 'ID $id is not a valid v4 UUID');
        
        // Add to set for uniqueness check
        generatedIds.add(id);
      }

      // Assert that all generated IDs were unique
      expect(generatedIds.length, numberOfIdsToGenerate, reason: 'Not all generated IDs were unique');
    });
  });
}
