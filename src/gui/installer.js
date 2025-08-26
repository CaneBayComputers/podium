const { ipcRenderer } = require('electron');
const path = require('path');
const fs = require('fs');
const Convert = require('ansi-to-html');

let currentStep = 0;
let installationPath = '';
let systemChecks = {};
let podiumInstalled = false;

// Initialize ANSI to HTML converter with dark theme colors
const convert = new Convert({
    fg: '#f8f9fa',
    bg: '#1a1a1a',
    newline: true,
    escapeXML: false,
    colors: {
        0: '#1a1a1a',  // black
        1: '#ff6b6b',  // red
        2: '#51cf66',  // green
        3: '#ffd43b',  // yellow
        4: '#74c0fc',  // blue
        5: '#d0bfff',  // magenta
        6: '#66d9ef',  // cyan
        7: '#f8f9fa'   // white
    }
});

// Initialize installer
document.addEventListener('DOMContentLoaded', async () => {
    // Check if Podium CLI is already installed
    const podiumStatus = await checkPodiumInstallation();
    
    if (podiumStatus === 'not-configured') {
        // Skip to configuration step if CLI is installed but not configured
        document.querySelector('#step-welcome .step-content h2').textContent = 'Configure Podium';
        document.querySelector('#step-welcome .step-description').textContent = 
            'Podium CLI is installed but needs configuration. Let\'s set up your development environment.';
        document.querySelector('#step-welcome .btn').textContent = 'Configure Now';
        
        // Hide system check step since CLI is already installed
        systemChecks.skipSystemCheck = true;
    }
    
    showStep(0);
});

async function checkPodiumInstallation() {
    try {
        const result = await ipcRenderer.invoke('execute-command', 'podium', ['help', '--no-coloring']);
        if (result.code === 0) {
            podiumInstalled = true;
            
            // Check if configured by looking for docker-stack/.env
            const configCheck = await ipcRenderer.invoke('execute-command', 'test', [
                '-f', '/usr/local/share/podium-cli/docker-stack/.env'
            ]);
            
            return configCheck.code === 0 ? 'configured' : 'not-configured';
        }
        return 'not-installed';
    } catch (error) {
        return 'not-installed';
    }
}

function showStep(stepIndex) {
    // Hide all steps
    document.querySelectorAll('.installer-step').forEach(step => {
        step.classList.remove('active');
    });
    
    // Show current step
    document.getElementById(`step-${getStepName(stepIndex)}`).classList.add('active');
    
    // Update step indicator
    document.querySelectorAll('.step-dot').forEach((dot, index) => {
        dot.classList.remove('active', 'completed');
        if (index === stepIndex) {
            dot.classList.add('active');
        } else if (index < stepIndex) {
            dot.classList.add('completed');
        }
    });
    
    currentStep = stepIndex;
    
    // Execute step-specific logic
    switch (stepIndex) {
        case 1:
            // Disable continue button during system check
            document.getElementById('continue-btn').disabled = true;
            runSystemCheck();
            break;
        case 2:
            loadConfiguration();
            break;
        case 3:
            startInstallation();
            break;
    }
}

function getStepName(index) {
    const steps = ['welcome', 'system-check', 'configuration', 'installation', 'complete'];
    return steps[index];
}

function nextStep() {
    if (currentStep < 4) {
        let nextStepIndex = currentStep + 1;
        
        // Skip system check if CLI is already installed
        if (nextStepIndex === 1 && systemChecks.skipSystemCheck) {
            nextStepIndex = 2;
        }
        
        showStep(nextStepIndex);
    }
}

function previousStep() {
    if (currentStep > 0) {
        showStep(currentStep - 1);
    }
}

async function runSystemCheck() {
    const checks = [
        { id: 'check-os', name: 'Operating System', test: checkOperatingSystem },
        { id: 'check-git', name: 'Git Installation', test: checkGit },
        { id: 'check-docker', name: 'Docker Installation', test: checkDocker },
        { id: 'check-permissions', name: 'Permissions', test: checkPermissions }
    ];
    
    let allPassed = true;
    
    for (const check of checks) {
        const element = document.getElementById(check.id);
        const icon = element.querySelector('.check-icon');
        const text = element.querySelector('.check-text');
        
        // Show loading
        icon.textContent = '⏳';
        text.textContent = `Checking ${check.name}...`;
        
        try {
            const result = await check.test();
            systemChecks[check.id] = result;
            
            if (result.success) {
                icon.textContent = '✅';
                text.textContent = result.message;
                element.classList.add('success');
            } else {
                icon.textContent = '❌';
                text.textContent = result.message;
                element.classList.add('error');
                allPassed = false;
            }
        } catch (error) {
            icon.textContent = '❌';
            text.textContent = `Error checking ${check.name}: ${error.message}`;
            element.classList.add('error');
            allPassed = false;
        }
        
        // Small delay for better UX
        await new Promise(resolve => setTimeout(resolve, 500));
    }
    
    // Enable and show continue button if all checks passed
    const continueBtn = document.getElementById('continue-btn');
    continueBtn.disabled = !allPassed;
    continueBtn.style.display = allPassed ? 'inline-block' : 'none';
    
    if (!allPassed) {
        showErrorMessage('Some system checks failed. Please resolve the issues before continuing.');
    }
}

