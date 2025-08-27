const { ipcRenderer, shell } = require('electron');

// Global state interfaces
interface Project {
  name: string;
  type: 'php' | 'laravel' | 'wordpress';
  folderExists: boolean;
  hostEntry: boolean;
  dockerRunning: boolean;
  portMapped: boolean;
  localUrl: string;
  lanUrl: string;
  port: number | null;
  status: 'running' | 'starting' | 'stopped';
}

interface SharedService {
  name: string;
  status: string;
  port?: number;
  running?: boolean;
}

interface SharedServices {
  [key: string]: SharedService;
}

interface Services {
  [key: string]: any;
}

// Global state
let projects: Project[] = [];
let sharedServices: SharedServices = {};
let services: Services = {};
console.log('RENDERER: Global state initialized');

// Initialize app
document.addEventListener('DOMContentLoaded', (): void => {
    console.log('DEBUG: DOMContentLoaded event fired');
    console.log('DEBUG: About to call loadProjects()');
    loadProjects();
    console.log('DEBUG: About to call loadServices()');
    loadServices();
    console.log('DEBUG: About to call setupEventListeners()');
    setupEventListeners();
    console.log('DEBUG: DOMContentLoaded initialization complete');
});

function setupEventListeners(): void {
    // Project type radio buttons
    const projectTypeRadios: NodeListOf<HTMLInputElement> = document.querySelectorAll('input[name="project-type"]');
    projectTypeRadios.forEach((radio: HTMLInputElement) => {
        radio.addEventListener('change', toggleVersionGroups);
    });
    
    // GitHub repository checkbox
    const githubCheckbox: HTMLInputElement | null = document.getElementById('create-github-repo') as HTMLInputElement;
    if (githubCheckbox) {
        githubCheckbox.addEventListener('change', toggleGithubOptions);
    }
}

function toggleGithubOptions(): void {
    const githubCheckbox: HTMLInputElement | null = document.getElementById('create-github-repo') as HTMLInputElement;
    const githubOptions: HTMLElement | null = document.getElementById('github-options');
    
    if (githubCheckbox && githubOptions) {
        githubOptions.style.display = githubCheckbox.checked ? 'block' : 'none';
    }
}

function toggleVersionGroups(): void {
    const projectType: string = (document.querySelector('input[name="project-type"]:checked') as HTMLInputElement).value;
    const laravelGroup: HTMLElement | null = document.getElementById('laravel-version-group');
    const wordpressGroup: HTMLElement | null = document.getElementById('wordpress-version-group');
    const basicGroup: HTMLElement | null = document.getElementById('basic-version-group');
    
    // Hide all version groups first
    if (laravelGroup) laravelGroup.style.display = 'none';
    if (wordpressGroup) wordpressGroup.style.display = 'none';
    if (basicGroup) basicGroup.style.display = 'none';
    
    // Show the appropriate version group
    if (projectType === 'laravel' && laravelGroup) {
        laravelGroup.style.display = 'block';
    } else if (projectType === 'wordpress' && wordpressGroup) {
        wordpressGroup.style.display = 'block';
    }
    // Note: Basic PHP doesn't need version selection - no options to show
}

async function loadProjects(): Promise<void> {
    try {
        // Use podium status command with JSON output for cleaner parsing
        const result = await ipcRenderer.invoke('execute-podium', 'status', ['--json-output']);
        
        // Check if command succeeded
        if (result.code !== 0) {
            console.log('Podium status command failed, likely no projects or services stopped');
            projects = [];
            sharedServices = {};
            renderProjects();
            return;
        }
        
        parseProjectStatusJSON(result.stdout);
        renderProjects();
    } catch (error) {
        console.error('Failed to load projects:', error);
        // Only show error if it's a real failure, not just empty state
        if (projects.length === 0) {
            console.log('No projects found, not showing error notification');
        } else {
            showError('Failed to load projects');
        }
    }
}

