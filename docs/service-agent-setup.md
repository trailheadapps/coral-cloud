# Agentforce Service Agent setup and configuration

For the deployment of the Agentforce Service Agent it is necessary that certain values in the metadata are replaced with record ids from the used org. To achieve this during source deployment this project makes use of the [string replacement functionality of the Salesforce CLI](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_string_replace.htm). For this certain values will be exported as environment variables.

1. Export the org alias of the current org as environment variable.

    **macOS/Linux (Bash):**

    ```bash
    export SF_CC_PLACEHOLDER_USERNAME=$(sf org display --json | grep -o '"username": "[^"]*' | cut -d'"' -f4)
    ```

    **Windows (PowerShell):**

    ```powershell
    $SF_CC_PLACEHOLDER_USERNAME = (sf org display --json | ConvertFrom-Json).result.username
    ```

1. Export the first part of the subdomain of the current org as environment variable.

    **macOS/Linux (Bash):**

    ```bash
    export SF_CC_PLACEHOLDER_DOMAIN=$(sf org display --json | grep -o '"instanceUrl": "https[^"]*' | cut -d'"' -f4 | sed -E 's|https?://([^\.]+).*|\1|')
    ```

    **Windows (PowerShell):**

    ```powershell
    $SF_CC_PLACEHOLDER_DOMAIN = ((sf org display --json | ConvertFrom-Json).result.instanceUrl -replace 'https?://', '') -split '\.' | Select-Object -First 1
    ```

1. Deploy metadata for automating the setup of the Agentforce Service Agent technical user.

    ```bash
    sf project deploy start -d cc-service-app/main/setup/classes/SetupServiceAgentUser.cls -d cc-service-app/main/default/permissionSets/Coral_Cloud_Service_Agent.permissionset-meta.xml
    ```

1. Set up the Agentforce Service Agent user.

    ```bash
    sf apex run -f apex-scripts/setup-agent-user.apex
    ```

1. Export dummy environment variables.

    **macOS/Linux (Bash):**

    ```bash
    export SF_CC_PLACEHOLDER_FLOW_AGENT_ID="DummyForInitialDeploy"
    export SF_CC_PLACEHOLDER_FLOW_CHANNEL_ID="DummyForInitialDeploy"
    export SF_CC_PLACEHOLDER_FLOW_QUEUE_ID="DummyForInitialDeploy"
    ```

    **Windows (PowerShell):**

    ```powershell
    $env:SF_CC_PLACEHOLDER_FLOW_AGENT_ID = "DummyForInitialDeploy"
    $env:SF_CC_PLACEHOLDER_FLOW_CHANNEL_ID = "DummyForInitialDeploy"
    $env:SF_CC_PLACEHOLDER_FLOW_QUEUE_ID = "DummyForInitialDeploy"
    ```

1. Deploy the app metadata.

    ```bash
    sf project deploy start -d cc-service-app

    ```

1. Replace previously exported dummy variables with values from the org.

    **macOS/Linux (Bash):**

    ```bash
    export SF_CC_PLACEHOLDER_FLOW_AGENT_ID=$(sf data query --query "SELECT Id from BotDefinition WHERE DeveloperName='Coral_Cloud_Agent'" --json | grep -o '"Id": "[^"]*' | cut -d'"' -f4)
    export SF_CC_PLACEHOLDER_FLOW_CHANNEL_ID=$(sf data query --query "SELECT Id from ServiceChannel WHERE DeveloperName='sfdc_livemessage'" --json | grep -o '"Id": "[^"]*' | cut -d'"' -f4)
    export SF_CC_PLACEHOLDER_FLOW_QUEUE_ID=$(sf data query --query "SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Messaging Queue'" --json | grep -o '"Id": "[^"]*' | cut -d'"' -f4)
    ```

    **Windows (PowerShell):**

    ```powershell
    $SF_CC_PLACEHOLDER_FLOW_AGENT_ID = (sf data query --query "SELECT Id from BotDefinition WHERE DeveloperName='Coral_Cloud_Agent'" --json | ConvertFrom-Json).result.records[0].Id
    $SF_CC_PLACEHOLDER_FLOW_CHANNEL_ID = (sf data query --query "SELECT Id from ServiceChannel WHERE DeveloperName='sfdc_livemessage'" --json | ConvertFrom-Json).result.records[0].Id
    $SF_CC_PLACEHOLDER_FLOW_QUEUE_ID = (sf data query --query "SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Messaging Queue'" --json | ConvertFrom-Json).result.records[0].Id
    ```

1. Redeploy flow metadata with org specific values.

    ```bash
    sf project deploy start -d cc-service-app/main/default/flows/Route_to_Agent.flow-meta.xml cc-service-app/main/default/flows/Route_to_Agent.flow-meta.xml
    ```

1. Publish Experience Cloud site.

    ```bash
    sf community publish --name 'coral cloud'
    ```

1. Deploy guest profile for Experience Cloud site.

    ```bash
    sf project deploy start --metadata-dir=guest-profile-metadata -w 10
    ```

1. Launch the org on the Messaging Settings setup page.

    ```bash
    sf org open -p /lightning/setup/LiveMessageSetup/home
    ```

1. Ensure that **Messaging** is toggled on.

1. Click on the same page on **Agent Channel**, then click on **Activate**. Confirm the checkbox, and close the dialog with **Accept**.

1. From Salesforce Setup, search for "Embedded Service Deployments" and select **Embedded Service Deployments**.

1. Select **Agent Web Deployment**, then click on **Publish** (it may take a few seconds for the confirmation to show up on screen).

1. From Salesforce Setup, search for "Agents" and select **Agents**.

1. Select **Coral Cloud Agent**, then click on **Open in Builder**.

1. Click **Activate**.

1. Click back in your browser.

1. Click on the App Launcher and enter **coral cloud**. Click on **coral cloud** to launch the Experience Cloud site.

    ![](/docs/gfx/app-launcher-ec.png)
