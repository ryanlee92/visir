# AI Agent Implementation Documentation

## Overview

The AI Agent is a conversational interface that allows users to interact with the application using natural language. It can understand user intent, execute application functions (MCP functions), and provide intelligent responses. The agent supports various actions including task creation, event scheduling, mail operations, chat interactions, and more.

## Architecture

### Core Components

1. **AgentActionController** (`lib/features/inbox/application/agent_action_controller.dart`)
   - Main controller managing the AI agent's state and conversation flow
   - Handles message processing, function call execution, and user confirmations
   - Manages conversation history and session state

2. **McpFunctionExecutor** (`lib/features/inbox/application/mcp_function_executor.dart`)
   - Parses function calls from AI responses
   - Executes MCP (Model Context Protocol) functions
   - Handles 83+ different function types (tasks, events, mail, chat, projects, etc.)

3. **McpFunctionRegistry** (`lib/features/inbox/domain/entities/mcp_function_schema.dart`)
   - Defines schemas for all available MCP functions
   - Provides function descriptions and parameter definitions for AI models

4. **AgentActionMessagesWidget** (`lib/features/inbox/presentation/widgets/agent_action_messages_widget.dart`)
   - UI component for displaying conversation messages
   - Renders entity widgets (tasks, events, mail, etc.) from AI responses
   - Handles confirmation UI for write actions

## Execution Flow

### 1. User Message Processing

```
User sends message
    ↓
sendMessage() called
    ↓
Message added to state.messages
    ↓
_generateGeneralChat() called
    ↓
AI API called with:
  - User message
  - Conversation history
  - Context (projects, tasks, events, inboxes, channels)
  - System prompt with function schemas
    ↓
AI Response received
```

### 2. Function Call Detection and Parsing

```
AI Response contains function calls
    ↓
parseFunctionCalls() extracts:
  - Function name
  - Function arguments
  - can_parallelize flag
  - depends_on dependencies
    ↓
Function calls grouped by dependencies
    ↓
For each group:
  - If can_parallelize: Execute in parallel
  - If depends_on: Execute sequentially
```

### 3. Function Execution Decision

For each function call:

```
Check if function requires confirmation:
  - Write actions (create, update, delete, send): YES
  - Read actions (search, list, get): NO
    ↓
If requires confirmation:
  - Add to pendingFunctionCalls
  - Generate action_id (UUID)
  - Store message_index (which message generated this action)
  - Return null (don't execute yet)
    ↓
If no confirmation needed:
  - Execute immediately
  - Return result
```

### 4. Confirmation Flow

```
User sees pending actions in UI
    ↓
User clicks "Confirm" button
    ↓
confirmActions() called with actionIds
    ↓
Deduplicate callsToExecute:
  - Remove duplicates by action_id
  - Remove duplicates by function signature
    ↓
For each call:
  - Execute function
  - Track success/failure
    ↓
Generate summary message via AI
    ↓
Update state:
  - Remove executed actions from pendingFunctionCalls
  - Add result message to conversation
  - Set isLoading: false
```

## Detailed Execution Logic

### Function Call Parsing

The AI can return function calls in multiple formats:

1. **Array Format**: `[{"function": "createTask", "arguments": {...}}, ...]`
2. **XML Tags**: `<function_call>...</function_call>`
3. **JSON Blocks**: Multiple JSON objects in the response

`parseFunctionCalls()` handles all these formats and extracts:
- `function`: Function name
- `arguments`: Function parameters
- `can_parallelize`: Whether this can run in parallel (default: true for search functions)
- `depends_on`: List of function indices this depends on

### Dependency Grouping

Functions are grouped using `_groupFunctionCalls()`:

```dart
// Group 1: Independent functions (can run in parallel)
[searchInbox, searchTask] → Execute simultaneously

// Group 2: Dependent functions (must run sequentially)
[createTask] → Wait for Group 1
[updateTask] → Wait for createTask (depends_on: [0])
```

### Write Actions Requiring Confirmation

The following actions require user confirmation before execution:

- **Creation**: `createTask`, `createEvent`, `createProject`
- **Updates**: `updateTask`, `updateEvent`, `updateProject`
- **Deletion**: `deleteTask`, `deleteEvent`, `deleteMail`, `deleteMessage`
- **Sending**: `sendMail`, `replyMail`, `forwardMail`, `sendMessage`, `replyMessage`
- **State Changes**: `markMailAsRead`, `archiveMail`, `pinMail`, etc.

### Duplicate Detection

Duplicates are detected at two levels:

1. **UI Level** (`agent_action_messages_widget.dart`):
   - By `action_id`: Each action has a unique UUID
   - By `function signature`: `functionName|title|startAt|endAt` for tasks/events

2. **Execution Level** (`confirmActions`):
   - Same deduplication logic applied before execution
   - Ensures UI display matches actual execution count

### Message Index Tracking

Each pending function call stores `message_index`:
- Indicates which assistant message generated this action
- Used to display entity widgets with the correct message
- Prevents entity blocks from moving to the bottom after confirmation

## UI Rendering

### Entity Widgets