async function checkOperatingSystem() {
    const platform = process.platform;
    const supported = ['darwin', 'linux', 'win32'];
    
    if (supported.includes(platform)) {
        let osName = platform === 'darwin' ? 'macOS' : platform === 'win32' ? 'Windows' : 'Linux';
        return { success: true, message: `${osName} detected - supported platform` };
    } else {
        return { success: false, message: `Unsupported platform: ${platform}` };
    }
}

async function checkGit() {
    try {
        const result = await ipcRenderer.invoke('execute-command', 'git', ['--version']);
        if (result.code === 0) {
            return { success: true, message: 'Git is installed and ready' };
        } else {
            return { success: false, message: 'Git is not installed or not accessible' };
        }
    } catch (error) {
        return { success: false, message: 'Git check failed' };
    }
}

async function checkDocker() {
    try {
        const result = await ipcRenderer.invoke('execute-command', 'docker', ['--version']);
        if (result.code === 0) {
            return { success: true, message: 'Docker is installed and ready' };
        } else {
            return { success: false, message: 'Docker is not installed - will be installed automatically' };
        }
    } catch (error) {
        return { success: true, message: 'Docker will be installed during setup' };
    }
}

async function checkPermissions() {
    // Check if user has sudo access (for Linux/Mac)
    if (process.platform === 'win32') {
        return { success: true, message: 'Windows permissions ready' };
    }
    
    try {
        const result = await ipcRenderer.invoke('execute-command', 'sudo', ['-v']);
        if (result.code === 0) {
            return { success: true, message: 'Sudo access available' };
        } else {
            return { success: false, message: 'Sudo access required for installation' };
        }
    } catch (error) {
        return { success: false, message: 'Unable to check sudo access' };
    }
}

async function startInstallation() {
    const progressFill = document.getElementById('progress-fill');
    const progressText = document.getElementById('progress-text');
    
    let progress = 0;
    
    try {
        if (podiumInstalled) {
            // CLI is already installed, just run configuration
            updateProgress(20, 'Configuring Podium environment...');
            await runPodiumConfig();
        } else {
            // Step 1: Clone Podium CLI
            updateProgress(10, 'Downloading Podium CLI...');
            await clonePodiumCLI();
            
            // Step 2: Run installer
            updateProgress(20, 'Running Podium installer...');
            await runPodiumInstaller();
        }
        
        // Installation complete
        updateProgress(100, 'Installation complete!');
        console.log('Installation process completed successfully');
        document.getElementById('finish-btn').disabled = false;
        document.getElementById('finish-btn').style.display = 'inline-block';
        
    } catch (error) {
        showErrorMessage(`Installation failed: ${error.message}`);
        logOutput.textContent += `\n\nERROR: ${error.message}`;
    }
}

function updateProgress(percentage, message) {
    document.getElementById('progress-fill').style.width = `${percentage}%`;
    document.getElementById('progress-text').textContent = message;
}

async function clonePodiumCLI() {
    // For development/demo purposes, create symbolic link to existing cbc-development
    const existingCLI = '/home/shawn/repos/cbc/cbc-development';
    installationPath = '/home/shawn/repos/cbc/podium-cli';
    
    // Create symbolic link
    const result = await ipcRenderer.invoke('execute-command', 'ln', [
        '-sf', 
        existingCLI,
        installationPath
    ]);
    
    if (result.code !== 0) {
        throw new Error('Failed to create Podium CLI link');
    }
    
    // Verify the link was created and install script exists
    const checkResult = await ipcRenderer.invoke('execute-command', 'test', [
        '-f', 
        path.join(installationPath, 'scripts', 'configure.sh')
    ]);
    
    if (checkResult.code !== 0) {
        throw new Error('Podium CLI installation files not found');
    }
}

async function runPodiumInstaller() {
    const installerScript = path.join(installationPath, 'scripts', 'configure.sh');
    
    return new Promise((resolve, reject) => {
        console.log('Starting Podium installer...');
        
        // Collect configuration from form
        const gitName = document.getElementById('git-name').value;
        const gitEmail = document.getElementById('git-email').value;
        const awsAccessKey = document.getElementById('aws-access-key').value;
        const awsSecretKey = document.getElementById('aws-secret-key').value;
        const awsRegion = document.getElementById('aws-region').value;
        const skipAws = document.getElementById('skip-aws').checked;
        // Database engine selection removed - all engines are now available
        
        // Build installer arguments
        let installerArgs = ['--gui-mode', '--no-coloring'];
        if (gitName) installerArgs.push('--git-name', gitName);
        if (gitEmail) installerArgs.push('--git-email', gitEmail);
        if (!skipAws && awsAccessKey && awsSecretKey) {
            installerArgs.push('--aws-access-key', awsAccessKey);
            installerArgs.push('--aws-secret-key', awsSecretKey);
            installerArgs.push('--aws-region', awsRegion);
        }
        if (skipAws) installerArgs.push('--skip-aws');
        // Database engine argument removed - all engines are now available
        
        console.log('Running installer with args:', installerArgs);
        
        // Start the installation with configuration
        const command = `echo "y" | bash ${installerScript} ${installerArgs.join(' ')}`;
        ipcRenderer.invoke('execute-command-stream', 'bash', ['-c', command], {
            cwd: installationPath
        }).then((result) => {
            console.log('Installer finished with result:', result);
            
            if (result.code === 0) {
                resolve();
            } else {
                reject(new Error(`Installation script exited with code ${result.code}`));
            }
        }).catch((error) => {
            // Clean up listener
            ipcRenderer.removeListener('command-output', outputListener);
            reject(error);
        });
    });
}

