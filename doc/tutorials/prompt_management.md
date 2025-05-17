# Prompt Management Tutorial

This tutorial explains how to work with prompts in the Model Context Protocol (MCP) using the Flutter MCP package.

## What are MCP Prompts?

Prompts in MCP are templates for generating messages that can be sent to language models. They can:

- Define system instructions
- Create user messages
- Include variable substitution
- Format content for different AI models

Prompts have names, descriptions, arguments, and return messages.

## Client-Side: Using Prompts

### Listing Available Prompts

To list the prompts available on an MCP server:

```dart
import 'package:flutter_mcp/flutter_mcp.dart';

Future<void> listPrompts(McpClient client) async {
  try {
    final prompts = await client.listPrompts();
    
    print('Available prompts:');
    for (final prompt in prompts) {
      print('- ${prompt.name}: ${prompt.description}');
      
      print('  Arguments:');
      for (final arg in prompt.arguments) {
        print('    - ${arg.name}: ${arg.description}');
        print('      Required: ${arg.required}');
      }
    }
  } catch (e) {
    print('Failed to list prompts: $e');
  }
}
```

The `listPrompts()` method returns a list of `PromptInfo` objects, each containing:
- `name`: The name of the prompt
- `description`: A description of the prompt
- `arguments`: A list of `PromptArgument` objects describing the prompt's arguments

### Getting Prompts

To get a prompt from an MCP server:

```dart
Future<void> getPrompt(McpClient client, String name, Map<String, dynamic> args) async {
  try {
    final result = await client.getPrompt(name, args);
    
    print('Prompt: ${result.description}');
    print('Messages:');
    for (final message in result.messages) {
      print('- ${message.role}: ${message.content.text}');
    }
  } catch (e) {
    print('Failed to get prompt: $e');
  }
}
```

The `getPrompt()` method returns a `GetPromptResult` object containing:
- `description`: A description of the prompt
- `messages`: A list of `Message` objects with the prompt's messages

### Example: Getting Specific Prompts

Here's an example of getting specific prompts:

```dart
// Get the 'greeting' prompt
Future<void> getGreetingPrompt(McpClient client, String name) async {
  final result = await client.getPrompt('greeting', {
    'name': name,
  });
  
  print('Greeting prompt:');
  for (final message in result.messages) {
    print('- ${message.role}: ${message.content.text}');
  }
}

// Get the 'code_review' prompt
Future<void> getCodeReviewPrompt(McpClient client, String language, String code) async {
  final result = await client.getPrompt('code_review', {
    'language': language,
    'code': code,
  });
  
  print('Code review prompt:');
  for (final message in result.messages) {
    print('- ${message.role}: ${message.content.text}');
  }
}
```

## Server-Side: Implementing Prompts

### Defining Prompt Providers

When implementing an MCP server, you need to define prompt providers that can handle prompt requests:

```dart
class GreetingPromptProvider {
  PromptInfo getPromptInfo() {
    return PromptInfo(
      name: 'greeting',
      description: 'A greeting prompt',
      arguments: [
        PromptArgument(
          name: 'name',
          description: 'The name to greet',
          required: true,
        ),
      ],
    );
  }
  
  GetPromptResult getPrompt(Map<String, dynamic> args) {
    // Validate arguments
    if (!args.containsKey('name')) {
      throw ArgumentError('Missing required argument: name');
    }
    
    final name = args['name'] as String;
    
    // Create messages
    return GetPromptResult(
      description: 'A greeting prompt for $name',
      messages: [
        Message(
          role: MessageRole.system,
          content: MessageContent(
            type: ContentType.text,
            text: 'You are a helpful assistant.',
          ),
        ),
        Message(
          role: MessageRole.user,
          content: MessageContent(
            type: ContentType.text,
            text: 'Hello, $name!',
          ),
        ),
      ],
    );
  }
}
```

### Registering Prompt Providers

In your server implementation, register the prompt providers:

```dart
class MyMcpServer {
  final List<dynamic> _promptProviders = [];
  
  void registerPromptProvider(dynamic provider) {
    _promptProviders.add(provider);
  }
  
  List<PromptInfo> listPrompts() {
    return _promptProviders
        .map((provider) => provider.getPromptInfo())
        .toList();
  }
  
  GetPromptResult getPrompt(String name, Map<String, dynamic> args) {
    // Find a provider that can handle this prompt
    for (final provider in _promptProviders) {
      if (provider.getPromptInfo().name == name) {
        return provider.getPrompt(args);
      }
    }
    
    throw McpError(
      code: McpErrorCodes.promptNotFound,
      message: 'Prompt not found: $name',
    );
  }
  
  // Other server methods...
}
```

### Handling Prompt Requests

In your server's request handler, handle prompt-related requests:

