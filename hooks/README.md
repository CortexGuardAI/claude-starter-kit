# Hooks

Hooks are event-driven automations that fire before or after Claude Code tool executions. They enforce code quality, catch mistakes early, and automate repetitive checks.

## How Hooks Work

```
User request --> Claude picks a tool --> PreToolUse hook runs --> Tool executes --> PostToolUse hook runs
```

- **PreToolUse** hooks run before the tool executes. They can **block** (exit code 2) or **warn** (stderr without blocking).
- **PostToolUse** hooks run after the tool completes. They can analyze output but cannot block.
- **Stop** hooks run after each Claude response.
- **SessionStart/SessionEnd** hooks run at session lifecycle boundaries.

## Hooks in This Starter Kit

### PreToolUse Hooks

| Hook | Matcher | Behavior |
|------|---------|----------|
| **No-verify blocker** | `Bash` | Blocks `git --no-verify` to protect pre-commit hooks |
| **File size limit** | `Write` | Blocks creation of files > 800 lines |
| **TODO/FIXME warning** | `Edit` | Warns when adding TODO/FIXME/HACK comments |

### PostToolUse Hooks

| Hook | Matcher | What It Does |
|------|---------|-------------|
| **console.log warning** | `Edit` | Warns about console.log in edited code |
| **Test file reminder** | `Write` | Reminds to create tests for new source files |

### Lifecycle Hooks

| Hook | Event | What It Does |
|------|-------|-------------|
| **Console.log audit** | `Stop` | Checks all modified files for console.log |

## Writing Your Own Hook

Hooks are shell commands that receive tool input as JSON on stdin and must output JSON on stdout.

**Basic structure:**

```javascript
// my-hook.js
let data = '';
process.stdin.on('data', chunk => data += chunk);
process.stdin.on('end', () => {
  const input = JSON.parse(data);

  // Access tool info
  const toolName = input.tool_name;        // "Edit", "Bash", "Write", etc.
  const toolInput = input.tool_input;      // Tool-specific parameters
  const toolOutput = input.tool_output;    // Only available in PostToolUse

  // Warn (non-blocking): write to stderr
  console.error('[Hook] Warning message shown to Claude');

  // Block (PreToolUse only): exit with code 2
  // process.exit(2);

  // Always output the original data to stdout
  console.log(data);
});
```

**Exit codes:**
- `0` -- Success (continue execution)
- `2` -- Block the tool call (PreToolUse only)
- Other non-zero -- Error (logged but does not block)

## Hook Input Schema

```typescript
interface HookInput {
  tool_name: string;          // "Bash", "Edit", "Write", "Read", etc.
  tool_input: {
    command?: string;         // Bash: the command being run
    file_path?: string;       // Edit/Write/Read: target file
    old_string?: string;      // Edit: text being replaced
    new_string?: string;      // Edit: replacement text
    content?: string;         // Write: file content
  };
  tool_output?: {             // PostToolUse only
    output?: string;          // Command/tool output
  };
}
```

## Common Hook Recipes

### Auto-format Python files with ruff

```json
{
  "matcher": "Edit",
  "hooks": [{
    "type": "command",
    "command": "node -e \"let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{const i=JSON.parse(d);const p=i.tool_input?.file_path||'';if(/\\.py$/.test(p)){const{execFileSync}=require('child_process');try{execFileSync('ruff',['format',p],{stdio:'pipe'})}catch(e){}}console.log(d)})\""
  }],
  "description": "Auto-format Python files with ruff after edits"
}
```

### Block commits without tests

```json
{
  "matcher": "Bash",
  "hooks": [{
    "type": "command",
    "command": "node -e \"let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{const i=JSON.parse(d);const cmd=i.tool_input?.command||'';if(/git commit/.test(cmd)&&!/--amend/.test(cmd)){const{execSync}=require('child_process');try{const files=execSync('git diff --cached --name-only',{encoding:'utf8'});if(/src\\//.test(files)&&!/test|spec/.test(files)){console.error('[Hook] Warning: Committing source files without test files')}}catch(e){}}console.log(d)})\""
  }],
  "description": "Warn when committing source files without corresponding test files"
}
```

## Customizing

### Disabling a Hook

Remove or comment out the hook entry in `hooks.json`.

### Adding a Hook

Add a new entry to the appropriate event array (`PreToolUse`, `PostToolUse`, `Stop`, etc.) in `hooks.json`.

### Async Hooks

For hooks that should not block the main flow:

```json
{
  "type": "command",
  "command": "node my-slow-hook.js",
  "async": true,
  "timeout": 30
}
```
