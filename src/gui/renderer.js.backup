

// Load ipcRenderer for communication with main process
let ipcRenderer = null;
try {
    ipcRenderer = require('electron').ipcRenderer;
} catch (error) {
    console.error('Failed to load ipcRenderer:', error);
}

// Global state
let projects = [];
let sharedServices = {};
let services = {};
console.log('RENDERER: Global state initialized');

// Initialize app
document.addEventListener('DOMContentLoaded', () => {
    console.log('DEBUG: DOMContentLoaded event fired');
    console.log('DEBUG: About to call loadProjects()');
    loadProjects();
    console.log('DEBUG: About to call loadServices()');
    loadServices();
    console.log('DEBUG: About to call setupEventListeners()');
    setupEventListeners();
    console.log('DEBUG: DOMContentLoaded initialization complete');
});

function setupEventListeners() {
    // Project type radio buttons
    const projectTypeRadios = document.querySelectorAll('input[name="project-type"]');
    projectTypeRadios.forEach(radio => {
        radio.addEventListener('change', toggleVersionGroups);
    });
    
    // GitHub repository checkbox
    const githubCheckbox = document.getElementById('create-github-repo');
    if (githubCheckbox) {
        githubCheckbox.addEventListener('change', toggleGithubOptions);
    }
}

function toggleGithubOptions() {
    const githubCheckbox = document.getElementById('create-github-repo');
    const githubOptions = document.getElementById('github-options');
    
    if (githubCheckbox && githubOptions) {
        githubOptions.style.display = githubCheckbox.checked ? 'block' : 'none';
    }
}

function toggleVersionGroups() {
    const projectType = document.querySelector('input[name="project-type"]:checked').value;
    const laravelGroup = document.getElementById('laravel-version-group');
    const wordpressGroup = document.getElementById('wordpress-version-group');
    const basicGroup = document.getElementById('basic-version-group');
    
    // Hide all version groups first
    laravelGroup.style.display = 'none';
    wordpressGroup.style.display = 'none';
    basicGroup.style.display = 'none';
    
    // Show the appropriate version group
    if (projectType === 'laravel') {
        laravelGroup.style.display = 'block';
    } else if (projectType === 'wordpress') {
        wordpressGroup.style.display = 'block';
    }
    // Note: Basic PHP doesn't need version selection - no options to show
}

