#!/bin/bash
SCRIPT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd $SCRIPT_PATH/..

echo ""
echo "Installing Coral Cloud - Base"
echo ""

# Get default org alias
VALUE_REGEX='"value": "([a-zA-Z0-9_\-]+)"'
ORG_INFO=$(sf config get target-org --json)
if [[ $ORG_INFO =~ $VALUE_REGEX ]]
then
    ORG_ALIAS="${BASH_REMATCH[1]}"
    echo "Using current default org: $ORG_ALIAS"
    echo ""
else
    echo "Could not retrieve default org alias."
    read -p "Create a scratch org? [yY]: " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[^Yy]$ ]]
    then
        echo "Installation aborted."
        exit 1
    fi
    ORG_ALIAS="cc-scratch-org"
    sf org create scratch --definition-file config/project-scratch-def.json --alias "$ORG_ALIAS" -d -y 30
    EXIT_CODE="$?"
    echo ""
    if [ "$EXIT_CODE" -ne 0 ]; then
        echo "Installation failed."
        exit $EXIT_CODE
    fi
fi

# Open DC Setup home
sf org open -p lightning/setup/SetupOneHome/home?setupApp=audience360
echo ""

# Wait for DC activation
echo "STOP: wait for Data Cloud deployment completion before moving forward."
echo "You can check progress in Data Cloud Setup."
read -p "Is Data Cloud is fully enabled? [yY]: " -n 1 -r
echo ""
echo ""
# Abort if not ready
if [[ $REPLY =~ ^[^Yy]$ ]]
then
  echo "Installation aborted."
  exit 1
fi

# Confirm feature activation
echo "STOP: ensure that you've toggled on the following features:"
echo " * Einstein"
echo " * Agents"
read -p "Are the above features enabled? [yY]: " -n 1 -r
echo ""
echo ""
# Abort if not ready
if [[ $REPLY =~ ^[^Yy]$ ]]
then
  echo "Installation aborted."
  exit 1
fi

echo "[1/7] Pushing base source..." && \
sf project deploy start -d cc-base-app && \
echo "" && \

echo "[2/7] Assigning Prompt Template Manager permission set..." && \
sf org assign permset -n EinsteinGPTPromptTemplateManager && \
echo "" && \

echo "[3/7] Pushing employee source..." && \
sf project deploy start -d cc-employee-app && \
echo "" && \

echo "[4/7] Assigning Coral Cloud permission sets..." && \
sf org assign permset -n Coral_Cloud_Admin && \
sf org assign permset -n Coral_Cloud_Employee_Agent_Access && \
echo "" && \

echo "[5/7] Importing sample data..." && \
sf data tree import -p data/data-plan.json && \
echo "" && \

echo "[6/7] Generate additional sample data..." && \
sf apex run -f apex-scripts/setup.apex && \
echo "" && \

echo "[7/7] Installing Data Kit..." && \
sf package install -p 04tHr000000ku4k -w 10 && \
echo "" && \

echo "Opening org..." && \
sf org open -p lightning/page/home && \
echo ""
EXIT_CODE="$?"

# Check exit code
echo ""
if [ "$EXIT_CODE" -eq 0 ]; then
  echo "Installation completed."
  echo ""
else
    echo "Installation failed."
fi
exit $EXIT_CODE
