/// Test application for MCP UI components
///
/// This application demonstrates the MCP UI components without requiring
/// an actual MCP server connection. It creates mock responses and renders
/// them using the MCP Response Widgets.
import 'package:flutter/material.dart';
import 'package:flutter_mcp/flutter_mcp.dart';

void main() {
  runApp(const McpUiTestApp());
}

class McpUiTestApp extends StatelessWidget {
  const McpUiTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MCP UI Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const McpUiTestPage(),
    );
  }
}

class McpUiTestPage extends StatefulWidget {
  const McpUiTestPage({super.key});

  @override
  State<McpUiTestPage> createState() => _McpUiTestPageState();
}

class _McpUiTestPageState extends State<McpUiTestPage> {
  late McpTheme _mcpTheme;
  bool _useDarkTheme = false;

  // Create mock responses for testing
  final List<McpResponse> _mockResponses = [
    // Text response
    McpResponseImpl(
      id: 'text-response-1',
      result: {
        'text': 'This is a simple text response from the MCP server. '
            'It demonstrates how text responses are rendered with the '
            'McpTextResponseWidget.\n\n'
            'Text responses can contain multiple paragraphs and are '
            'formatted according to the theme settings.',
      },
    ),
    
    // Code response
    McpResponseImpl(
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
  
  // List available resources
  final resources = await client.listResources();
  print('Available resources:');
  for (final resource in resources) {
    print('- \${resource.name}: \${resource.uriTemplate}');
  }
}''',
        'language': 'dart',
      },
    ),
    
    // Data response
    McpResponseImpl(
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
    
    // Error response
    McpResponseImpl(
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
  ];

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
        title: const Text('MCP UI Test'),
        actions: [
          // Theme toggle
          IconButton(
            icon: Icon(_useDarkTheme ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              setState(() {
                _useDarkTheme = !_useDarkTheme;
                _mcpTheme = _useDarkTheme
                    ? McpTheme.dark(context)
                    : McpTheme.light(context);
              });
            },
            tooltip: _useDarkTheme ? 'Switch to Light Theme' : 'Switch to Dark Theme',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'MCP Response Widgets',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          
          // Response list
          Expanded(
            child: _buildResponseList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseList() {
    final renderer = McpResponseRenderer(
      theme: _mcpTheme,
      onInteraction: _handleInteraction,
    );

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _mockResponses.length,
      itemBuilder: (context, index) {
        final response = _mockResponses[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Response type header
              Text(
                _getResponseTypeLabel(response),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Rendered response
              renderer.render(context, response),
            ],
          ),
        );
      },
    );
  }

  String _getResponseTypeLabel(McpResponse response) {
    if (response.error != null) {
      return 'Error Response';
    }
    
    final result = response.result;
    if (result == null) {
      return 'Unknown Response';
    }
    
    if (result.containsKey('text')) {
      return 'Text Response';
    } else if (result.containsKey('code')) {
      return 'Code Response';
    } else if (result.containsKey('data')) {
      return 'Data Response';
    }
    
    return 'Unknown Response';
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
