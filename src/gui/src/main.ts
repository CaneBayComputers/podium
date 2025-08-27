import { app, BrowserWindow, ipcMain, dialog, IpcMainInvokeEvent } from 'electron';
import * as path from 'path';
import { spawn, ChildProcess, execSync } from 'child_process';
import * as fs from 'fs';
import * as os from 'os';

// Debug log file path
const debugLogPath: string = path.join(os.tmpdir(), 'podium-gui-debug.log');

// Debug logging function
function debugLog(message: string, data: any = null): void {
  const timestamp: string = new Date().toISOString();
  const logEntry: string = `[${timestamp}] ${message}${data ? '\n' + JSON.stringify(data, null, 2) : ''}\n`;
  
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

let mainWindow: BrowserWindow | null = null;

function createWindow(): void {
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
    icon: path.join(__dirname, '../../assets/icon.png'),
    title: 'Podium - PHP Development Platform'
  });

  // Check if Podium CLI is installed and configured
  const podiumStatus: string = checkPodiumStatus();
  debugLog('Podium status check result', { status: podiumStatus });
  
  if (podiumStatus === 'not-installed') {
    debugLog('Loading installer.html - Podium not installed');
    mainWindow.loadFile('../installer.html');
  } else if (podiumStatus === 'not-configured') {
    debugLog('Loading installer.html - Podium not configured');
    mainWindow.loadFile('../installer.html');
  } else {
    debugLog('Loading index.html - Podium ready');
    mainWindow.loadFile('../index.html');
  }

  // Open DevTools in development
  if (process.argv.includes('--dev')) {
    mainWindow.webContents.openDevTools();
  }
}

type PodiumStatus = 'configured' | 'not-configured' | 'not-installed';

