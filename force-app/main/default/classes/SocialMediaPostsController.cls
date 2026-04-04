public with sharing class SocialMediaPostsController {
    @AuraEnabled
    public static String generateSocialMediaPosts(String experienceSessionId) {
        // Create inputs
        Map<String, String> experienceSession = new Map<String, String>();
        experienceSession.put('id', experienceSessionId);
        ConnectApi.WrappedValue experienceSessionValue = new ConnectApi.WrappedValue();
        experienceSessionValue.value = experienceSession;
        Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();
        inputParams.put('Input:experienceSession', experienceSessionValue);

        // Configure invocation parameters
        ConnectApi.EinsteinPromptTemplateGenerationsInput executeTemplateInput = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
        executeTemplateInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
        executeTemplateInput.additionalConfig.applicationName = 'PromptBuilderPreview';
        executeTemplateInput.isPreview = false;
        executeTemplateInput.inputParams = inputParams;
        return runPrompTemplate(executeTemplateInput);
    }

    private static String runPrompTemplate(
        ConnectApi.EinsteinPromptTemplateGenerationsInput executeTemplateInput
    ) {
        // Connect API is not available in test context so we'll fake the response
        if (Test.isRunningTest()) {
            ConnectApi.WrappedValue wrappedVal = executeTemplateInput.inputParams.get(
                'Input:experienceSession'
            );
            Map<String, String> params = (Map<String, String>) wrappedVal.value;
            return 'Fake call with ' + params.get('id');
        }
        // Generate the response based on the prompt template
        ConnectApi.EinsteinPromptTemplateGenerationsRepresentation generationsOutput = ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(
            'Generate_Social_Media_Posts',
            executeTemplateInput
        );
        ConnectApi.EinsteinLLMGenerationItemOutput response = generationsOutput.generations[0];
        return response.text;
    }
}
