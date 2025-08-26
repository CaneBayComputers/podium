const { app, BrowserWindow, ipcMain, dialog } = require('electron');
const path = require('path');
const { spawn } = require('child_process');
const fs = require('fs');
const os = require('os');

// Debug log file path
const debugLogPath = path.join(os.tmpdir(), 'podium-gui-debug.log');

// Debug logging function
function debugLog(message, data = null) {
  const timestamp = new Date().toISOString();
  const logEntry = `[${timestamp}] ${message}${data ? '\n' + JSON.stringify(data, null, 2) : ''}\n`;
  
  // Console log for immediate viewing
  console.log(message, data || '');
  
  // Only write to file if in debug mode (--dev flag)
  if (process.argv.includes('--dev')) {
    try {
      // Overwrite file each time (not append)
      if (!fs.existsSync(debugLogPath)) {
        fs.writeFileSync(debugLogPath, '=== PODIUM GUI DEBUG LOG ===\n');
      }
      fs.appendFileSync(debugLogPath, logEntry);
    } catch (error) {
      console.error('Failed to write debug log:', error);
    }
  }
}

let mainWindow;

function createWindow() {
  // Clear debug log at startup
  if (process.argv.includes('--dev')) {
    try {
      fs.writeFileSync(debugLogPath, '=== PODIUM GUI DEBUG LOG ===\n');
      debugLog('Debug logging initialized', { logPath: debugLogPath });
    } catch (error) {
      console.error('Failed to initialize debug log:', error);
    }
  }

  mainWindow = new BrowserWindow({
    width: 2000,
    height: 1200,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false
    },
    icon: path.join(__dirname, '../assets/icon.png'),
    title: 'Podium - PHP Development Platform'
  });

  // Check if Podium CLI is installed and configured
  const podiumStatus = checkPodiumStatus();
  debugLog('Podium status check result', { status: podiumStatus });
  
  if (podiumStatus === 'not-installed') {
    debugLog('Loading installer.html - Podium not installed');
    mainWindow.loadFile('src/installer.html');
  } else if (podiumStatus === 'not-configured') {
    debugLog('Loading installer.html - Podium not configured');
    mainWindow.loadFile('src/installer.html');
  } else {
    debugLog('Loading index.html - Podium ready');
    mainWindow.loadFile('src/index.html');
  }

  // Open DevTools in development
  if (process.argv.includes('--dev')) {
    mainWindow.webContents.openDevTools();
  }
}

function checkPodiumStatus() {
  try {
    // Check if podium command exists in PATH
    const { execSync } = require('child_process');
    execSync('podium help --no-coloring', { stdio: 'pipe' });
    
    // Podium CLI exists, now check if it's configured
    // Look for docker-stack/.env in common installation locations
    const possibleConfigPaths = [
      '/usr/local/share/podium-cli/docker-stack/.env',
      path.join(require('os').homedir(), 'cbc-development/docker-stack/.env'),
      path.join(require('os').homedir(), 'podium-cli/docker-stack/.env'),
      path.join(__dirname, '../../cbc-development/docker-stack/.env'),
      path.join(__dirname, '../../podium-cli/docker-stack/.env')
    ];
    
    for (const configPath of possibleConfigPaths) {
      if (fs.existsSync(configPath)) {
        return 'configured';
      }
    }
    
    return 'not-configured';
  } catch (error) {
    return 'not-installed';
  }
}

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});

// IPC handler for renderer console messages
ipcMain.handle('renderer-log', async (event, ...args) => {
  console.log('🔥 RENDERER LOG:', ...args);
  debugLog('RENDERER LOG', args);
});

// IPC handlers for communicating with Podium CLI
ipcMain.handle('execute-podium-script', async (event, scriptName, args = []) => {
  return new Promise((resolve, reject) => {
    // Find podium-cli directory
    const podiumStatus = checkPodiumStatus();
    const podiumCliPath = podiumStatus === 'configured' ? '/usr/local/share/podium-cli' : null;
    if (!podiumCliPath) {
      reject(new Error('Podium CLI not found'));
      return;
    }
    
    const scriptPath = path.join(podiumCliPath, 'scripts', scriptName);
    
    const childProcess = spawn('bash', [scriptPath, ...args], {
      cwd: podiumCliPath,
      stdio: ['pipe', 'pipe', 'pipe'],
      env: { ...process.env, NO_COLOR: '1' }
    });

    let stdout = '';
    let stderr = '';

    childProcess.stdout.on('data', (data) => {
      stdout += data.toString();
    });

    childProcess.stderr.on('data', (data) => {
      stderr += data.toString();
    });

    childProcess.on('close', (code) => {
      resolve({
        code,
        stdout,
        stderr
      });
    });

    childProcess.on('error', (error) => {
      reject(error);
    });
  });
});

