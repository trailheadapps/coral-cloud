# Coral Cloud TDX26 Demo Setup Instructions

This branch is a "fork" of the main Coral Cloud sample app specifically designed for a TDX 26 demo.

Here are the instruction to create a scratch org for the demo:

## Setup Requirements

- Salesforce CLI configured with a DevHub
- [jq](https://jqlang.org/). You can install it with Hombrew via this command: `brew install jq`

## Setup Instructions

1. Run the setup script:

    ```sh
    ./bin/install.sh
    ```

2. Got to **Agentforce Studio > Tests** and create a new Test Suite with these settings:

    | Field                        | Value                                                |
    | ---------------------------- | ---------------------------------------------------- |
    | Test Name                    | Customer Service Agent Tests                         |
    | Agent to test                | Customer Service Agent                               |
    | Include conversation history | Checked                                              |
    | Include context variables    | Checked                                              |
    | Context variables            | Verified Customer Id<br/>Is Verified Customer        |
    | Test data                    | `custom_service_agent_tests.csv` file from this repo |
    | Evaluations                  | Check all                                            |
