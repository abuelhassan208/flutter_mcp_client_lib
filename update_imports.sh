#!/bin/bash

# Script to update imports from flutter_mcp to flutter_mcp_client_lib

# Find all Dart files in the test directory
find test -name "*.dart" -type f | while read -r file; do
  echo "Updating imports in $file"
  # Replace imports
  sed -i '' 's/package:flutter_mcp\//package:flutter_mcp_client_lib\//g' "$file"
done

# Also update the old library file to re-export the new one for backward compatibility
echo "/// Re-export the new library for backward compatibility
///
/// This file is kept for backward compatibility with existing code.
/// New code should import flutter_mcp_client_lib.dart directly.
library flutter_mcp;

export 'flutter_mcp_client_lib.dart';" > lib/flutter_mcp.dart

echo "Import updates completed!"
