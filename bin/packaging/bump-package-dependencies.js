const {
    readProjectConfig,
    writeProjectConfig,
    getPackageIndex,
    getPackageVersion,
    getVersionWithoutKeyword
} = require('./util/projectConfigHelper.js');

// Get package name from parameters
if (process.argv.length !== 3) {
    console.log('Missing package name argument');
    process.exit(1);
}
const packageName = process.argv[2];
console.log(`Updating '${packageName}' package dependencies...`);

// Read project file
const projectConfig = readProjectConfig();

// Find package
const packageIndex = getPackageIndex(projectConfig, packageName);

// Update dependencies
const { dependencies } = projectConfig.packageDirectories[packageIndex];
dependencies.forEach((dep) => {
    const depVersion = getVersionWithoutKeyword(dep.versionNumber);
    const latestVersion = getVersionWithoutKeyword(
        getPackageVersion(projectConfig, dep.package)
    );
    if (depVersion !== latestVersion) {
        console.log(
            `- Dependency '${dep.package}': bumping from ${depVersion} to ${latestVersion}`
        );
        dep.versionNumber = `${latestVersion}.LATEST`;
    } else {
        console.log(
            `- Dependency '${dep.package}': already on latest version ${latestVersion}`
        );
    }
});

// Update project file
writeProjectConfig(projectConfig);
console.log(`Updated '${packageName}' dependencies.`);
