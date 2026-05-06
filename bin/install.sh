#!/bin/bash
SCRIPT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd $SCRIPT_PATH/..

# Set parameters
ORG_ALIAS="cc-demo"

echo ""
echo "Installing Coral Cloud demo ($ORG_ALIAS)"
echo ""

echo "Cleaning previous scratch org..."
sf org delete scratch -p -o $ORG_ALIAS &> /dev/null
echo ""

echo "[1/9] Creating scratch org..." && \
sf org create scratch -f config/project-scratch-def.json -a $ORG_ALIAS -d -y 30 && \
echo "" && \

echo "[2/9] Creating Service Agent user..." && \
AGENT_USERNAME=$(sf org create agent-user --first-name Service --last-name Agent --json | jq -r '.result.username') && \
echo "Service Agent username: $AGENT_USERNAME" && \
echo "" && \

echo "[3/9] Overwrite agent username in *.agent files..." && \
find . -name "*.agent" -exec sed -i '' "s/default_agent_user: \".*\"/default_agent_user: \"$AGENT_USERNAME\"/" {} + && \
echo "" && \

echo "[4/9] Overwrite agent username in *.bot-meta.xml files..." && \
find . -name "*.bot-meta.xml" -exec sed -i '' "s/<botUser>.*<\/botUser>/<botUser>$AGENT_USERNAME<\/botUser>/" {} + && \
echo "" && \

echo "[5/9] Assigning prompt template manager permission sets to user..."
sf org assign permset -n EinsteinGPTPromptTemplateManager
echo "" && \

echo "[6/9] Pushing base source..." && \
sf project deploy start && \
echo "" && \

echo "[7/9] Assigning Coral Cloud permission sets..." && \
sf org assign permset -n Coral_Cloud_Admin
sf org assign permset -n Coral_Cloud_Customer_Service_Agent -b "$AGENT_USERNAME"
echo "" && \

echo "[8/9] Importing sample data..." && \
sf data tree import -p data/data-plan.json && \
echo "" && \

echo "[9/9] Generate additional sample data..." && \
sf apex run -f apex-scripts/setup.apex && \
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
