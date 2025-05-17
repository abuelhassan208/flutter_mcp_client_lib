/// Simple test application for MCP UI components
///
/// This application demonstrates each MCP UI component individually
/// with a simple interface for testing.
import 'package:flutter/material.dart';
import 'package:flutter_mcp/flutter_mcp.dart';

void main() {
  runApp(const McpUiSimpleTestApp());
}

class McpUiSimpleTestApp extends StatelessWidget {
  const McpUiSimpleTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MCP UI Simple Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const McpUiSimpleTestPage(),
    );
  }
}

class McpUiSimpleTestPage extends StatefulWidget {
  const McpUiSimpleTestPage({super.key});

  @override
  State<McpUiSimpleTestPage> createState() => _McpUiSimpleTestPageState();
}

class _McpUiSimpleTestPageState extends State<McpUiSimpleTestPage> {
  late McpTheme _mcpTheme;
  String _selectedWidget = 'Text';

  // Create mock responses for testing
  final Map<String, McpResponse> _mockResponses = {
    'Text': McpResponseImpl(
      id: 'text-response-1',
      result: {
        'text': 'This is a simple text response from the MCP server. '
            'It demonstrates how text responses are rendered with the '
            'McpTextResponseWidget.\n\n'
            'Text responses can contain multiple paragraphs and are '
            'formatted according to the theme settings.',
      },
    ),
    'Code': McpResponseImpl(
      id: 'code-response-1',
      result: {
        'code': '''
void main() {
  print('Hello, MCP!');
  
  // This is an example code block
  final client = McpClient(
    name: 'Example Client',
    version: '1.0.0',
  );
  
  // Connect to the server
  await client.connect(transport);
}''',
        'language': 'dart',
      },
    ),
    'Data': McpResponseImpl(
      id: 'data-response-1',
      result: {
        'data': {
          'name': 'Example Data',
          'type': 'JSON',
          'properties': {
            'nested': true,
            'interactive': true,
            'values': [1, 2, 3, 4, 5],
          },
          'metadata': {
            'created': '2025-05-15T12:00:00Z',
            'version': '1.0.0',
          },
        },
      },
    ),
    'Error': McpResponseImpl(
      id: 'error-response-1',
      error: McpError(
        code: -33000, // resourceNotFound
        message: 'The requested resource was not found',
        data: {
          'uri': 'example://not-found',
          'timestamp': '2025-05-15T12:00:00Z',
        },
      ),
    ),
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize the MCP theme based on the current Flutter theme
    _mcpTheme = McpTheme.fromTheme(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MCP UI Simple Test'),
      ),
      body: Column(
        children: [
          // Widget selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text('Select Widget: '),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedWidget,
                  items: _mockResponses.keys.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text('$value Response'),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedWidget = newValue;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          
          // Divider
          const Divider(),
          
          // Widget display
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: _buildSelectedWidget(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedWidget() {
    final response = _mockResponses[_selectedWidget];
    if (response == null) {
      return const Center(child: Text('No widget selected'));
    }

    final renderer = McpResponseRenderer(
      theme: _mcpTheme,
      onInteraction: _handleInteraction,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$_selectedWidget Response Widget',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        renderer.render(context, response),
        const SizedBox(height: 32),
        const Text(
          'Widget Properties:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildWidgetProperties(),
      ],
    );
  }

  Widget _buildWidgetProperties() {
    switch (_selectedWidget) {
      case 'Text':
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Displays plain text content'),
            Text('• Supports copy to clipboard'),
            Text('• Handles text selection'),
            Text('• Applies theme styling'),
          ],
        );
      case 'Code':
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Displays code with syntax highlighting'),
            Text('• Shows language label'),
            Text('• Supports line numbers'),
            Text('• Provides copy to clipboard functionality'),
          ],
        );
      case 'Data':
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Renders structured data (JSON)'),
            Text('• Supports interactive exploration'),
            Text('• Expandable/collapsible nodes'),
            Text('• Provides copy to clipboard functionality'),
          ],
        );
      case 'Error':
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Displays error messages with error code'),
            Text('• Shows error details when available'),
            Text('• Uses appropriate error styling'),
            Text('• Can include retry functionality'),
          ],
        );
      default:
        return const Text('No properties available');
    }
  }

  void _handleInteraction(
    String responseId,
    String interactionType,
    Map<String, dynamic> data,
  ) {
    // Show a snackbar with the interaction details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Interaction: $interactionType on $responseId'),
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Log the interaction details
    debugPrint('Interaction: $responseId, $interactionType, $data');
  }
}
