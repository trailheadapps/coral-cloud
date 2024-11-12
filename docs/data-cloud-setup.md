# Data Cloud deployment and configuration

1. Install automatically some of the components (Amazon S3 connection and data streams) from the Data Kit thanks to the [Data Kit component deployment flow](https://developer.salesforce.com/docs/platform/data-cloud-dev/guide/dc-deploy_data_kit_components.html):

    ```bash
    sf api request rest '/services/data/v62.0/actions/custom/flow/sfdatakit__DeployDataKitComponents' --method POST --body @config/data-kit-deploy.json
    sf api request rest '/services/data/v62.0/ssot/datakit/Coral_Cloud_Data_Kit_Sample_App?asyncMode=true' --method POST --body @config/data-kit-set-s3-credentials.json
    ```

1. Refresh the Guest data stream:

    1. In App Launcher, select the **Data Cloud** app and open the **Data Streams** tab.
    1. Locate the **Guest** data stream (notice that a timestamp is appended to the name of the stream, this is expected) and select **Refresh Now** from the row actions.
    1. Select **Refresh Only New Files** from the row actions.
    1. Click **Refresh Now**.

1. Refresh Reservation data stream:

    1. From the **Data Streams** tab, click the **Reservation** data stream with the timestamp suffix.
    1. Select **Refresh Now** from the row actions.
    1. Select **Refresh Only New Files** from the row actions.
    1. Click **Refresh Now**.

1. Map the Reservation data stream:

    1. From the **Reservation** data stream view, click **Review** in the **Data Mapping** panel.
    1. Click the pencil icon next to the "Data Model entities" panel header.
    1. Click the **Custom Data Model** tab.
    1. Click **New Custom Object**.
    1. Clear the timestamps suffix from the Object Label and Object API Name so that both are named `Reservation`.
    1. Click **Save**.
    1. Click **Save & Close**.

1. Create the Reservations-to-Individual relationship

    1. From the **Data Model** tab, click the **Reservation** Data Model Object (DMO).
    1. Click the **Relationships** tab.
    1. Click **New**.
    1. Click the **+ New Relationship** button.
    1. Configure your relationship as follows:

        | **Field**      | **Value**       |
        | -------------- | --------------- |
        | Field          | `Contact ID`    |
        | Cardinality    | `N:1`           |
        | Related Object | `Individual`    |
        | Related Field  | `Individual Id` |

    1. Click **Save & Close**.

1. Deploy a CRM data stream from the Data Kit:

    1. From the **Data Streams** tab, click **New**.
    1. Under **Connected Sources**, select the **Salesforce CRM** connector, and click **Next**.
    1. Under **Custom Data Bundles**, select **Salesforce_Contacts**, and click **Next**.
    1. Keep the default selection and click **Next**.
    1. Click **Deploy**.
    1. After the deployment, click the down caret icon to the right of the **Contact_Home** Data Stream row, and select **Refresh Now**.

1. Deploy and run an identity resolution ruleset from the Data Kit:

    1. From the **Identity Resolution** tab, click **New**.
    1. Select the **Install from Data Kit** and click **Next**.
    1. Select the **Guest Name and Email** and click **Next**.
    1. Keep the default selection and click **Save**.
    1. Click **Run Ruleset**.

1. Deploy a calculated insight from the Data Kit:

    1. From the **Calculated Insights** tab, click **New**.
    1. Select **Create from a Data Kit** and click **Next**.
    1. Select **Spend Profile by Guest** and click **Next**.
    1. Click **Save**.
    1. Keep the default name and click **Next**.
    1. Leave the Schedule field value to **Not Scheduled** and click **Enable**.
    1. Click **Publish Now** from the top actions in the upper right corner. If it's not visible, click the caret down button to expand the action list.

## Optional: Access Unified Data from Salesforce

1. Add a Data Cloud related list to the Contact object

    1. From Salesforce **Setup**, open the **Object Manager**.
    1. Select the **Contact** object.
    1. Go to the **Data Cloud Related List** tab.
    1. Click **New**.
    1. Under **Data Cloud Object**, select **Reservation** and click **Next**.
    1. Keep the default values and click **Next**.
    1. Change the Related list label to `Reservations` (plural).
    1. Check the **Contact Layout** checkbox.
    1. Check the Add related list to users’ existing record page customizations checkbox.
    1. Click **Next**.

1. Add the Related List to the Contact page layout

    1. From the **Object Manager**, click **Page Layouts** in the left sidebar.
    1. Click **Contact Layout**.
    1. Scroll to the bottom of the page layout until you see the **Reservations** related list.
    1. Click the wrench icon.
    1. Add the following fields to the Selected Fields:
        - Reservation ID
        - Check-in Date
        - Check-out Date
        - Total Price
    1. Click **OK** to save your field selection.
    1. Click **Save** to save your changes to the Contact layout.
    1. In the **Coral Cloud Resorts** app, navigate to the Contact record page for Sofia Rodriguez.
    1. Refresh the page.
    1. Click the **Related** tab.
    1. Make sure that you can see the Reservations related list.

## Optional: Access Calculated Insights in Salesforce

1. Modify the "Data Cloud Admin" permission set

    1. Open Salesforce Setup.
    1. Search for and open **Permission Sets**.
    1. Click the **Data Cloud Admin** permission set.
    1. In the Apps section, click **Data Cloud Data Space Management**.
    1. In the Data Spaces panel, click **Edit**.
    1. Check the **Enabled** checkbox for the **default** data space and click **Save**.
    1. Click **OK** in the confirmation dialog.

1. Modify the "Customer 360 Data Platform Integration" permission set

    1. From **Permission Sets**, select the **Customer 360 Data Platform Integration** permission set.
    1. In the Apps section, click **Object Settings**.
    1. Click **Contacts**.
    1. Click the **Edit** button.
    1. Check the **Modify All** checkbox. This automatically checks the Delete checkbox as well.
    1. Scroll down the page into the **Field Permissions** section and check the **Edit Access** checkbox for the **Lifetime Reservations** and **Lifetime Value** fields.
    1. Scroll back up to the top and click **Save**.

1. Create a Data Cloud Copy Field Enrichment in Salesforce

    1. From the **Object Manager**, select the **Contact** object.
    1. Go to the **Data Cloud Copy Field** tab.
    1. Click **New**.
    1. In the **Data Cloud Object** field, select the **Spend Profile By Guest** calculated insight, and click **Next**.
    1. Select the **Lifetime Reservations** and **Lifetime Value** fields, and click **Next**.
    1. Change the Label to `Spend Profile By Guest` (remove `default`), and click **Next**.
    1. In the Field Mapping tab, apply the following mapping:

        | **Data Cloud: Spend Profile By Guest** | →   | **Contact**           |
        | -------------------------------------- | --- | --------------------- |
        | Lifetime Reservations                  | →   | Lifetime Reservations |
        | Lifetime Value                         | →   | Lifetime Value        |

    1. Click **Save and Start Sync**.
    1. In the dialog box, click **Save and Start Sync**.

> [!TIP]
> This process can take up to 15 minutes to complete. You won't see data before.
