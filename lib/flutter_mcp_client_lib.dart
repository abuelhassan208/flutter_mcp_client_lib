/// Flutter MCP Client Library
///
/// A Flutter implementation of the Model Context Protocol (MCP) for integrating
/// with AI tools like Windsurf, Cursor, and Claude.
library;

export 'src/client/client.dart';
export 'src/models/models.dart';
export 'src/transports/transports.dart';
export 'src/utils/utils.dart';

// UI Components
export 'src/ui/themes/mcp_theme.dart';
export 'src/ui/widgets/mcp_response_widget.dart';
export 'src/ui/widgets/mcp_text_response_widget.dart';
export 'src/ui/widgets/mcp_code_response_widget.dart';
export 'src/ui/widgets/mcp_data_response_widget.dart';
export 'src/ui/widgets/mcp_error_response_widget.dart';
export 'src/ui/renderers/mcp_response_renderer.dart';
export 'src/ui/extensions/mcp_client_ui_extensions.dart';
