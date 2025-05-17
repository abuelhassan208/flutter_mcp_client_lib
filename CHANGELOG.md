# Changelog

All notable changes to the Flutter MCP package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 1.0.1 (2023-05-17)

### Added
- Enhanced ClientCapabilities class with resources, tools, and prompts fields
- Updated documentation to match the current implementation
- Improved error handling in the client
- Added more comprehensive examples

### Fixed
- Fixed timeout issues in the client
- Resolved UI widget test failures
- Fixed error handling tests

## 1.0.0 (2023-05-13)

### Added
- Initial implementation of MCP client (#1)
- WebSocket transport layer (#2)
- HTTP transport layer (#3)
- JSON-RPC 2.0 message handling (#4)
- Type-safe models for MCP protocol (#5)
- Support for resources, tools, and prompts (#6)
- Comprehensive error handling (#7)
- Logging and debugging utilities (#8)
- Example client and server implementations (#9)
- Complete documentation and API reference (#10)

### Features
- **Client**: Full implementation of MCP client with capability negotiation
- **Server**: Support for implementing MCP servers
- **Resources**: Support for listing and reading resources
- **Tools**: Support for listing and calling tools
- **Prompts**: Support for listing and retrieving prompts
- **Transports**: WebSocket and HTTP transport implementations
- **Error Handling**: Comprehensive error handling and recovery strategies
- **Logging**: Detailed logging for debugging and monitoring

## 0.9.0 (2023-05-01)

### Added
- Beta release of MCP client implementation
- WebSocket transport implementation
- Basic resource, tool, and prompt support
- Example client application

### Changed
- Improved error handling and recovery
- Enhanced logging and debugging

### Fixed
- JSON serialization issues with nullable fields
- WebSocket connection handling edge cases
- Error propagation in async contexts

## 0.5.0 (2023-04-15)

### Added
- Alpha release of MCP client
- Initial WebSocket transport
- Basic JSON-RPC message handling
- Preliminary model classes

### Known Issues
- Limited error handling
- Incomplete protocol implementation
- No HTTP transport support