// New handler for podium command
ipcMain.handle('execute-podium', async (event, subcommand, args = []) => {
  return new Promise((resolve, reject) => {
    // Try to use global podium command first, then fallback to local
    const allArgs = [subcommand, ...args, '--json-output'];
    
    // Try global podium command first
    let childProcess = spawn('podium', allArgs, {
      cwd: os.homedir(), // Run from user's home directory
      stdio: ['pipe', 'pipe', 'pipe'],
      env: { ...process.env, NO_COLOR: '1' }
    });

    // If global command fails, try local podium script
    childProcess.on('error', (error) => {
      const podiumStatus = checkPodiumStatus();
      const podiumCliPath = podiumStatus === 'configured' ? '/usr/local/share/podium-cli' : null;
      if (!podiumCliPath) {
        reject(new Error('Podium CLI not found'));
        return;
      }
      
      const podiumPath = path.join(podiumCliPath, 'podium');
      childProcess = spawn('bash', [podiumPath, ...allArgs], {
        cwd: os.homedir(), // Run from user's home directory, not CLI directory
        stdio: ['pipe', 'pipe', 'pipe'],
        env: { ...process.env, NO_COLOR: '1' }
      });
    });

    let stdout = '';
    let stderr = '';

    childProcess.stdout.on('data', (data) => {
      stdout += data.toString();
    });

    childProcess.stderr.on('data', (data) => {
      stderr += data.toString();
    });

    childProcess.on('close', (code) => {
      resolve({
        code,
        stdout,
        stderr
      });
    });

    childProcess.on('error', (error) => {
      reject(error);
    });
  });
});

ipcMain.handle('get-project-status', async () => {
  try {
    const result = await ipcMain.emit('execute-podium-script', null, 'status.sh');
    return result;
  } catch (error) {
    return { error: error.message };
  }
});

ipcMain.handle('select-podium-directory', async () => {
  const result = await dialog.showOpenDialog(mainWindow, {
    properties: ['openDirectory'],
    title: 'Select Podium CLI Directory'
  });
  
  if (!result.canceled && result.filePaths.length > 0) {
    return result.filePaths[0];
  }
  
  return null;
});

// Execute arbitrary commands (needed for Docker checks, etc.)
ipcMain.handle('execute-command', async (event, command, args = [], options = {}) => {
  return new Promise((resolve, reject) => {
    debugLog('Executing command', { command, args, options });
    
    const process = spawn(command, args, {
      stdio: ['pipe', 'pipe', 'pipe'],
      ...options
    });

    let stdout = '';
    let stderr = '';

    process.stdout.on('data', (data) => {
      stdout += data.toString();
    });

    process.stderr.on('data', (data) => {
      stderr += data.toString();
    });

    process.on('close', (code) => {
      const result = { code, stdout, stderr };
      debugLog('Command completed', { command, result });
      resolve(result);
    });

    process.on('error', (error) => {
      debugLog('Command error', { command, error: error.message });
      reject(error);
    });
  });
});

ipcMain.handle('execute-command-stream', async (event, command, args = [], options = {}) => {
  return new Promise((resolve, reject) => {
    debugLog('Executing command stream', { command, args, options });
    
    const childProcess = spawn(command, args, {
      stdio: ['pipe', 'pipe', 'pipe'],
      env: { ...process.env, NO_COLOR: '1' },
      ...options
    });

    let stdout = '';
    let stderr = '';

    // Log to console for debugging, no UI output
    childProcess.stdout.on('data', (data) => {
      const output = data.toString('utf8');
      stdout += output;
      console.log('STDOUT:', output);
      debugLog('Command stdout', { command, output });
    });

    childProcess.stderr.on('data', (data) => {
      const output = data.toString('utf8');
      stderr += output;
      console.log('STDERR:', output);
      debugLog('Command stderr', { command, output });
    });

    childProcess.on('close', (code) => {
      const result = { 
        success: code === 0,
        code: code,
        exitCode: code,
        stdout,
        stderr
      };
      console.log('Process exited with code:', code);
      debugLog('Command completed', { command, result });
      resolve(result);
    });

    childProcess.on('error', (error) => {
      console.error('Process error:', error);
      debugLog('Command error', { command, error: error.message });
      reject(error);
    });
  });
});

ipcMain.handle('select-directory', async (event, options = {}) => {
  const result = await dialog.showOpenDialog(mainWindow, {
    properties: ['openDirectory'],
    title: options.title || 'Select Directory',
    defaultPath: options.defaultPath
  });
  
  if (!result.canceled && result.filePaths.length > 0) {
    return result.filePaths[0];
  }
  
  return null;
});
