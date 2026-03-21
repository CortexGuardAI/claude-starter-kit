# MCP Server Configurations

This folder contains pre-configured Model Context Protocol (MCP) servers that you can use to give Claude Code live access to external tools and data.

## What is MCP?
The Model Context Protocol allows Claude Code to securely connect with local and remote resources. By enabling these servers, Claude can:
* Read and create GitHub PRs
* Browse the web and run E2E browser tests via Playwright
* Look up live, up-to-date documentation via Context7

## How to Install

MCP Servers are configured globally in your user directory, **not** inside your project folder. 

1. Open your global Claude configuration file:
   - Mac/Linux: `~/.claude.json`
   - Windows: `%APPDATA%\Claude\claude.json` (or similar depending on installation)
   
   *Tip: You can quickly open this in VS Code by running `code ~/.claude.json` in your terminal.*

2. Copy the contents of the `mcp-servers.json` file in this directory and paste them into the `"mcpServers"` object inside your `~/.claude.json`.

3. Update the Environment Variables:
   - For GitHub, replace `"YOUR_GITHUB_PAT_HERE"` with a valid Personal Access Token.
   - Some servers (like Context7 and Playwright) do not require environment variables and work out of the box using `npx`.

## Included Servers

### 1. Context7 (`@upstash/context7-mcp`)
**Why use it?** Claude gets cut off from recent internet knowledge based on its training date. Context7 gives Claude live access to the absolute latest framework documentation.
**How to test it:** Run `/docs "Next.js" "How do I configure routing?"` in Claude Code.

### 2. Playwright (`@playwright/mcp`)
**Why use it?** Allows Claude to literally open a Chrome browser (headless or visible), navigate to URLs, click buttons, and read the DOM.
**How to test it:** Start your local dev server and ask Claude: `"Use playwright to navigate to http://localhost:3000 and tell me if the login button is visible."`

### 3. GitHub (`@modelcontextprotocol/server-github`)
**Why use it?** Claude can search across your organization's repositories, read existing issues to gather context for a feature, or create PRs automatically.
**How to test it:** Ask Claude: `"Search GitHub for issues mentioning 'login bug' in the current codebase."`

## Need more?
You can find many more official and community MCP servers at the [MCP Integrations page](https://github.com/modelcontextprotocol/servers).
