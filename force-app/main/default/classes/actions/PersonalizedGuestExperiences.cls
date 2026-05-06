public with sharing class PersonalizedGuestExperiences {
    // Make this method available for grounding
    // the Generate_Personalized_Schedule prompt template
    @InvocableMethod(
        label='Get sessions of interest for today'
        description='Get today\'s sessions that match the user\'s interests.'
    )
    public static List<Response> getSessions(List<Request> requests) {
        Id contactId = requests[0].contactId;

        Contact contact = [
            SELECT Id, Name, Interest1__c, Interest2__c, Interest3__c
            FROM Contact
            WHERE Id = :contactId
            WITH USER_MODE
        ];

        Recommendations recommendations = new Recommendations();
        recommendations.preferences = new List<String>{
            contact.Interest1__c,
            contact.Interest2__c,
            contact.Interest3__c
        };
        recommendations.sessions = ExperienceSessionController.getSessions(
            contact
        );

        // Create expected response
        List<Response> responses = new List<Response>();
        Response res = new Response();
        res.sessions = JSON.serialize(recommendations);
        responses.add(res);
        return responses;
    }

    // The variables in this class need to match the prompt template inputs,
    // that may be different on each prompt template
    public class Request {
        @InvocableVariable(required=true description='The guest (Contact) ID')
        public String contactId;
    }

    public class Response {
        @InvocableVariable
        public String sessions;
    }

    private class Recommendations {
        public List<String> preferences;
        public List<Session__c> sessions;
    }
}
