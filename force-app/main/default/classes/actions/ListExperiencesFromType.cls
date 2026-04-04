public with sharing class ListExperiencesFromType {
    @InvocableMethod(
        label='List Experiences from Type'
        description='Returns a list of experiences based on their type'
    )
    public static List<ActionOutput> getExperiencesFromType(
        List<ActionInput> inputs
    ) {
        List<ActionOutput> outputs = new List<ActionOutput>();
        for (ActionInput input : inputs) {
            // Get the experience type from the input
            String type = '%' + input.experienceType.toLowerCase().trim() + '%';
            // Fetch experiences records
            List<Experience__c> experiences = [
                SELECT Id, Name, Picture_URL__c, Description__c
                FROM Experience__c
                WHERE Type__c LIKE :type
                WITH SYSTEM_MODE
            ];
            // Prepare the response
            ActionOutput output = new ActionOutput();
            output.experiences = JSON.serialize(experiences);
            outputs.add(output);
        }
        return outputs;
    }

    public class ActionInput {
        @InvocableVariable(
            label='Experience Type'
            description='The type of experience to list'
            required=true
        )
        public String experienceType;
    }

    public class ActionOutput {
        @InvocableVariable(
            label='Experiences'
            description='The list of experiences of the given type'
        )
        public String experiences;
    }
}