function parseProjectStatusJSON(statusOutput: string): void {
    projects = [];
    sharedServices = {};
    
    if (!statusOutput || statusOutput.trim() === '') {
        console.log('Empty status output, no projects to parse');
        return;
    }
    
    // Check if output looks like JSON
    const trimmed: string = statusOutput.trim();
    if (!trimmed.startsWith('{') && !trimmed.startsWith('[')) {
        console.log('Status output is not JSON format, likely no projects or services stopped:', trimmed);
        return;
    }
    
    try {
        const data = JSON.parse(statusOutput);
        
        // Store shared services data
        sharedServices = data.shared_services || {};
        
        // Parse projects
        if (data.projects && Array.isArray(data.projects)) {
            for (const projectData of data.projects) {
                const project: Project = {
                    name: projectData.name || '',
                    type: 'php', // Default type
                    folderExists: projectData.folder_exists === true,
                    hostEntry: projectData.host_entry === true,
                    dockerRunning: projectData.docker_running === true,
                    portMapped: projectData.port_mapped === true,
                    localUrl: projectData.local_url || '',
                    lanUrl: projectData.lan_url || '',
                    port: projectData.external_port ? parseInt(projectData.external_port) : null,
                    status: 'stopped'
                };
                
                // Determine overall status
                if (project.dockerRunning && project.portMapped) {
                    project.status = 'running';
                } else if (project.dockerRunning) {
                    project.status = 'starting';
                } else {
                    project.status = 'stopped';
                }
                
                // Detect project type from name (simplified)
                if (project.name.includes('laravel') || project.name.includes('api')) {
                    project.type = 'laravel';
                } else if (project.name.includes('wordpress') || project.name.includes('wp')) {
                    project.type = 'wordpress';
                } else {
                    project.type = 'php';
                }
                
                projects.push(project);
            }
        }
        
    } catch (error) {
        console.error('Failed to parse JSON status output:', error);
        console.log('Raw output that failed to parse:', statusOutput);
        // Only show error if the directory exists but parsing failed
        // This prevents errors when services are simply stopped or directory is empty
        if (statusOutput.includes('Error:') || statusOutput.includes('Failed:')) {
            showError('Failed to parse project status data');
        } else {
            console.log('Non-JSON output likely due to stopped services, not showing error');
        }
    }
}

// Legacy function - redirects to JSON version
function parseProjectStatus(statusOutput: string): void {
    console.log('DEBUG: parseProjectStatus called - redirecting to JSON version');
    parseProjectStatusJSON(statusOutput);
}

function renderProjects(): void {
    const grid: HTMLElement | null = document.getElementById('projects-grid');
    if (!grid) return;
    
    if (projects.length === 0) {
        grid.innerHTML = `
            <div class="project-card placeholder">
                <div class="project-icon">🚀</div>
                <h3>Create Your First Project</h3>
                <p>Get started by creating a new PHP, Laravel, or WordPress project</p>
                <button class="btn btn-primary" onclick="showCreateProject()">Create Project</button>
            </div>
        `;
        return;
    }

    grid.innerHTML = projects.map((project: Project) => {
        const statusIcon = project.status === 'running' ? '🟢' : 
                          project.status === 'starting' ? '🟡' : '🔴';
        const statusText = project.status.charAt(0).toUpperCase() + project.status.slice(1);
        const projectIcon = project.type === 'laravel' ? '🎯' : 
                           project.type === 'wordpress' ? '📝' : '🐘';

        return `
            <div class="project-card">
                <div class="project-icon">${projectIcon}</div>
                <h3>${project.name}</h3>
                <div class="project-status">
                    <span class="status-indicator ${project.status}">${statusIcon} ${statusText}</span>
                </div>
                <div class="project-details">
                    <div class="project-urls">
                        ${project.localUrl ? `<a href="${project.localUrl}" class="url-link" onclick="openUrl('${project.localUrl}')">${project.localUrl}</a>` : ''}
                        ${project.lanUrl ? `<a href="${project.lanUrl}" class="url-link" onclick="openUrl('${project.lanUrl}')">${project.lanUrl}</a>` : ''}
                    </div>
                    <div class="project-actions">
                        ${project.status === 'running' ? 
                            `<button class="btn btn-warning btn-sm" onclick="stopProject('${project.name}')">Stop</button>` :
                            `<button class="btn btn-success btn-sm" onclick="startProject('${project.name}')">Start</button>`
                        }
                        <button class="btn btn-info btn-sm" onclick="showProjectDetails('${project.name}')">Details</button>
                        <button class="btn btn-danger btn-sm" onclick="removeProject('${project.name}')">Remove</button>
                    </div>
                </div>
            </div>
        `;
    }).join('');
}