```dart
void handleRequest(McpRequest request) {
  switch (request.method) {
    case 'listPrompts':
      final prompts = listPrompts();
      sendResponse(McpResponse(
        id: request.id,
        result: {'prompts': prompts.map((p) => p.toJson()).toList()},
      ));
      break;
      
    case 'getPrompt':
      final name = request.params['name'] as String;
      final args = request.params['arguments'] as Map<String, dynamic>;
      
      try {
        final result = getPrompt(name, args);
        sendResponse(McpResponse(
          id: request.id,
          result: result.toJson(),
        ));
      } catch (e) {
        sendErrorResponse(request.id, e);
      }
      break;
      
    // Handle other methods...
  }
}
```

## Best Practices for Prompt Implementation

### Variable Substitution

Implement a robust variable substitution system for your prompts:

```dart
String substituteVariables(String template, Map<String, dynamic> variables) {
  return template.replaceAllMapped(
    RegExp(r'\{\{([^}]+)\}\}'),
    (match) {
      final variableName = match.group(1)!.trim();
      return variables.containsKey(variableName)
          ? variables[variableName].toString()
          : match.group(0)!;
    },
  );
}

Message createMessageWithVariables(
  MessageRole role,
  String template,
  Map<String, dynamic> variables,
) {
  return Message(
    role: role,
    content: MessageContent(
      type: ContentType.text,
      text: substituteVariables(template, variables),
    ),
  );
}
```

### Template Rendering

For more complex templates, consider using a template engine:

```dart
String renderTemplate(String template, Map<String, dynamic> context) {
  // This is a simple example; in a real application,
  // you might use a more sophisticated template engine
  
  // Replace variables
  String result = substituteVariables(template, context);
  
  // Handle conditionals
  result = result.replaceAllMapped(
    RegExp(r'\{\% if ([^%]+) \%\}(.*?)\{\% endif \%\}', dotAll: true),
    (match) {
      final condition = match.group(1)!.trim();
      final content = match.group(2)!;
      
      // Simple condition evaluation
      bool conditionMet = false;
      if (condition.contains('==')) {
        final parts = condition.split('==').map((p) => p.trim()).toList();
        final left = context[parts[0]] ?? parts[0];
        final right = context[parts[1]] ?? parts[1];
        conditionMet = left == right;
      } else {
        conditionMet = context.containsKey(condition) && 
                      (context[condition] == true || 
                       context[condition] is String && context[condition].isNotEmpty);
      }
      
      return conditionMet ? content : '';
    },
  );
  
  // Handle loops
  result = result.replaceAllMapped(
    RegExp(r'\{\% for ([^%]+) in ([^%]+) \%\}(.*?)\{\% endfor \%\}', dotAll: true),
    (match) {
      final itemName = match.group(1)!.trim();
      final listName = match.group(2)!.trim();
      final content = match.group(3)!;
      
      if (!context.containsKey(listName) || !(context[listName] is List)) {
        return '';
      }
      
      final list = context[listName] as List;
      return list.map((item) {
        final itemContext = Map<String, dynamic>.from(context);
        itemContext[itemName] = item;
        return substituteVariables(content, itemContext);
      }).join('');
    },
  );
  
  return result;
}
```

### Message Formatting

Format messages appropriately for different AI models:

```dart
List<Message> formatMessagesForModel(
  List<Message> messages,
  String modelType,
) {
  switch (modelType) {
    case 'claude':
      // Claude expects a specific format
      return messages.map((message) {
        if (message.role == MessageRole.system) {
          // Convert system message to a human message with special format
          return Message(
            role: MessageRole.user,
            content: MessageContent(
              type: ContentType.text,
              text: '<system>\n${message.content.text}\n</system>',
            ),
          );
        }
        return message;
      }).toList();
      
    case 'gpt':
      // GPT can handle system messages directly
      return messages;
      
    default:
      // Default format
      return messages;
  }
}
```

### Error Handling

Implement proper error handling for prompt operations:

```dart
GetPromptResult getPromptSafely(
  String name,
  Map<String, dynamic> args,
  List<dynamic> providers,
) {
  try {
    // Find the provider
    final provider = providers.firstWhere(
      (p) => p.getPromptInfo().name == name,
      orElse: () => throw McpError(
        code: McpErrorCodes.promptNotFound,
        message: 'Prompt not found: $name',
      ),
    );
    
    // Validate arguments
    final promptInfo = provider.getPromptInfo();
    for (final arg in promptInfo.arguments) {
      if (arg.required && !args.containsKey(arg.name)) {
        throw McpError(
          code: McpErrorCodes.invalidParams,
          message: 'Missing required argument: ${arg.name}',
        );
      }
    }
    
    // Get the prompt
    return provider.getPrompt(args);
  } catch (e) {
    if (e is McpError) {
      rethrow;
    }
    
    throw McpError(
      code: McpErrorCodes.internalError,
      message: 'Failed to get prompt: $e',
    );
  }
}
```

## Conclusion

In this tutorial, you learned how to:
- List and get prompts as an MCP client
- Implement prompt providers in an MCP server
- Perform variable substitution in templates
- Format messages for different AI models
- Handle prompt-related errors

Prompts are a powerful way to structure interactions with language models through the MCP protocol.
