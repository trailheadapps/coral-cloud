const fs = require('fs');
const PROJECT_FILE = 'sfdx-project.json';

// Read project file
let rawProjectFile = fs.readFileSync(PROJECT_FILE);
const projectConfig = JSON.parse(rawProjectFile);

// Bump package minor version
let { versionNumber } = projectConfig.packageDirectories[0];
const versionParts = versionNumber.split('.');
const minor = parseInt(versionParts[1], 10);
versionParts[1] = `${minor + 1}`;
versionNumber = versionParts.join('.');
projectConfig.packageDirectories[0].versionNumber = versionNumber;

// Update project file
rawProjectFile = JSON.stringify(projectConfig, null, 4);
fs.writeFileSync(PROJECT_FILE, rawProjectFile);
console.log(`Updated package version to ${versionNumber}`);
