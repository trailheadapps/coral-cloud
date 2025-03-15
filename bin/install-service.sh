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
    echo "Exporting org alias and subdomain for use in scripts:"
    export SF_CC_PLACEHOLDER_USERNAME=$(sf org display --json | grep -o '"username": "[^"]*' | cut -d'"' -f4)
    echo "- Username: $SF_CC_PLACEHOLDER_USERNAME"
    export SF_CC_PLACEHOLDER_DOMAIN=$(sf org display --json | grep -o '"instanceUrl": "https[^"]*' | cut -d'"' -f4 | sed -E 's|https?://([^\.]+).*|\1|')
    echo "- Domain:   $SF_CC_PLACEHOLDER_DOMAIN"    
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
export SF_CC_PLACEHOLDER_FLOW_AGENT_ID=$(sf data query --query "SELECT Id from BotDefinition WHERE DeveloperName='Coral_Cloud_Agent'" --json | grep -o '"Id": "[^"]*' | cut -d'"' -f4) && \
echo "Agent ID: $SF_CC_PLACEHOLDER_FLOW_AGENT_ID" && \
export SF_CC_PLACEHOLDER_FLOW_CHANNEL_ID=$(sf data query --query "SELECT Id from ServiceChannel WHERE DeveloperName='sfdc_livemessage'" --json | grep -o '"Id": "[^"]*' | cut -d'"' -f4) && \
echo "Channel ID: $SF_CC_PLACEHOLDER_FLOW_CHANNEL_ID" && \
export SF_CC_PLACEHOLDER_FLOW_QUEUE_ID=$(sf data query --query "SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Messaging Queue'" --json | grep -o '"Id": "[^"]*' | cut -d'"' -f4) && \
echo "Queue ID: $SF_CC_PLACEHOLDER_FLOW_QUEUE_ID" && \
sf project deploy start -d cc-service-app/main/default/flows/Route_to_Agent.flow-meta.xml cc-service-app/main/default/flows/Route_to_Queue.flow-meta.xml && \
echo "" && \

echo "Publishing Experience Cloud site..." && \
sf community publish --name 'coral cloud' && \
echo "" && \

echo "Deploying guest profile for Experience Cloud site..." && \
sf project deploy start --metadata-dir=guest-profile-metadata -w 10 && \
echo "" && \

echo "Opening org..." && \
sf org open -p /lightning/setup/LiveMessageSetup/home && \
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