function checkPodiumStatus(): PodiumStatus {
  try {
    // Check if podium command exists in PATH
    execSync('podium help --no-coloring', { stdio: 'pipe' });
    
    // Podium CLI exists, now check if it's configured
    // Look for docker-stack/.env in common installation locations
    const possibleConfigPaths: string[] = [
      '/usr/local/share/podium-cli/docker-stack/.env',
      path.join(os.homedir(), 'cbc-development/docker-stack/.env'),
      path.join(os.homedir(), 'podium-cli/docker-stack/.env'),
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

app.on('window-all-closed', (): void => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', (): void => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});

// IPC handler for renderer console messages
ipcMain.handle('renderer-log', async (event: IpcMainInvokeEvent, ...args: any[]): Promise<void> => {
  console.log('🔥 RENDERER LOG:', ...args);
  debugLog('RENDERER LOG', args);
});

interface CommandResult {
  code: number;
  stdout: string;
  stderr: string;
}

// IPC handlers for communicating with Podium CLI
ipcMain.handle('execute-podium-script', async (event: IpcMainInvokeEvent, scriptName: string, args: string[] = []): Promise<CommandResult> => {
  return new Promise((resolve, reject) => {
    // Find podium-cli directory
    const podiumStatus: PodiumStatus = checkPodiumStatus();
    const podiumCliPath: string | null = podiumStatus === 'configured' ? '/usr/local/share/podium-cli' : null;
    if (!podiumCliPath) {
      reject(new Error('Podium CLI not found'));
      return;
    }
    
    const scriptPath: string = path.join(podiumCliPath, 'scripts', scriptName);
    
    const childProcess: ChildProcess = spawn('bash', [scriptPath, ...args], {
      cwd: podiumCliPath,
      stdio: ['pipe', 'pipe', 'pipe'],
      env: { ...process.env, NO_COLOR: '1' }
    });

    let stdout: string = '';
    let stderr: string = '';

    childProcess.stdout?.on('data', (data: Buffer) => {
      stdout += data.toString();
    });

    childProcess.stderr?.on('data', (data: Buffer) => {
      stderr += data.toString();
    });

    childProcess.on('close', (code: number | null) => {
      resolve({
        code: code || 0,
        stdout,
        stderr
      });
    });

    childProcess.on('error', (error: Error) => {
      reject(error);
    });
  });
});

// New handler for podium command
ipcMain.handle('execute-podium', async (event: IpcMainInvokeEvent, subcommand: string, args: string[] = []): Promise<CommandResult> => {
  return new Promise((resolve, reject) => {
    // Try to use global podium command first, then fallback to local
    const allArgs: string[] = [subcommand, ...args, '--json-output'];
    
    // Try global podium command first
    let childProcess: ChildProcess = spawn('podium', allArgs, {
      cwd: os.homedir(), // Run from user's home directory
      stdio: ['pipe', 'pipe', 'pipe'],
      env: { ...process.env, NO_COLOR: '1' }
    });

    // If global command fails, try local podium script
    childProcess.on('error', (error: Error) => {
      const podiumStatus: PodiumStatus = checkPodiumStatus();
      const podiumCliPath: string | null = podiumStatus === 'configured' ? '/usr/local/share/podium-cli' : null;
      if (!podiumCliPath) {
        reject(new Error('Podium CLI not found'));
        return;
      }
      
      const podiumPath: string = path.join(podiumCliPath, 'podium');
      childProcess = spawn('bash', [podiumPath, ...allArgs], {
        cwd: os.homedir(), // Run from user's home directory, not CLI directory
        stdio: ['pipe', 'pipe', 'pipe'],
        env: { ...process.env, NO_COLOR: '1' }
      });
    });

    let stdout: string = '';
    let stderr: string = '';

    childProcess.stdout?.on('data', (data: Buffer) => {
      stdout += data.toString();
    });

    childProcess.stderr?.on('data', (data: Buffer) => {
      stderr += data.toString();
    });

    childProcess.on('close', (code: number | null) => {
      resolve({
        code: code || 0,
        stdout,
        stderr
      });
    });

    childProcess.on('error', (error: Error) => {
      reject(error);
    });
  });
});

interface ProjectStatusResult {
  error?: string;
}

ipcMain.handle('get-project-status', async (): Promise<ProjectStatusResult> => {
  try {
    const result = await ipcMain.emit('execute-podium-script', null, 'status.sh');
    return { error: 'Not implemented' }; // This function needs proper implementation
  } catch (error) {
    return { error: (error as Error).message };
  }
});

ipcMain.handle('select-podium-directory', async (): Promise<string | null> => {
  if (!mainWindow) return null;
  
  const result = await dialog.showOpenDialog(mainWindow, {
    properties: ['openDirectory'],
    title: 'Select Podium CLI Directory'
  });
  
  if (!result.canceled && result.filePaths.length > 0) {
    return result.filePaths[0] || null;
  }
  
  return null;
});

interface ExecuteCommandOptions {
  cwd?: string;
  env?: NodeJS.ProcessEnv;
  [key: string]: any;
}

// Execute arbitrary commands (needed for Docker checks, etc.)
ipcMain.handle('execute-command', async (event: IpcMainInvokeEvent, command: string, args: string[] = [], options: ExecuteCommandOptions = {}): Promise<CommandResult> => {
  return new Promise((resolve, reject) => {
    debugLog('Executing command', { command, args, options });
    
    const process: ChildProcess = spawn(command, args, {
      stdio: ['pipe', 'pipe', 'pipe'],
      ...options
    });

    let stdout: string = '';
    let stderr: string = '';

    process.stdout?.on('data', (data: Buffer) => {
      stdout += data.toString();
    });

    process.stderr?.on('data', (data: Buffer) => {
      stderr += data.toString();
    });

    process.on('close', (code: number | null) => {
      const result: CommandResult = { code: code || 0, stdout, stderr };
      debugLog('Command completed', { command, result });
      resolve(result);
    });

    process.on('error', (error: Error) => {
      debugLog('Command error', { command, error: error.message });
      reject(error);
    });
  });
});

interface StreamCommandResult {
  success: boolean;
  code: number;
  exitCode: number;
  stdout: string;
  stderr: string;
}

ipcMain.handle('execute-command-stream', async (event: IpcMainInvokeEvent, command: string, args: string[] = [], options: ExecuteCommandOptions = {}): Promise<StreamCommandResult> => {
  return new Promise((resolve, reject) => {
    debugLog('Executing command stream', { command, args, options });
    
    const childProcess: ChildProcess = spawn(command, args, {
      stdio: ['pipe', 'pipe', 'pipe'],
      env: { ...process.env, NO_COLOR: '1' },
      ...options
    });

    let stdout: string = '';
    let stderr: string = '';

    // Log to console for debugging, no UI output
    childProcess.stdout?.on('data', (data: Buffer) => {
      const output: string = data.toString('utf8');
      stdout += output;
      console.log('STDOUT:', output);
      debugLog('Command stdout', { command, output });
    });

    childProcess.stderr?.on('data', (data: Buffer) => {
      const output: string = data.toString('utf8');
      stderr += output;
      console.log('STDERR:', output);
      debugLog('Command stderr', { command, output });
    });

    childProcess.on('close', (code: number | null) => {
      const result: StreamCommandResult = { 
        success: code === 0,
        code: code || 0,
        exitCode: code || 0,
        stdout,
        stderr
      };
      console.log('Process exited with code:', code);
      debugLog('Command completed', { command, result });
      resolve(result);
    });

    childProcess.on('error', (error: Error) => {
      console.error('Process error:', error);
      debugLog('Command error', { command, error: error.message });
      reject(error);
    });
  });
});

interface SelectDirectoryOptions {
  title?: string;
  defaultPath?: string;
}

ipcMain.handle('select-directory', async (event: IpcMainInvokeEvent, options: SelectDirectoryOptions = {}): Promise<string | null> => {
  if (!mainWindow) return null;
  
  const dialogOptions: Electron.OpenDialogOptions = {
    properties: ['openDirectory'],
    title: options.title || 'Select Directory'
  };
  
  if (options.defaultPath) {
    dialogOptions.defaultPath = options.defaultPath;
  }
  
  const result = await dialog.showOpenDialog(mainWindow, dialogOptions);
  
  if (!result.canceled && result.filePaths.length > 0) {
    return result.filePaths[0] || null;
  }
  
  return null;
});
