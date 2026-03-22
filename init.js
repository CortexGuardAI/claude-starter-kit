#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const targetDir = process.cwd();
const sourceDir = __dirname;
const claudeDir = path.join(targetDir, '.claude');

console.log("🚀 Initializing Claude Code Starter Kit...\n");

// Ensure .claude directory exists
if (!fs.existsSync(claudeDir)) {
    fs.mkdirSync(claudeDir, { recursive: true });
}

// Folders to copy into .claude/
const foldersToCopy = ['agents', 'commands', 'skills', 'mcp-configs'];

for (const folder of foldersToCopy) {
    const src = path.join(sourceDir, folder);
    const dest = path.join(claudeDir, folder);
    
    if (fs.existsSync(src)) {
        console.log(`📦 Copying ${folder}...`);
        fs.cpSync(src, dest, { recursive: true });
    }
}

// Copy hooks documentation folder
const hooksSrcDir = path.join(sourceDir, 'hooks');
if (fs.existsSync(hooksSrcDir)) {
    fs.cpSync(hooksSrcDir, path.join(claudeDir, 'hooks'), { recursive: true });
}

// Safely merge hooks into .claude/settings.json
const hooksJsonPath = path.join(sourceDir, 'hooks', 'hooks.json');
const settingsJsonPath = path.join(claudeDir, 'settings.json');

if (fs.existsSync(hooksJsonPath)) {
    console.log(`🔨 Safely merging hooks into .claude/settings.json...`);
    const starterHooksData = JSON.parse(fs.readFileSync(hooksJsonPath, 'utf8'));
    const starterHooks = starterHooksData.hooks || starterHooksData.customHooks || {};
    
    let settings = {};
    if (fs.existsSync(settingsJsonPath)) {
        try {
            settings = JSON.parse(fs.readFileSync(settingsJsonPath, 'utf8'));
        } catch (e) {
            console.warn(`⚠️  Warning: Could not parse existing settings.json. Hooks integration skipped.`);
            settings = null;
        }
    }
    
    if (settings) {
        if (!settings.hooks) settings.hooks = {};
        
        // Deep merge PreToolUse, PostToolUse, Stop, etc.
        for (const [eventName, hookArray] of Object.entries(starterHooks)) {
            if (!settings.hooks[eventName]) {
                settings.hooks[eventName] = [];
            }
            
            // Append hooks that don't already exist (simple dedup by description)
            const existingDescriptions = settings.hooks[eventName].map(h => h.description);
            for (const newHook of hookArray) {
                if (!existingDescriptions.includes(newHook.description)) {
                    settings.hooks[eventName].push(newHook);
                }
            }
        }
        
        fs.writeFileSync(settingsJsonPath, JSON.stringify(settings, null, 2));
    }
}

// Copy CLAUDE.md to project root and safely replace mcp-configs path
const claudeMdSrc = path.join(sourceDir, 'CLAUDE.md');
const claudeMdDest = path.join(targetDir, 'CLAUDE.md');

if (fs.existsSync(claudeMdSrc)) {
    console.log(`📝 Copying CLAUDE.md...`);
    let content = fs.readFileSync(claudeMdSrc, 'utf8');
    // Update path for mcp-configs to point to .claude/mcp-configs
    content = content.replace(/mcp-configs\//g, '.claude/mcp-configs/');
    fs.writeFileSync(claudeMdDest, content);
}

// Automatically create local .claude.json to enable MCP servers
const mcpServersSrc = path.join(claudeDir, 'mcp-configs', 'mcp-servers.json');
const localClaudeJsonDest = path.join(targetDir, '.claude.json');

if (fs.existsSync(mcpServersSrc) && !fs.existsSync(localClaudeJsonDest)) {
    console.log(`⚙️  Configuring local .claude.json for MCP servers...`);
    fs.copyFileSync(mcpServersSrc, localClaudeJsonDest);
}

console.log("\n✅ Success! Claude Code Starter Kit applied to the project.");
console.log("\nInstalled components in .claude/:");
console.log("  - .claude/agents/        Specific workflow sub-agents");
console.log("  - .claude/commands/      Interactive slash commands");
console.log("  - .claude/skills/        Deep workflow knowledge bases");
console.log("  - .claude/hooks/         Hooks configuration");
console.log("  - .claude/mcp-configs/   MCP server configuration templates");
console.log("  - CLAUDE.md              Project-level instructions (in project root)");
console.log("  - .claude.json           Local MCP server definitions (ready to use)");
console.log("\nNext steps:");
console.log("1. Review and update CLAUDE.md to match your project instructions.");
console.log("2. Run 'claude' in this directory to start testing your new commands!");
