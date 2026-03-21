---
description: Configure the GitHub MCP server with your Personal Access Token.
---

# /setup-github Command

## Purpose
Automatically configures the GitHub MCP server in your local `.claude.json` with your Personal Access Token (PAT).

## Usage
`/setup-github <YOUR_GITHUB_PAT>`

If the user does not provide a token in the command, reply by asking them to generate one at https://github.com/settings/tokens (it requires standard `repo` access) and to provide it.

## Execution Steps

When invoked with a token, you (Claude) must:
1. **Read**: Look for `.claude.json` in the root of the project.
2. **Verify**: Check if the `"github"` key exists under `"mcpServers"`.
3. **Edit**: Use your tools to safely replace `"YOUR_GITHUB_PAT_HERE"` (or the existing token) with the token provided by the user in the `"GITHUB_PERSONAL_ACCESS_TOKEN"` field.
4. **Report**: Tell the user that the configuration was updated and that the GitHub MCP server is now ready to use. 

### Error Handling
- If `.claude.json` is missing, advise the user that the starter kit has an `mcp-configs` setup that handles this, or just tell them to manually create the file.
- Do NOT output the user's PAT token in your text responses for security reasons. Confirm with a masked version like `ghp_***...`.
