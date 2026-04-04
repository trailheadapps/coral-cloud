public with sharing class ListExperienceTypes {
    @InvocableMethod(
        label='List Experience Types'
        description='Returns a list of all available experience types'
    )
    public static List<ActionOutput> getExperienceTypes(
        List<ActionInput> inputs
    ) {
        // Get picklist values
        Schema.DescribeFieldResult fieldResult = Experience__c.Type__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();

        // Prepare the type list
        List<String> experienceTypes = new List<String>();
        for (Schema.PicklistEntry entry : picklistValues) {
            if (entry.isActive()) {
                experienceTypes.add(entry.getLabel());
            }
        }

        ActionOutput output = new ActionOutput();
        output.experienceTypes = JSON.serialize(experienceTypes);
        // Prepare the responses
        List<ActionOutput> outputs = new List<ActionOutput>();
        for (ActionInput input : inputs) {
            outputs.add(output);
        }
        return outputs;
    }

    public class ActionOutput {
        @InvocableVariable(
            label='Experience Types'
            description='The list of available experience types'
        )
        public String experienceTypes;
    }

    public class ActionInput {
        /*
         * This input is not used, but it is required to make the method invocable.
         */
        @InvocableVariable(
            label='Unused dummy input'
            description='This input is not used, but it is required to make the method invocable.'
        )
        public String dummyInput;
    }
}
