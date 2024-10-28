#!/bin/bash
SCRIPT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd $SCRIPT_PATH/..

echo ""
echo "Installing Coral Cloud - Service"
echo ""

# Get default org alias
VALUE_REGEX='"value": "([a-zA-Z0-9_\-]+)"'
ORG_INFO=$(sf config get target-org --json)
if [[ $ORG_INFO =~ $VALUE_REGEX ]]
then
    ORG_ALIAS="${BASH_REMATCH[1]}"
    echo "Using current default org: $ORG_ALIAS"
    echo "Exporting org alias and subdomain for use in scripts."
    export SF_CC_PLACEHOLDER_USERNAME=$(sf org display --json |  jq -r '.result | .username')
    echo "Username: $SF_CC_PLACEHOLDER_USERNAME"
    export SF_CC_PLACEHOLDER_DOMAIN=$(sf org display --json | jq -r '.result | .instanceUrl | sub("https?://"; "") | split(".")[0]')
    echo "Domain: $SF_CC_PLACEHOLDER_DOMAIN"    
    echo ""
else
    echo "Installation failed: could not retrieve default org alias."
    exit 1
fi

echo "Pushing Service Agent Setup source..." && \
sf project deploy start -d cc-service-app/main/setup/classes/SetupServiceAgentUser.cls -d cc-service-app/main/default/permissionSets/Coral_Cloud_Service_Agent.permissionset-meta.xml && \
echo "" && \

echo "Setting up Service Agent user..." && \
sf apex run -f apex-scripts/setup-agent-user.apex && \
echo "" && \

echo "Pushing source..." && \
export SF_CC_PLACEHOLDER_FLOW_AGENT_ID="DummyForInitialDeploy" && \
export SF_CC_PLACEHOLDER_FLOW_CHANNEL_ID="DummyForInitialDeploy" && \
export SF_CC_PLACEHOLDER_FLOW_QUEUE_ID="DummyForInitialDeploy" && \
sf project deploy start -d cc-service-app && \
echo "" && \

echo "Redeploying flow metadata with org specific values..." && \
export SF_CC_PLACEHOLDER_FLOW_AGENT_ID=$(sf data query --query "SELECT Id from BotDefinition WHERE DeveloperName='Coral_Cloud_Agent'" --json | jq -r '.result | .records[0] | .Id') && \
echo "Agent ID: $SF_CC_PLACEHOLDER_FLOW_AGENT_ID" && \
export SF_CC_PLACEHOLDER_FLOW_CHANNEL_ID=$(sf data query --query "SELECT Id from ServiceChannel WHERE DeveloperName='sfdc_livemessage'" --json | jq -r '.result | .records[0] | .Id') && \
echo "Channel ID: $SF_CC_PLACEHOLDER_FLOW_CHANNEL_ID" && \
export SF_CC_PLACEHOLDER_FLOW_QUEUE_ID=$(sf data query --query "SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Messaging Queue'" --json | jq -r '.result | .records[0] | .Id') && \
echo "Queue ID: $SF_CC_PLACEHOLDER_FLOW_QUEUE_ID" && \
sf project deploy start -d cc-service-app/main/default/flows/Route_to_Agent.flow-meta.xml cc-service-app/main/default/flows/Route_to_Queue.flow-meta.xml && \
echo "" && \

echo "Publishing Experience Cloud site..." && \
sf community publish --name 'coral cloud' && \
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
  echo "Experience Cloud URL: https://${SF_CC_PLACEHOLDER_DOMAIN}.develop.my.site.com/"
  echo ""
else
    echo "Installation failed."
fi
exit $EXIT_CODE
