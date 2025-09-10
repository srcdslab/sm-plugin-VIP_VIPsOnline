# Copilot Instructions for VIP_VIPsOnline Plugin

## Repository Overview
This repository contains a SourcePawn plugin for SourceMod that provides VIP player listing functionality. The plugin allows players to view a list of currently online VIP players along with their group information and VIP status expiration times.

**Plugin Name**: VIP_VIPsOnline  
**Version**: 1.0.2  
**Author**: R1KO  
**Dependencies**: SourceMod 1.11+, VIP Core plugin  

## Technical Environment
- **Language**: SourcePawn
- **Platform**: SourceMod 1.11+ (currently uses 1.11.0-git6917)
- **Build System**: SourceKnight (modern build tool for SourceMod plugins)
- **Compiler**: SourcePawn compiler (spcomp) via SourceKnight
- **CI/CD**: GitHub Actions with automated building and releases

## Project Structure
```
addons/sourcemod/
├── scripting/
│   └── VIP_VIPsOnline.sp          # Main plugin source code
├── translations/
│   └── vip_online.phrases.txt     # Multi-language translations
└── plugins/                       # Output directory for compiled .smx files
```

**Key Files**:
- `sourceknight.yaml` - Build configuration and dependencies
- `.github/workflows/ci.yml` - CI/CD pipeline configuration
- `addons/sourcemod/scripting/VIP_VIPsOnline.sp` - Main plugin implementation

## Build & Development Process

### Building the Plugin
```bash
# Install SourceKnight if not available
pip install sourceknight

# Build the plugin
sourceknight build
```

The build system automatically:
- Downloads and sets up SourceMod 1.11.0-git6917
- Downloads VIP Core dependency from GitHub
- Compiles the plugin to `.smx` format
- Outputs compiled plugin to `addons/sourcemod/plugins/`

### Testing
- Deploy to a test SourceMod server with VIP Core installed
- Test commands: `sm_viplist`, `sm_vips`, `sm_випс`
- Verify multi-language support with different client languages
- Test with various VIP configurations (temporary, permanent, different groups)

## Code Style & Standards

### Naming Conventions
- **Global variables**: Prefix with `g_` and use PascalCase (e.g., `g_bShowGroup`)
- **Functions**: PascalCase (e.g., `VIPList_CMD`, `Handler_VIPListMenu`)
- **Local variables**: camelCase (e.g., `iClient`, `sBuffer`)
- **ConVars**: snake_case for cvar names (e.g., `vip_vo_show_group`)

### Code Requirements
- Use `#pragma semicolon 1` and `#pragma newdecls required`
- Indentation: tabs (4 spaces)
- Delete trailing spaces
- Use descriptive variable and function names

### Memory Management
- **IMPORTANT**: Use `delete hMenu` instead of `CloseHandle(hMenu)`
- Use `delete` directly without null checks (SourceMod handles null automatically)
- For StringMap/ArrayList: Use `delete` instead of `.Clear()` to prevent memory leaks
- Create new instances after deletion when needed

### Error Handling & Best Practices
- Always validate client indices with `IsClientInGame()`
- Use `GetClientUserId()` for menu callbacks to handle client disconnections
- Implement proper error handling for all API calls
- Use translation files for all user-facing messages
- Load translations in `OnPluginStart()`: `LoadTranslations("vip_online.phrases")`

## Plugin-Specific Implementation Details

### Core Functionality
1. **Commands**: Registers console commands for VIP list display
2. **Menu System**: Creates interactive menus showing online VIP players
3. **Configuration**: ConVars for toggling group/expiration display
4. **Internationalization**: Multi-language support via translation files

### Key Functions
- `VIPList_CMD()` - Main command handler for VIP list display
- `Handler_VIPListMenu()` - Menu selection handler
- `Handler_InfoMenu()` - Info panel handler for VIP details

### ConVar Configuration
- `vip_vo_show_group` - Toggle VIP group display (default: 1)
- `vip_vo_show_expired` - Toggle expiration time display (default: 1)
- Configuration file: `cfg/sourcemod/vip/vips_online.cfg`

### VIP Core Integration
This plugin depends on VIP Core functionality:
- `VIP_IsClientVIP(client)` - Check if client has VIP status
- `VIP_GetClientVIPGroup(client, buffer, size)` - Get client's VIP group
- `VIP_GetClientAccessTime(client)` - Get VIP expiration timestamp
- `VIP_GetTimeFromStamp()` - Format time remaining

## Translation System
- File: `addons/sourcemod/translations/vip_online.phrases.txt`
- Supports 25+ languages including English, Russian, German, French, etc.
- Key phrases: "VIP_PLAYERS_ONLINE", "EXPIRES", "PANEL_BACK", "PANEL_CLOSE"
- Always use `%T` formatting for translated strings in code

## Common Development Tasks

### Adding New Features
1. Follow existing code patterns in `VIP_VIPsOnline.sp`
2. Add new translation phrases to `vip_online.phrases.txt`
3. Test with multiple languages
4. Update ConVar descriptions if adding configuration options

### Modifying Menu Behavior
- Menu items use `GetClientUserId()` for reliable client tracking
- Panel navigation uses keys 8 (back) and 10 (close/exit)
- Always handle `MenuAction_End` to prevent memory leaks

### Version Updates
- Update version in plugin info block
- Follow semantic versioning (MAJOR.MINOR.PATCH)
- Update changelog in plugin header comments

## Dependencies & External APIs
- **SourceMod**: Core modding framework (1.11+ required)
- **VIP Core**: Required dependency for VIP functionality
  - Repository: https://github.com/srcdslab/sm-plugin-VIP-Core
  - Automatically managed via SourceKnight build system

## Performance Considerations
- Minimize operations in frequently called functions
- Cache ConVar values in global variables with change hooks
- Use efficient client iteration patterns (for loop through MaxClients)
- Avoid unnecessary string operations in loops

## Debugging & Troubleshooting
- Enable SourceMod developer mode: `sm_developer 1`
- Check SourceMod logs: `logs/sourcemod/errors_*.log`
- Verify VIP Core is loaded and functioning
- Test translation loading with `sm_reload_translations`

## Release Process
- Automated via GitHub Actions on push/tag
- Creates release artifacts with compiled plugin and translations
- Supports both tagged releases and latest builds from main branch
- Package includes proper directory structure for SourceMod installation