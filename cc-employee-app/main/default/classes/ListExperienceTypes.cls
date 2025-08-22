public with sharing class ListExperienceTypes {
    @InvocableMethod(
        label='List Experience Types'
        description='Returns a list of all available experience types'
    )
    public static List<ExperienceTypeOutput> getExperienceTypes(
        List<ExperienceTypeInput> inputs
    ) {
        // Get picklist values
        Schema.DescribeFieldResult fieldResult = Experience__c.Type__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();

        // Prepare the type list
        ExperienceTypeOutput typeList = new ExperienceTypeOutput();
        for (Schema.PicklistEntry entry : picklistValues) {
            if (entry.isActive()) {
                typeList.experienceTypes.add(
                    new ExperienceTypeItem(entry.getLabel())
                );
            }
        }

        // Prepare the responses
        List<ExperienceTypeOutput> typeOutput = new List<ExperienceTypeOutput>();
        for (ExperienceTypeInput input : inputs) {
            typeOutput.add(typeList);
        }
        return typeOutput;
    }

    public class ExperienceTypeOutput {
        @InvocableVariable(
            label='Experience Types'
            description='The list of available experience types'
        )
        public List<ExperienceTypeItem> experienceTypes;

        public ExperienceTypeOutput() {
            this.experienceTypes = new List<ExperienceTypeItem>();
        }
    }

    public class ExperienceTypeInput {
        /*
         * This input is not used, but it is required to make the method invocable.
         */
        @InvocableVariable(
            label='Unused dummy input'
            description='This input is not used, but it is required to make the method invocable.'
        )
        public String dummyInput;
    }

    public class ExperienceTypeItem {
        public String itemName;

        public ExperienceTypeItem(String itemName) {
            this.itemName = itemName;
        }
    }
}