The AI can embed entities in responses using custom HTML tags:

- `<inapp_task>`: Task entity
- `<inapp_event>`: Event entity
- `<inapp_mail>`: Mail entity
- `<inapp_message>`: Chat message entity
- `<inapp_inbox>`: Inbox entity
- `<inapp_calendar>`: Calendar entity

These tags contain JSON data that is parsed and rendered as Flutter widgets.

### Confirmation Button

- Appears only on the **last message** that has pending write actions
- Disappears when `isLoading: true` (during execution)
- Disappears after confirmation (when `pendingFunctionCalls` is empty)
- Positioned at the right end of the message

### Markdown and HTML Rendering

The widget handles mixed content:
1. Extract entity tags from content
2. Convert Markdown to HTML
3. Replace entity tag placeholders with rendered widgets
4. Render final HTML with embedded widgets

## State Management

### AgentActionState

```dart
class AgentActionState {
  final List<AgentActionMessage> messages;           // Conversation history
  final bool isLoading;                              // Loading indicator
  final List<Map<String, dynamic>>? pendingFunctionCalls; // Actions awaiting confirmation
  final Set<int> loadedInboxNumbers;                 // Fully loaded inbox items
  final String? sessionId;                           // Chat session ID
  final String? conversationSummary;                  // Conversation title
}
```

### Pending Function Call Structure

```dart
{
  'action_id': String,              // Unique UUID
  'function_name': String,          // e.g., 'createTask'
  'function_args': Map,            // Function parameters
  'message_index': int,            // Which message generated this
  'updated_tagged_tasks': List,    // Context data
  'updated_tagged_events': List,
  'tagged_connections': List,
  'updated_available_inboxes': List,
  'remaining_credits': double,
}
```

## AI System Prompts

The system prompts include:

1. **Function Schemas**: All 83+ MCP functions with parameters
2. **Entity Schemas**: TaskEntity and EventEntity field definitions
3. **Output Format**: Instructions for using `inapp_xxx` tags
4. **Date Parsing**: Prioritize dates from inbox body over current date
5. **Multiple Deadlines**: Create separate tasks for each deadline

## Error Handling

1. **Function Execution Errors**: Caught and added to `errorMessages`
2. **AI API Errors**: Displayed as error message in conversation
3. **Parsing Errors**: Ignored, continue with remaining functions
4. **Credit Insufficient**: Special handling to prompt user

## Key Features

### 1. Parallel Execution

Functions with `can_parallelize: true` execute simultaneously:
- Search functions (`searchInbox`, `searchTask`, `searchCalendarEvent`)
- Read-only operations

### 2. Sequential Execution

Functions with dependencies execute in order:
- `createTask` → `updateTask` (if update depends on create)
- `searchInbox` → `createTask` (if task creation depends on search results)

### 3. Context Awareness

The AI receives:
- **Project Context**: Tagged projects and their details
- **Task/Event Context**: Tagged tasks and events
- **Inbox Context**: Relevant inbox items (summary or full content)
- **Channel Context**: Recent messages from tagged channels
- **Connection Context**: Tagged connections

### 4. Automatic Inbox Loading

For `createTask` and `createEvent` actions:
- If inbox numbers are provided, automatically load full content
- Add to `loadedInboxNumbers` set
- Pass full content to AI for better date parsing

### 5. Conversation History

- Messages encrypted before storage
- Session-based grouping
- Title auto-generation from first message or action type

## Example Execution Flow

### Scenario: User wants to create a task from an inbox item

```
1. User: "Create a task for this email"
   ↓
2. AI receives:
   - User message
   - Inbox context (email content)
   - Function schemas
   ↓
3. AI responds:
   - Message: "A new task has been prepared..."
   - Function call: createTask({title: "...", startAt: "...", ...})
   ↓
4. System detects: createTask requires confirmation
   ↓
5. Action added to pendingFunctionCalls:
   {
     action_id: "uuid-123",
     function_name: "createTask",
     function_args: {...},
     message_index: 1
   }
   ↓
6. UI displays:
   - AI message
   - Task entity widget (with task details)
   - Confirm button
   ↓
7. User clicks "Confirm"
   ↓
8. confirmActions() called:
   - Deduplicate (if needed)
   - Execute createTask
   - Track result
   ↓
9. AI generates summary:
   "Done - I created 1 new task successfully."
   ↓
10. State updated:
    - pendingFunctionCalls: [] (empty)
    - messages: [...previous, resultMessage]
    - isLoading: false
   ↓
11. UI updates:
    - Confirm button disappears
    - Result message displayed
    - Task entity widget remains visible
```

## Testing

Automated tests cover:
- Function call parsing
- Entity tag parsing
- Markdown rendering
- Parallel execution logic
- Batch confirmation
- Integration tests for end-to-end flows

## Future Improvements

1. **Streaming Responses**: Support for streaming AI responses
2. **Function Result Caching**: Cache search results to avoid redundant calls
3. **Smart Retry**: Automatic retry for failed function calls
4. **Batch Operations**: Support for batch operations (e.g., create multiple tasks)
5. **Undo/Redo**: Support for undoing executed actions




