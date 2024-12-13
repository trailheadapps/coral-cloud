const {
    readProjectConfig,
    writeProjectConfig,
    getPackageIndex
} = require('./util/projectConfigHelper.js');

// Get package name from parameters
if (process.argv.length !== 3) {
    console.log('Missing package name argument');
    process.exit(1);
}
const packageName = process.argv[2];
console.log(`Updating '${packageName}' package version...`);

// Read project file
const projectConfig = readProjectConfig();

// Find package
const packageIndex = getPackageIndex(projectConfig, packageName);

// Bump package minor version
let { versionNumber } = projectConfig.packageDirectories[packageIndex];
const versionParts = versionNumber.split('.');
const minor = parseInt(versionParts[1], 10);
versionParts[1] = `${minor + 1}`;
versionNumber = versionParts.join('.');
projectConfig.packageDirectories[packageIndex].versionNumber = versionNumber;

// Update project file
writeProjectConfig(projectConfig);
console.log(`Updated '${packageName}' package version to ${versionNumber}`);
