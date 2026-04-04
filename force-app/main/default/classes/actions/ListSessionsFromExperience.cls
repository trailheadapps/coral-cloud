public with sharing class ListSessionsFromExperience {
    @InvocableMethod(
        label='List Sessions from Experience'
        description='Returns a list of sessions for a specific experience'
    )
    public static List<ActionOutput> getSessionsFromExperience(
        List<ActionInput> inputs
    ) {
        List<ActionOutput> outputs = new List<ActionOutput>();
        for (ActionInput input : inputs) {
            String experienceName =
                '%' +
                input.experienceName.toLowerCase().trim() +
                '%';

            List<Session__c> sessions = [
                SELECT
                    Id,
                    Experience_Name__c,
                    Date__c,
                    Start_Time__c,
                    End_Time__c,
                    Duration_Hours__c,
                    Location__c,
                    Available_Slots__c
                FROM Session__c
                WHERE
                    Experience_Name__c LIKE :experienceName
                    AND Is_Canceled__c = FALSE
                    AND Date__c >= TODAY
                WITH SYSTEM_MODE
                ORDER BY Date__c ASC, Start_Time__c ASC
                LIMIT 5
            ];

            ActionOutput output = new ActionOutput();
            output.sessions = JSON.serialize(sessions);
            outputs.add(output);
        }
        return outputs;
    }

    public class ActionInput {
        @InvocableVariable(
            label='Experience Name'
            description='The experience name used to list sessions'
            required=true
        )
        public String experienceName;
    }

    public class ActionOutput {
        @InvocableVariable(
            label='Sessions'
            description='The list of sessions for the given experience'
        )
        public String sessions;
    }
}
