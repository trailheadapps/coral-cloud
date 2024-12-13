import fs from 'fs';

const PROJECT_FILE = 'sfdx-project.json';
const VERSION_REGEX = /(\d+\.\d+\.\d+)/;

export function readProjectConfig() {
    const rawProjectFile = fs.readFileSync(PROJECT_FILE);
    return JSON.parse(rawProjectFile);
}

export function writeProjectConfig(projectConfig) {
    const rawProjectFile = JSON.stringify(projectConfig, null, 4);
    fs.writeFileSync(PROJECT_FILE, rawProjectFile);
}

export function getPackageIndex(projectConfig, packageName) {
    const packageIndex = projectConfig.packageDirectories.findIndex(
        (packageDir) => packageDir.package === packageName
    );
    if (packageIndex === -1) {
        console.log(`Could not find package with name '${packageName}'`);
        process.exit(2);
    }
    return packageIndex;
}

export function getPackageVersion(projectConfig, packageName) {
    const packageIndex = getPackageIndex(projectConfig, packageName);
    return projectConfig.packageDirectories[packageIndex].versionNumber;
}

export function getVersionWithoutKeyword(fullVersion) {
    const matches = fullVersion.match(VERSION_REGEX);
    if (matches.length === 1) {
        return matches[0];
    }
    return matches[1];
}
