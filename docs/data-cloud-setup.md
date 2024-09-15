# Data Cloud deployment and configuration

1. Install automatically some of the components (Amazon S3 connection and data streams) from the Data Kit thanks to the [Data Kit component deployment flow](https://developer.salesforce.com/docs/platform/data-cloud-dev/guide/dc-deploy_data_kit_components.html):

    ```bash
    sf api request rest actions/custom/flow/sfdatakit__DeployDataKitComponents --method POST --body config/data-kit-deploy.json
    ```

1. Configure the credentials for the Amazon S3 read-only connection that you deployed above:

    1. Open the **Setup Menu** and select **Data Cloud Setup**.
    1. In the left sidebar, click **Other Connectors**.
    1. Open the **Coral Cloud S3 Connection** and click **Edit**.
    1. Update the following values:

        | **Field**             | **Value**                                  |
        | --------------------- | ------------------------------------------ |
        | AWS access key        | `AKIA47CRZ7L5P7VBV3LD`                     |
        | AWS secret access key | `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` |

    1. Click **Test Connection** to validate the connection.
    1. Click **Save**

1. Refresh the Guest data stream:

    1. In App Launcher, select the **Data Cloud** app and open the **Data Streams** tab.
    1. Locate the **Guest** data stream (notice that a timestamp is appended to the name of the stream, this is expected) and select **Refresh Now** from the row actions.
    1. Select **Refresh Only New Files** from the row actions.
    1. Click **Refresh Now**.

1. Refresh and map the Reservation data stream:

    1. From the **Data Streams** tab, click the **Reservation** data stream with the timestamp suffix.
    1. Select **Refresh Now** from the row actions.
    1. Select **Refresh Only New Files** from the row actions.
    1. Click **Refresh Now**.
    1. Click **Start** in the **Data Mapping** panel.
    1. In the Data Model entities panel, click **Select Objects**.
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
    1. After the deployment, click the arrow down icon to the right of the **Contact_Home** Data Stream row, and select **Refresh Now**.

1. Deploy and run an identity resolution ruleset from the Data Kit:

    1. From the **Identity Resolution** tab, click **New**.
    1. Select the **Install from Data Kit** and click **Next**.
    1. Select the **Guest Name and Email** and click **Next**.
    1. Keep the default selection and click **Save**.
    1. Click **Run Ruleset**.

1. Deploy a calculated insight from the Data Kit:

    1. From the **Calculated Insights** tab, click **New**.
    1. Select the **Create from a Data Kit** and click **Next**.
    1. Select the **Spend Profile by Guest** and click **Next**.
    1. Click **Save**.
    1. Keep the default name and click **Next**.
    1. Leave the Schedule field value to **Not Scheduled** and click **Enable**.
    1. Click **Publish Now** from the top actions in the upper right corner. If it's not visible, click the arrow down button to expand the action list.

That's it congratulations, you've installed the Coral Cloud Resorts sample app!