async function loadServices(): Promise<void> {
    try {
        const result = await ipcRenderer.invoke('execute-podium', 'status', ['--json-output']);
        
        if (result.code !== 0) {
            console.log('Services status command failed, likely no services running');
            renderServices();
            return;
        }
        
        parseProjectStatusJSON(result.stdout);
        renderServices();
    } catch (error) {
        console.error('Failed to load services:', error);
        renderServices();
    }
}

function renderServices(): void {
    const servicesGrid: HTMLElement | null = document.getElementById('services-grid');
    if (!servicesGrid) return;

    if (!sharedServices || Object.keys(sharedServices).length === 0) {
        servicesGrid.innerHTML = `
            <div class="service-card">
                <div class="service-status">⚪</div>
                <h4>No Services</h4>
                <p>Start Podium to see shared services</p>
            </div>
        `;
        return;
    }

    servicesGrid.innerHTML = Object.entries(sharedServices).map(([serviceName, service]: [string, SharedService]) => {
        const statusIcon = service.running ? '🟢' : '🔴';
        const statusText = service.running ? 'Running' : 'Stopped';
        
        return `
            <div class="service-card">
                <div class="service-status">${statusIcon}</div>
                <h4>${serviceName}</h4>
                <p>${statusText}${service.port ? ` (Port ${service.port})` : ''}</p>
            </div>
        `;
    }).join('');
}

// Project management functions
async function startProject(projectName: string): Promise<void> {
    try {
        showLoading(`Starting project ${projectName}...`);
        const result = await ipcRenderer.invoke('execute-command-stream', 'podium', ['start', projectName]);
        
        if (result.success) {
            showSuccess(`Project ${projectName} started successfully`);
        } else {
            showError(`Failed to start project: ${result.stderr || result.stdout}`);
        }
        
        // Refresh project list
        setTimeout(() => {
            loadProjects();
            loadServices();
        }, 2000);
    } catch (error) {
        showError('Error starting project: ' + (error as Error).message);
    }
}

async function stopProject(projectName: string): Promise<void> {
    try {
        showLoading(`Stopping project ${projectName}...`);
        const result = await ipcRenderer.invoke('execute-command-stream', 'podium', ['stop', projectName]);
        
        if (result.success) {
            showSuccess(`Project ${projectName} stopped successfully`);
        } else {
            showError(`Failed to stop project: ${result.stderr || result.stdout}`);
        }
        
        // Refresh project list
        setTimeout(() => {
            loadProjects();
            loadServices();
        }, 2000);
    } catch (error) {
        showError('Error stopping project: ' + (error as Error).message);
    }
}

async function removeProject(projectName: string): Promise<void> {
    if (!confirm(`Are you sure you want to remove project "${projectName}"? This action cannot be undone.`)) {
        return;
    }

    try {
        showLoading(`Removing project ${projectName}...`);
        const result = await ipcRenderer.invoke('execute-command-stream', 'podium', ['remove', projectName, '--force']);
        
        if (result.success) {
            showSuccess(`Project ${projectName} removed successfully`);
        } else {
            showError(`Failed to remove project: ${result.stderr || result.stdout}`);
        }
        
        // Refresh project list
        setTimeout(() => {
            loadProjects();
            loadServices();
        }, 2000);
    } catch (error) {
        showError('Error removing project: ' + (error as Error).message);
    }
}

function refreshProjects(): void {
    showNotification('🔄 Refreshing projects and services...', 'info', 2000);
    loadProjects();
    loadServices();
    
    // Show completion notification after a brief delay
    setTimeout(() => {
        showNotification('✅ Projects refreshed', 'success', 2000);
    }, 1000);
}

function openUrl(url: string): void {
    shell.openExternal(url);
}

function showCreateProject(): void {
    showModal('create-project-modal');
}

