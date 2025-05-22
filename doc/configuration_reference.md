## Configuration Reference

### McpClient Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| name | String | required | The name of the client |
| version | String | required | The version of the client |
| capabilities | ClientCapabilities | required | The capabilities of the client |
| timeout | Duration | 30 seconds | The timeout for requests |

### ClientCapabilities Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| sampling | SamplingCapabilityConfig | null | Configuration for sampling capabilities |
| resources | ResourceCapabilityConfig | null | Configuration for resource capabilities |
| tools | ToolCapabilityConfig | null | Configuration for tool capabilities |
| prompts | PromptCapabilityConfig | null | Configuration for prompt capabilities |

### SamplingCapabilityConfig

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| sample | bool | false | Whether the client can handle sample requests |

### ResourceCapabilityConfig

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| list | bool | false | Whether the client can list resources |
| read | bool | false | Whether the client can read resources |

### ToolCapabilityConfig

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| list | bool | false | Whether the client can list tools |
| call | bool | false | Whether the client can call tools |

### PromptCapabilityConfig

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| list | bool | false | Whether the client can list prompts |
| get | bool | false | Whether the client can get prompts |
