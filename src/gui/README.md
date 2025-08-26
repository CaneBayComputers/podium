# 🎭 Podium GUI

Professional desktop application for the Podium PHP Development Platform.

## Overview

Podium GUI is an Electron-based desktop application that provides a beautiful, intuitive interface for managing your Podium development environment. It transforms the powerful Podium CLI into a user-friendly visual experience.

## Features

- **📊 Project Dashboard** - Visual overview of all your projects
- **🚀 One-Click Project Creation** - Laravel and WordPress projects
- **⚡ Service Management** - Start/stop projects and services
- **🌐 Easy Access** - Local and LAN URLs displayed prominently  
- **📱 Professional Presentation** - Perfect for client demos
- **🔄 Real-Time Status** - Live project health monitoring

## Requirements

- **Podium CLI** must be installed and accessible
- **Node.js** 16+ for development
- **Electron** for desktop app functionality

## Development Setup

```bash
# Install dependencies
npm install

# Run in development mode
npm run dev

# Build for production
npm run build
```

## Architecture

The GUI communicates with Podium CLI by:
- Executing Podium scripts via Node.js child processes
- Parsing script output to update the interface
- Providing visual feedback for all operations

## Relationship to Podium CLI

This GUI is a **visual wrapper** around the Podium CLI scripts. It:
- Calls the same `./scripts/new_project.sh`, `./scripts/startup.sh`, etc.
- Parses the output to provide visual feedback
- Maintains all the power and reliability of the CLI
- Adds professional presentation and ease of use

## Target Users

- **Agencies** - Professional client presentations
- **Teams** - Visual project management  
- **Beginners** - GUI makes Docker approachable
- **Stakeholders** - Non-technical users can see project status

---

*Podium GUI: Where professional PHP development meets beautiful design.* ✨