async function loadProjects() {
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

function parseProjectStatusJSON(statusOutput) {
    projects = [];
    sharedServices = {};
    
    if (!statusOutput || statusOutput.trim() === '') {
        console.log('Empty status output, no projects to parse');
        return;
    }
    
    // Check if output looks like JSON
    const trimmed = statusOutput.trim();
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
                const project = {
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
function parseProjectStatus(statusOutput) {
    console.log('DEBUG: parseProjectStatus called - redirecting to JSON version');
    parseProjectStatusJSON(statusOutput);
}

function renderProjects() {
    const grid = document.getElementById('projects-grid');
    
    if (projects.length === 0) {
        grid.innerHTML = `
            <div class="project-card placeholder">
                <div class="project-icon">🚀</div>
                <h3>Create Your First Project</h3>
                <p>Get started by creating a new Laravel or WordPress project</p>
                <button class="btn btn-primary" onclick="createNewProject()">+ New Project</button>
            </div>
        `;
        return;
    }

    const projectHTML = projects.map(project => {
        const typeIcon = getProjectTypeIcon(project.type);
        const statusClass = project.status === 'running' ? 'status-running' : 'status-stopped';
        const statusIcon = project.status === 'running' ? '🟢' : '🔴';
        
        // Health indicators - only show relevant issues based on project state
        const healthIndicators = [];
        if (!project.folderExists) healthIndicators.push('📁❌ Missing folder');
        if (!project.hostEntry) healthIndicators.push('🌐❌ No host entry');
        
        // Only show Docker/port issues if project should be running
        if (project.status === 'running') {
            if (!project.dockerRunning) healthIndicators.push('🐳❌ Docker not running');
            if (!project.portMapped) healthIndicators.push('🔗❌ Port not mapped');
        }
        
        const hasIssues = healthIndicators.length > 0;
        
        return `
            <div class="project-card ${hasIssues ? 'has-issues' : ''}">
                <div class="project-header">
                    <div class="project-icon">${typeIcon}</div>
                    <div class="project-info">
                        <h3>${project.name}</h3>
                        <div class="project-type">${project.type.toUpperCase()}</div>
                    </div>
                    <div class="project-status ${statusClass}">
                        ${statusIcon} ${project.status.charAt(0).toUpperCase() + project.status.slice(1)}
                    </div>
                </div>
                
                ${hasIssues ? `
                    <div class="project-issues">
                        <div class="issues-header">⚠️ Issues:</div>
                        ${healthIndicators.map(issue => `<div class="issue">${issue}</div>`).join('')}
                    </div>
                ` : ''}
                
                ${project.status === 'running' ? `
                    <div class="project-urls">
                        <div class="url-item">
                            <strong>Local:</strong> 
                            <a href="${project.localUrl}" onclick="openUrl('${project.localUrl}')" class="url-link">${project.localUrl}</a>
                        </div>
                        ${project.lanUrl ? `
                            <div class="url-item">
                                <strong>LAN:</strong> 
                                <a href="${project.lanUrl}" onclick="openUrl('${project.lanUrl}')" class="url-link">
                                    ${project.lanUrl}
                                </a>
                            </div>
                        ` : ''}
                    </div>
                ` : ''}
                
                <div class="project-actions">
                    ${project.status === 'running' 
                        ? `<button class="btn btn-warning btn-small" onclick="stopProject('${project.name}')">⏹ Stop</button>`
                        : `<button class="btn btn-success btn-small" onclick="startProject('${project.name}')">▶ Start</button>`
                    }
                    <button class="btn btn-primary btn-small" onclick="openUrl('${project.localUrl}')">🌐 Open</button>
                    <button class="btn btn-secondary btn-small" onclick="openUrl('http://phpmyadmin')">🗄️ DB</button>
                    <button class="btn btn-info btn-small" onclick="openTerminal('${project.name}')">💻 Terminal</button>
                    <button class="btn btn-danger btn-small" onclick="removeProject('${project.name}')">🗑️ Remove</button>
                </div>
            </div>
        `;
    }).join('');
    
    grid.innerHTML = projectHTML;
}

function getProjectTypeIcon(type) {
    switch(type) {
        case 'laravel': return '🔺';
        case 'wordpress': return '📝';
        case 'php': return '🐘';
        default: return '📦';
    }
}

async function loadServices() {
    try {
        // Check Docker containers for services
        const result = await ipcRenderer.invoke('execute-command', 'docker', ['ps', '--format', 'json']);
        
        services = {
            mysql: false,
            redis: false,
            phpmyadmin: false,
            mongo: false,
            postgres: false,
            memcached: false
        };
        
        if (result.code === 0 && result.stdout) {
            const containers = result.stdout.trim().split('\n')
                .filter(line => line.trim())
                .map(line => {
                    try {
                        return JSON.parse(line);
                    } catch (e) {
                        return null;
                    }
                })
                .filter(container => container !== null);
            
            // Check for service containers
            for (const container of containers) {
                const name = container.Names || container.Name || '';
                const image = container.Image || '';
                
                if (name.includes('mariadb') || name.includes('mysql') || image.includes('mariadb') || image.includes('mysql')) {
                    services.mysql = true;
                }
                if (name.includes('redis') || image.includes('redis')) {
                    services.redis = true;
                }
                if (name.includes('phpmyadmin') || image.includes('phpmyadmin')) {
                    services.phpmyadmin = true;
                }
                if (name.includes('mongo') || image.includes('mongo')) {
                    services.mongo = true;
                }
                if (name.includes('postgres') || image.includes('postgres')) {
                    services.postgres = true;
                }
                if (name.includes('memcached') || image.includes('memcached')) {
                    services.memcached = true;
                }
            }
        }
    } catch (error) {
        console.error('Failed to load services:', error);
    }
    
    // Update service indicators
    updateServiceStatus();
}

function updateServiceStatus() {
    document.getElementById('mysql-status').textContent = services.mysql ? '🟢' : '🔴';
    document.getElementById('redis-status').textContent = services.redis ? '🟢' : '🔴';
    document.getElementById('phpmyadmin-status').textContent = services.phpmyadmin ? '🟢' : '🔴';
    document.getElementById('mongo-status').textContent = services.mongo ? '🟢' : '🔴';
    document.getElementById('postgres-status').textContent = services.postgres ? '🟢' : '🔴';
    document.getElementById('memcached-status').textContent = services.memcached ? '🟢' : '🔴';
}

// Modal functions
function createNewProject() {
    document.getElementById('new-project-modal').classList.add('show');
}

function closeModal() {
    document.getElementById('new-project-modal').classList.remove('show');
}

async function submitNewProject() {
    console.log('submitNewProject called!'); // Debug
    
    const projectName = document.getElementById('project-name').value;
    const projectTypeElement = document.querySelector('input[name="project-type"]:checked');
    const createGithubRepo = document.getElementById('create-github-repo').checked;
    const organization = createGithubRepo ? document.getElementById('organization').value : '';
    
    // Get version based on project type
    let version = '';
    if (projectTypeElement) {
        const projectType = projectTypeElement.value;
        if (projectType === 'laravel') {
            version = document.getElementById('laravel-version').value;
        } else if (projectType === 'wordpress') {
            version = document.getElementById('wordpress-version').value;
        } else if (projectType === 'basic') {
            version = document.getElementById('basic-version').value;
        }
    }
    
    console.log('Project name:', projectName); // Debug
    console.log('Project type element:', projectTypeElement); // Debug
    console.log('Create GitHub repo:', createGithubRepo); // Debug
    console.log('Organization:', organization); // Debug
    
    if (!projectName) {
        alert('Project name is required');
        return;
    }
    
    if (!projectTypeElement) {
        alert('Please select a project type');
        return;
    }
    
    const projectType = projectTypeElement.value;
    console.log('Project type:', projectType); // Debug
    console.log('Version:', version); // Debug
    
    try {
        showLoading('Creating project...');
        
        const args = [projectName];
        if (createGithubRepo && organization) args.push(organization);
        if (version) args.push(version);
        // Add flag for GitHub repo creation
        if (createGithubRepo) args.push('--github');
        
        console.log('Calling podium new with args:', args); // Debug
        
        const result = await ipcRenderer.invoke('execute-podium', 'new', args);
        
        console.log('Result:', result); // Debug
        
        if (result.code === 0) {
            showSuccess('Project created successfully!');
            closeModal();
            loadProjects();
        } else {
            showError('Failed to create project: ' + result.stderr);
        }
    } catch (error) {
        console.error('Error details:', error); // Debug
        showError('Error creating project: ' + error.message);
    }
}

// Project actions
async function startProject(projectName) {
    console.log('🚀 START PROJECT CALLED:', projectName);
    if (ipcRenderer) {
        ipcRenderer.invoke('renderer-log', '🚀 START PROJECT CALLED:', projectName);
    }
    
    try {
        showLoading(`Starting ${projectName}...`);
        console.log('🔧 Calling execute-podium with up command');
        if (ipcRenderer) {
            ipcRenderer.invoke('renderer-log', '🔧 Calling execute-podium with up command');
        }
        
        const result = await ipcRenderer.invoke('execute-podium', 'up', [projectName]);
        console.log('✅ Result from execute-podium:', result);
        if (ipcRenderer) {
            ipcRenderer.invoke('renderer-log', '✅ Result from execute-podium:', JSON.stringify(result));
        }
        
        if (result.code === 0) {
            showSuccess(`${projectName} started successfully!`);
            loadProjects();
        } else {
            showError(`Failed to start ${projectName}: ${result.stderr || result.stdout}`);
        }
    } catch (error) {
        console.error('💥 Error in startProject:', error);
        if (ipcRenderer) {
            ipcRenderer.invoke('renderer-log', '💥 Error in startProject:', error.message);
        }
        showError('Error starting project: ' + error.message);
    }
}

async function stopProject(projectName) {
    try {
        showLoading(`Stopping ${projectName}...`);
        const result = await ipcRenderer.invoke('execute-podium', 'down', [projectName]);
        if (result.code === 0) {
            showSuccess(`${projectName} stopped successfully!`);
            loadProjects();
        } else {
            showError(`Failed to stop ${projectName}`);
        }
    } catch (error) {
        showError('Error stopping project: ' + error.message);
    }
}

async function removeProject(projectName) {
    if (!confirm(`Are you sure you want to remove ${projectName}? This will move it to trash.`)) {
        return;
    }
    
    try {
        showLoading(`Removing ${projectName}...`);
        const result = await ipcRenderer.invoke('execute-podium-script', 'remove_project.sh', [projectName]);
        if (result.code === 0) {
            showSuccess(`${projectName} removed successfully!`);
            loadProjects();
        } else {
            showError(`Failed to remove ${projectName}`);
        }
    } catch (error) {
        showError('Error removing project: ' + error.message);
    }
}

async function startAllProjects() {
    try {
        showLoading('Starting all projects...');
        const result = await ipcRenderer.invoke('execute-podium-script', 'startup.sh');
        if (result.code === 0) {
            showSuccess('All projects started successfully!');
            loadProjects();
        } else {
            showError('Failed to start all projects');
        }
    } catch (error) {
        showError('Error starting projects: ' + error.message);
    }
}

async function stopAllProjects() {
    try {
        showLoading('Stopping all projects...');
        const result = await ipcRenderer.invoke('execute-podium-script', 'shutdown.sh');
        if (result.code === 0) {
            showSuccess('All projects stopped successfully!');
            loadProjects();
        } else {
            showError('Failed to stop all projects');
        }
    } catch (error) {
        showError('Error stopping projects: ' + error.message);
    }
}

function refreshProjects() {
    showNotification('🔄 Refreshing projects and services...', 'info', 2000);
    loadProjects();
    loadServices();
    
    // Show completion notification after a brief delay
    setTimeout(() => {
        showNotification('✅ Projects refreshed', 'success', 2000);
    }, 1000);
}

function openUrl(url) {
    require('electron').shell.openExternal(url);
}

async function openTerminal(projectName) {
    try {
        // Open terminal with podium exec command for the project
        const result = await ipcRenderer.invoke('execute-podium', 'exec', [projectName, 'bash']);
        if (result.code !== 0) {
            showError(`Failed to open terminal for ${projectName}`);
        }
    } catch (error) {
        showError('Error opening terminal: ' + error.message);
    }
}

async function cloneProject() {
    const repoUrl = prompt('Enter repository URL:');
    if (!repoUrl) return;
    
    const projectName = prompt('Enter project name (optional):');
    
    try {
        showLoading('Cloning project...');
        const args = [repoUrl];
        if (projectName) args.push(projectName);
        
        const result = await ipcRenderer.invoke('execute-podium', 'clone', args);
        if (result.code === 0) {
            showSuccess('Project cloned successfully!');
            loadProjects();
        } else {
            showError('Failed to clone project: ' + result.stderr);
        }
    } catch (error) {
        showError('Error cloning project: ' + error.message);
    }
}

async function startServices() {
    try {
        showLoading('Starting shared services...');
        const result = await ipcRenderer.invoke('execute-podium', 'start-services');
        if (result.code === 0) {
            showSuccess('Services started successfully!');
            loadServices();
        } else {
            showError('Failed to start services');
        }
    } catch (error) {
        showError('Error starting services: ' + error.message);
    }
}

async function stopServices() {
    if (!confirm('Are you sure you want to stop all shared services? This will affect all projects.')) {
        return;
    }
    
    try {
        showLoading('Stopping shared services...');
        const result = await ipcRenderer.invoke('execute-podium', 'stop-services');
        if (result.code === 0) {
            showSuccess('Services stopped successfully!');
            loadServices();
        } else {
            showError('Failed to stop services');
        }
    } catch (error) {
        showError('Error stopping services: ' + error.message);
    }
}

// Test function to verify JavaScript is working
function testStartProject() {
    console.log('🧪 TEST: testStartProject called');
    if (ipcRenderer) {
        ipcRenderer.invoke('renderer-log', '🧪 TEST: testStartProject called');
    }
    alert('JavaScript functions are working! The Start button should work now.');
}

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    console.log('🎯 DOM loaded, initializing...');
    if (ipcRenderer) {
        ipcRenderer.invoke('renderer-log', '🎯 DOM loaded, initializing...');
    }
    
    loadProjects();
    loadServices();
    
    // Add functions to global scope for debugging
    window.testStartProject = testStartProject;
    window.startProject = startProject;
    
    console.log('✅ Initialization complete, functions available:', {
        testStartProject: typeof window.testStartProject,
        startProject: typeof window.startProject
    });
});

// Auto-refresh projects and services every 10 seconds
setInterval(() => {
    loadProjects();
    loadServices();
}, 10000);

// Utility functions
let currentNotification = null;

function showLoading(message) {
    hideNotification();
    currentNotification = showNotification(message, 'loading', 0);
}

function showSuccess(message) {
    hideNotification();
    currentNotification = showNotification(message, 'success', 3000);
}

function showError(message) {
    hideNotification();
    currentNotification = showNotification(message, 'error', 5000);
    console.error('Error:', message);
}

function showNotification(message, type, autoHide = 0) {
    // Create notification element if it doesn't exist
    let notification = document.getElementById('notification');
    if (!notification) {
        notification = document.createElement('div');
        notification.id = 'notification';
        notification.className = 'notification';
        document.body.appendChild(notification);
    }
    
    // Set content and type
    notification.textContent = message;
    notification.className = `notification ${type} show`;
    
    // Auto-hide if specified
    if (autoHide > 0) {
        setTimeout(() => {
            hideNotification();
        }, autoHide);
    }
    
    return notification;
}

function hideNotification() {
    const notification = document.getElementById('notification');
    if (notification) {
        notification.classList.remove('show');
    }
    currentNotification = null;
}
