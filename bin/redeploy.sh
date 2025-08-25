#!/bin/bash
SCRIPT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd $SCRIPT_PATH/..

echo ""
echo "Redeploying Coral Cloud"
echo ""

# Get env variables
echo "[1/2] Getting env variables..."
export SF_CC_PLACEHOLDER_USERNAME=$(sf org display --json | grep -o '"username": "[^"]*' | cut -d'"' -f4)
export SF_CC_PLACEHOLDER_DOMAIN=$(sf org display --json | grep -o '"instanceUrl": "https[^"]*' | cut -d'"' -f4 | sed -E 's|https?://([^\.]+).*|\1|')
export SF_CC_PLACEHOLDER_FLOW_AGENT_ID=$(sf data query --query "SELECT Id from BotDefinition WHERE DeveloperName='Coral_Cloud_Agent'" --json | grep -o '"Id": "[^"]*' | cut -d'"' -f4) && \
export SF_CC_PLACEHOLDER_FLOW_CHANNEL_ID=$(sf data query --query "SELECT Id from ServiceChannel WHERE DeveloperName='sfdc_livemessage'" --json | grep -o '"Id": "[^"]*' | cut -d'"' -f4) && \
export SF_CC_PLACEHOLDER_FLOW_QUEUE_ID=$(sf data query --query "SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Messaging Queue'" --json | grep -o '"Id": "[^"]*' | cut -d'"' -f4)

echo "Username:     $SF_CC_PLACEHOLDER_USERNAME"
echo "Domain:       $SF_CC_PLACEHOLDER_DOMAIN"
echo "Agent ID:     $SF_CC_PLACEHOLDER_FLOW_AGENT_ID"
echo "Channel ID:   $SF_CC_PLACEHOLDER_FLOW_CHANNEL_ID"
echo "Queue ID:     $SF_CC_PLACEHOLDER_FLOW_QUEUE_ID"

# Redeploy metadata
echo ""
echo "[1/2] Deploying metadata..."
sf project deploy start -c -w 10