function showProjectDetails(projectName: string): void {
    const project: Project | undefined = projects.find((p: Project) => p.name === projectName);
    if (!project) return;

    const modal: HTMLElement | null = document.getElementById('project-details-modal');
    const content: HTMLElement | null = document.getElementById('project-details-content');
    
    if (!modal || !content) return;

    content.innerHTML = `
        <h3>${project.name}</h3>
        <div class="detail-grid">
            <div class="detail-item">
                <strong>Type:</strong> ${project.type}
            </div>
            <div class="detail-item">
                <strong>Status:</strong> ${project.status}
            </div>
            <div class="detail-item">
                <strong>Folder Exists:</strong> ${project.folderExists ? 'Yes' : 'No'}
            </div>
            <div class="detail-item">
                <strong>Host Entry:</strong> ${project.hostEntry ? 'Yes' : 'No'}
            </div>
            <div class="detail-item">
                <strong>Docker Running:</strong> ${project.dockerRunning ? 'Yes' : 'No'}
            </div>
            <div class="detail-item">
                <strong>Port Mapped:</strong> ${project.portMapped ? 'Yes' : 'No'}
            </div>
            ${project.port ? `
            <div class="detail-item">
                <strong>Port:</strong> ${project.port}
            </div>
            ` : ''}
            ${project.localUrl ? `
            <div class="detail-item">
                <strong>Local URL:</strong> <a href="${project.localUrl}" onclick="openUrl('${project.localUrl}')">${project.localUrl}</a>
            </div>
            ` : ''}
            ${project.lanUrl ? `
            <div class="detail-item">
                <strong>LAN URL:</strong> <a href="${project.lanUrl}" onclick="openUrl('${project.lanUrl}')">${project.lanUrl}</a>
            </div>
            ` : ''}
        </div>
    `;

    showModal('project-details-modal');
}

// Modal management
function showModal(modalId: string): void {
    const modal: HTMLElement | null = document.getElementById(modalId);
    if (modal) {
        modal.style.display = 'block';
    }
}

function hideModal(modalId: string): void {
    const modal: HTMLElement | null = document.getElementById(modalId);
    if (modal) {
        modal.style.display = 'none';
    }
}

// Auto-refresh projects and services every 10 seconds
setInterval((): void => {
    loadProjects();
    loadServices();
}, 10000);

// Utility functions
let currentNotification: HTMLElement | null = null;

function showLoading(message: string): void {
    hideNotification();
    currentNotification = showNotification(message, 'loading', 0);
}

function showSuccess(message: string): void {
    hideNotification();
    currentNotification = showNotification(message, 'success', 5000);
}

function showError(message: string): void {
    hideNotification();
    currentNotification = showNotification(message, 'error', 8000);
}

function hideNotification(): void {
    if (currentNotification) {
        currentNotification.remove();
        currentNotification = null;
    }
}

function showNotification(message: string, type: 'success' | 'error' | 'info' | 'loading' = 'info', duration: number = 5000): HTMLElement {
    hideNotification();

    const notification: HTMLElement = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.innerHTML = `
        <div class="notification-content">
            <span class="notification-message">${message}</span>
            <button class="notification-close" onclick="this.parentElement.parentElement.remove()">×</button>
        </div>
    `;

    document.body.appendChild(notification);

    // Auto-hide after duration (if duration > 0)
    if (duration > 0) {
        setTimeout((): void => {
            if (notification.parentNode) {
                notification.remove();
                if (currentNotification === notification) {
                    currentNotification = null;
                }
            }
        }, duration);
    }

    return notification;
}

// Debug logging for renderer
if (ipcRenderer) {
    const originalConsoleLog = console.log;
    console.log = function(...args: any[]): void {
        originalConsoleLog.apply(console, args);
        if (ipcRenderer) {
            ipcRenderer.invoke('renderer-log', ...args);
        }
    }
    
    // Log that renderer is ready
    if (document.readyState === 'loading') {
        ipcRenderer.invoke('renderer-log', '🎯 DOM loaded, initializing...');
    }
    
    loadProjects();
    loadServices();
    
    // Add functions to global scope for debugging
    (window as any).testStartProject = testStartProject;
    (window as any).startProject = startProject;
    
    console.log('✅ Initialization complete, functions available:', {
        testStartProject: typeof (window as any).testStartProject,
        startProject: typeof (window as any).startProject
    });
}

// Test function for debugging
async function testStartProject(projectName: string): Promise<void> {
    console.log('🧪 Testing startProject with:', projectName);
    try {
        const result = await ipcRenderer.invoke('execute-command', 'podium', ['start', projectName]);
        console.log('✅ Command result:', result);
    } catch (error) {
        console.error('❌ Command failed:', error);
    }
}

// Export functions for global access
(window as any).refreshProjects = refreshProjects;
(window as any).showCreateProject = showCreateProject;
(window as any).startProject = startProject;
(window as any).stopProject = stopProject;
(window as any).removeProject = removeProject;
(window as any).showProjectDetails = showProjectDetails;
(window as any).showModal = showModal;
(window as any).hideModal = hideModal;
(window as any).openUrl = openUrl;
