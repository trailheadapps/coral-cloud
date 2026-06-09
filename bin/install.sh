#!/bin/bash
SCRIPT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd $SCRIPT_PATH/..

# Set parameters
ORG_ALIAS="coral-cloud-demo"

# Ensure that jq is installed
if ! command -v jq &> /dev/null; then
  echo "Error: jq is not installed. Install it with: brew install jq"
  exit 1
fi

echo ""
echo "Installing Coral Cloud demo ($ORG_ALIAS)"
echo ""

echo "Cleaning previous scratch org..."
sf org delete scratch -p -o $ORG_ALIAS &> /dev/null
echo ""

echo "[1/12] Creating scratch org..." && \
sf org create scratch -f config/project-scratch-def.json -a $ORG_ALIAS -d -y 30 && \
echo "" && \

echo "[2/12] Creating Service Agent user..." && \
AGENT_USERNAME=$(sf org create agent-user --first-name Service --last-name Agent --json | jq -r '.result.username') && \
echo "Service Agent username: $AGENT_USERNAME" && \
echo "" && \

echo "[3/12] Overwrite agent username in *.agent files..." && \
find . -name "*.agent" -exec sed -i '' "s/default_agent_user: \".*\"/default_agent_user: \"$AGENT_USERNAME\"/" {} + && \
echo "" && \

echo "[4/12] Overwrite agent username in *.bot-meta.xml files..." && \
find . -name "*.bot-meta.xml" -exec sed -i '' "s/<botUser>.*<\/botUser>/<botUser>$AGENT_USERNAME<\/botUser>/" {} + && \
echo "" && \

echo "[5/12] Assigning prompt template manager permission sets to user..." && \
sf org assign permset -n EinsteinGPTPromptTemplateManager  && \
echo "" && \

echo "[6/12] Pushing base source..." && \
sf project deploy start && \
echo "" && \

echo "[7/12] Activating agent..." && \
sf agent activate --api-name Customer_Service_Agent && \
echo "" && \

echo "[8/12] Assigning Coral Cloud permission sets..." && \
sf org assign permset -n Coral_Cloud_Admin  && \
sf org assign permset -n Coral_Cloud_Customer_Service_Agent -b "$AGENT_USERNAME"  && \
echo "" && \

echo "[9/12] Importing sample data..." && \
sf data tree import -p data/data-plan.json && \
echo "" && \

echo "[10/12] Generate additional sample data..." && \
sf apex run -f apex-scripts/setup.apex && \
echo "" && \

echo "[11/12] Waiting two minutes for sample data to be generated..." && \
sleep 2m && \
echo "" && \

echo "[12/12] Adjusting demo data..." && \
sf apex run -f apex-scripts/setup-demo.apex && \
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
