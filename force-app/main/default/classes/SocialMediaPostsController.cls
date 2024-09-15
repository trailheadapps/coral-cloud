public with sharing class SocialMediaPostsController {
    @AuraEnabled
    public static String generateSocialMediaPosts(String experienceSessionId) {
        // Create inputs
        ConnectApi.WrappedValue experienceSessionValue = new ConnectApi.WrappedValue();
        experienceSessionValue.value = new Map<String, String>{
            'id' => experienceSessionId
        };
        Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>{
            'Input:experienceSession' => experienceSessionValue
        };

        // Configure invocation parameters
        ConnectApi.EinsteinPromptTemplateGenerationsInput executeTemplateInput = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
        executeTemplateInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
        executeTemplateInput.additionalConfig.applicationName = 'PromptBuilderPreview';
        executeTemplateInput.isPreview = false;
        executeTemplateInput.inputParams = inputParams;

        // Call the service
        ConnectApi.EinsteinPromptTemplateGenerationsRepresentation generationsOutput = ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(
            'Generate_Social_Media_Posts',
            executeTemplateInput
        );
        ConnectApi.EinsteinLLMGenerationItemOutput response = generationsOutput.generations[0];
        return response.text;
    }
}