async function runPodiumConfig() {
    return new Promise((resolve, reject) => {
        console.log('Starting Podium configuration...');
        
        // Collect configuration from form
        const gitName = document.getElementById('git-name').value;
        const gitEmail = document.getElementById('git-email').value;
        const awsAccessKey = document.getElementById('aws-access-key').value;
        const awsSecretKey = document.getElementById('aws-secret-key').value;
        const awsRegion = document.getElementById('aws-region').value;
        const skipAws = document.getElementById('skip-aws').checked;
        // Database engine selection removed - all engines are now available
        
        // Build config arguments
        let configArgs = ['config', '--gui-mode'];
        if (gitName) configArgs.push('--git-name', gitName);
        if (gitEmail) configArgs.push('--git-email', gitEmail);
        if (!skipAws && awsAccessKey && awsSecretKey) {
            configArgs.push('--aws-access-key', awsAccessKey);
            configArgs.push('--aws-secret-key', awsSecretKey);
            configArgs.push('--aws-region', awsRegion);
        }
        if (skipAws) configArgs.push('--skip-aws');
        // Database engine argument removed - all engines are now available
        
        // Run podium config command
        configArgs.push('--no-coloring'); // Add no-coloring flag
        console.log('Running podium config with args:', configArgs);
        ipcRenderer.invoke('execute-command-stream', 'podium', configArgs).then((result) => {
            console.log('Config finished with result:', result);
            
            if (result.code === 0) {
                resolve();
            } else {
                reject(new Error(`Configuration failed with code ${result.code}`));
            }
        }).catch((error) => {
            // Clean up listener
            ipcRenderer.removeListener('command-output', outputListener);
            reject(error);
        });
    });
}

function toggleOutput() {
    const logOutput = document.getElementById('installation-log');
    logOutput.style.display = logOutput.style.display === 'none' ? 'block' : 'none';
}

// Debug output now goes to console only - no UI toggle needed

function openDashboard() {
    // Close installer and open main dashboard
    window.location.href = 'index.html';
}

async function loadConfiguration() {
    // Pre-fill Git configuration
    try {
        const gitName = await ipcRenderer.invoke('execute-command', 'git', ['config', '--global', 'user.name']);
        if (gitName.code === 0 && gitName.stdout.trim()) {
            document.getElementById('git-name').value = gitName.stdout.trim();
        }
        
        const gitEmail = await ipcRenderer.invoke('execute-command', 'git', ['config', '--global', 'user.email']);
        if (gitEmail.code === 0 && gitEmail.stdout.trim()) {
            document.getElementById('git-email').value = gitEmail.stdout.trim();
        }
    } catch (error) {
        console.log('Could not pre-fill Git config:', error);
    }

    // Pre-fill AWS configuration
    try {
        const awsAccessKey = await ipcRenderer.invoke('execute-command', 'aws', ['configure', 'get', 'aws_access_key_id']);
        if (awsAccessKey.code === 0 && awsAccessKey.stdout.trim()) {
            document.getElementById('aws-access-key').value = awsAccessKey.stdout.trim();
        }
        
        const awsSecretKey = await ipcRenderer.invoke('execute-command', 'aws', ['configure', 'get', 'aws_secret_access_key']);
        if (awsSecretKey.code === 0 && awsSecretKey.stdout.trim()) {
            document.getElementById('aws-secret-key').value = awsSecretKey.stdout.trim();
        }
        
        const awsRegion = await ipcRenderer.invoke('execute-command', 'aws', ['configure', 'get', 'region']);
        if (awsRegion.code === 0 && awsRegion.stdout.trim()) {
            document.getElementById('aws-region').value = awsRegion.stdout.trim();
        }
    } catch (error) {
        console.log('Could not pre-fill AWS config:', error);
    }

    // Set up AWS checkbox toggle
    const skipAwsCheckbox = document.getElementById('skip-aws');
    const awsFields = document.getElementById('aws-fields');
    
    skipAwsCheckbox.addEventListener('change', () => {
        awsFields.style.display = skipAwsCheckbox.checked ? 'none' : 'block';
    });
}



function showErrorMessage(message) {
    const stepContent = document.querySelector('.installer-step.active .step-content');
    
    // Remove existing error messages
    stepContent.querySelectorAll('.error-message').forEach(el => el.remove());
    
    // Add new error message
    const errorDiv = document.createElement('div');
    errorDiv.className = 'error-message';
    errorDiv.textContent = message;
    stepContent.appendChild(errorDiv);
}
