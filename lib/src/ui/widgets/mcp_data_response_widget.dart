/// MCP Data Response Widget
///
/// This file defines a widget for displaying structured data MCP responses.
/// It handles JSON, tables, and other structured data formats.
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/models.dart';
import '../themes/mcp_theme.dart';
import 'mcp_response_widget.dart';

/// Widget for displaying structured data MCP responses
///
/// This widget displays structured data MCP responses with proper formatting
/// and interactive elements. It supports JSON, tables, and other structured
/// data formats.
class McpDataResponseWidget extends McpResponseWidget {
  /// The data to display
  final Map<String, dynamic> data;

  /// Whether to enable data exploration
  final bool enableExploration;

  /// Whether to show a copy button
  final bool showCopyButton;

  /// Whether to initially expand all nodes
  final bool initiallyExpanded;

  /// Create a new MCP data response widget
  const McpDataResponseWidget({
    super.key,
    required super.response,
    required super.theme,
    required this.data,
    this.enableExploration = true,
    this.showCopyButton = true,
    this.initiallyExpanded = false,
    super.onInteraction,
  });

  /// Create a widget from an MCP response
  ///
  /// This factory method creates a data response widget from an MCP response.
  /// It extracts the data from the response result and creates a widget
  /// with the appropriate properties.
  factory McpDataResponseWidget.fromResponse({
    Key? key,
    required McpResponse response,
    required McpTheme theme,
    required String dataKey,
    bool enableExploration = true,
    bool showCopyButton = true,
    bool initiallyExpanded = false,
    McpInteractionCallback? onInteraction,
  }) {
    // Extract the data from the response result
    final responseData = response.result?[dataKey];
    final data =
        responseData is Map<String, dynamic>
            ? responseData
            : <String, dynamic>{};

    return McpDataResponseWidget(
      key: key,
      response: response,
      theme: theme,
      data: data,
      enableExploration: enableExploration,
      showCopyButton: showCopyButton,
      initiallyExpanded: initiallyExpanded,
      onInteraction: onInteraction,
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showCopyButton) _buildCopyButton(context),
        const SizedBox(height: 8),
        _buildDataContent(context),
      ],
    );
  }

  @override
  String getResponseType() {
    return 'Data Response';
  }

  /// Build the copy button
  Widget _buildCopyButton(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
        icon: const Icon(Icons.copy),
        tooltip: 'Copy to clipboard',
        onPressed: () {
          final jsonString = const JsonEncoder.withIndent('  ').convert(data);
          Clipboard.setData(ClipboardData(text: jsonString));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Copied to clipboard'),
              duration: Duration(seconds: 2),
            ),
          );
          triggerInteraction('copy', {'data': data});
        },
      ),
    );
  }

  /// Build the data content
  Widget _buildDataContent(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: theme.bodyTextStyle.copyWith(
            color: theme.secondaryTextColor,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    if (enableExploration) {
      return _buildJsonTree(context, data);
    } else {
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.codeBackgroundColor,
          borderRadius: BorderRadius.circular(theme.borderRadius / 2),
        ),
        child: SelectableText(
          jsonString,
          style: theme.codeTextStyle.copyWith(color: theme.codeTextColor),
        ),
      );
    }
  }

  /// Build a JSON tree for interactive data exploration
  Widget _buildJsonTree(BuildContext context, Map<String, dynamic> json) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(theme.borderRadius / 2),
        border: Border.all(
          color: theme.borderColor.withAlpha(128),
        ), // 0.5 opacity
      ),
      child: _JsonTreeView(
        data: json,
        theme: theme,
        initiallyExpanded: initiallyExpanded,
      ),
    );
  }
}

/// A tree view for JSON data
class _JsonTreeView extends StatefulWidget {
  final Map<String, dynamic> data;
  final McpTheme theme;
  final bool initiallyExpanded;

  const _JsonTreeView({
    required this.data,
    required this.theme,
    this.initiallyExpanded = false,
  });

  @override
  State<_JsonTreeView> createState() => _JsonTreeViewState();
}

class _JsonTreeViewState extends State<_JsonTreeView> {
  late Map<String, bool> _expandedState;

  @override
  void initState() {
    super.initState();
    _expandedState = {};
    // Initialize expanded state
    for (final key in widget.data.keys) {
      _expandedState[key] = widget.initiallyExpanded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          widget.data.entries.map((entry) {
            return _buildJsonNode(entry.key, entry.value);
          }).toList(),
    );
  }

  Widget _buildJsonNode(String key, dynamic value) {
    final isExpandable = value is Map || value is List;
    final isExpanded = _expandedState[key] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap:
              isExpandable
                  ? () {
                    setState(() {
                      _expandedState[key] = !isExpanded;
                    });
                  }
                  : null,
          child: Row(
            children: [
              if (isExpandable)
                Icon(
                  isExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
                  size: 20,
                  color: widget.theme.primaryColor,
                ),
              Text(
                key,
                style: widget.theme.bodyTextStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.theme.primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              if (!isExpandable || !isExpanded)
                Expanded(
                  child: Text(
                    _getValuePreview(value),
                    style: widget.theme.bodyTextStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
        if (isExpandable && isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child:
                value is Map
                    ? _buildMapContent(value)
                    : _buildListContent(value),
          ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildMapContent(Map<dynamic, dynamic> map) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          map.entries.map((entry) {
            final key = entry.key.toString();
            return _buildJsonNode(key, entry.value);
          }).toList(),
    );
  }

  Widget _buildListContent(List<dynamic> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          list.asMap().entries.map((entry) {
            final index = entry.key;
            final value = entry.value;
            return _buildJsonNode('[$index]', value);
          }).toList(),
    );
  }

  String _getValuePreview(dynamic value) {
    if (value == null) {
      return 'null';
    } else if (value is String) {
      return '"$value"';
    } else if (value is Map) {
      return '{...}';
    } else if (value is List) {
      return '[...]';
    } else {
      return value.toString();
    }
  }
}
