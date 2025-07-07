#!/bin/bash
SCRIPT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd $SCRIPT_PATH/..

echo ""
echo "Installing Coral Cloud - Service"
echo ""

# Get default org alias
VALUE_REGEX='"value": "([a-zA-Z0-9_\-]+)"'
DEFAULT_ORG_INFO=$(sf config get target-org --json)
if [[ $DEFAULT_ORG_INFO =~ $VALUE_REGEX ]]
then
    ORG_ALIAS="${BASH_REMATCH[1]}"
    echo "Using current default org: $ORG_ALIAS"
    echo "Exporting username and org domain for use in scripts:"
    export SF_CC_PLACEHOLDER_USERNAME=$(sf org display --json | grep -o '"username": "[^"]*' | cut -d'"' -f4)
    echo "- Username: $SF_CC_PLACEHOLDER_USERNAME"
    export SF_CC_PLACEHOLDER_DOMAIN=$(sf org display --json | grep -o '"instanceUrl": "https[^"]*' | cut -d'"' -f4 | sed -E 's|https?://([^\.]+).*|\1|')
    echo "- Domain:   $SF_CC_PLACEHOLDER_DOMAIN"    
    echo ""
else
    echo "Installation failed: could not retrieve default org alias."
    exit 1
fi

echo "[1/9] Pushing Experience Cloud site source..." && \
sf project deploy start -c -d cc-site && \
echo "" && \

echo "[2/9] Pushing Service Agent Setup source..." && \
sf project deploy start -c -d cc-service-app/main/setup/classes/SetupServiceAgentUser.cls -d cc-service-app/main/default/permissionSets/Coral_Cloud_Service_Agent.permissionset-meta.xml && \
echo "" && \

echo "[3/9] Setting up Service Agent user..." && \
sf apex run -f apex-scripts/setup-agent-user.apex && \
echo "" && \

echo "[4/9] Pushing service app source..." && \
export SF_CC_PLACEHOLDER_FLOW_AGENT_ID="DummyForInitialDeploy" && \
export SF_CC_PLACEHOLDER_FLOW_CHANNEL_ID="DummyForInitialDeploy" && \
export SF_CC_PLACEHOLDER_FLOW_QUEUE_ID="DummyForInitialDeploy" && \
sf project deploy start -c -d cc-service-app && \
echo "" && \

echo "[5/9] Reading flow values from org..." && \
export SF_CC_PLACEHOLDER_FLOW_AGENT_ID=$(sf data query --query "SELECT Id from BotDefinition WHERE DeveloperName='Coral_Cloud_Agent'" --json | grep -o '"Id": "[^"]*' | cut -d'"' -f4) && \
export SF_CC_PLACEHOLDER_FLOW_CHANNEL_ID=$(sf data query --query "SELECT Id from ServiceChannel WHERE DeveloperName='sfdc_livemessage'" --json | grep -o '"Id": "[^"]*' | cut -d'"' -f4) && \
export SF_CC_PLACEHOLDER_FLOW_QUEUE_ID=$(sf data query --query "SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Messaging Queue'" --json | grep -o '"Id": "[^"]*' | cut -d'"' -f4)
EXIT_CODE="$?"
# Check exit code
echo ""
if [ "$EXIT_CODE" -ne 0 ]; then
  echo "Installation failed."
  exit $EXIT_CODE
fi
# Check retrieved values
if [ -z "${SF_CC_PLACEHOLDER_FLOW_AGENT_ID}" ] || [ "${SF_CC_PLACEHOLDER_FLOW_AGENT_ID}" = "DummyForInitialDeploy" ]; then
    echo "Installation failed: could not retrieve agent ID."
    exit 1
fi
echo "- Agent ID: $SF_CC_PLACEHOLDER_FLOW_AGENT_ID"
if [ -z "${SF_CC_PLACEHOLDER_FLOW_CHANNEL_ID}" ] || [ "${SF_CC_PLACEHOLDER_FLOW_CHANNEL_ID}" = "DummyForInitialDeploy" ]; then
    echo "Installation failed: could not retrieve channel ID."
    exit 1
fi
echo "- Channel ID: $SF_CC_PLACEHOLDER_FLOW_CHANNEL_ID"
if [ -z "${SF_CC_PLACEHOLDER_FLOW_QUEUE_ID}" ] || [ "${SF_CC_PLACEHOLDER_FLOW_QUEUE_ID}" = "DummyForInitialDeploy" ]; then
    echo "Installation failed: could not retrieve queue ID."
    exit 1
fi
echo "- Queue ID: $SF_CC_PLACEHOLDER_FLOW_QUEUE_ID"

echo "[6/9] Redeploying flow metadata with org-specific values..." && \
sf project deploy start -c -d cc-service-app/main/default/flows/Route_to_Agent.flow-meta.xml cc-service-app/main/default/flows/Route_to_Queue.flow-meta.xml && \
echo "" && \

echo "[7/9] Publishing Experience Cloud site..." && \
sf community publish --name 'coral cloud' && \
echo "" && \

echo "[8/9] Deploying guest profile for Experience Cloud site..." && \
sf project deploy start --metadata-dir=guest-profile-metadata -w 10 && \
echo "" && \

echo "[9/9] Activate messaging channel..." && \
sf apex run -f apex-scripts/activate-messaging-channel.apex && \
echo "" && \

echo "Opening org..." && \
sf org open -p /lightning/setup/EmbeddedServiceDeployments/home && \
echo ""
EXIT_CODE="$?"

# Check exit code
echo ""
if [ "$EXIT_CODE" -eq 0 ]; then
  echo "Installation completed."
  echo ""
  echo "Experience Cloud URL: https://${SF_CC_PLACEHOLDER_DOMAIN}.develop.my.site.com/"
  echo ""
else
    echo "Installation failed."
fi
exit $EXIT_CODE
