public without sharing class CreateBooking {
    @InvocableMethod(
        label='Book Session'
        description='Books a session for the customer.'
    )
    public static List<Response> bookSession(List<Request> requests) {
        List<Response> responses = new List<Response>();
        for (Request req : requests) {
            Booking__c booking = new Booking__c(
                Contact__c = req.contactId,
                Session__c = req.sessionId,
                Number_of_Guests__c = req.numberOfGuests
            );
            insert as system booking;

            Booking__c created = [
                SELECT Id, Experience_Name__c, Date__c
                FROM Booking__c
                WHERE Id = :booking.Id
                LIMIT 1
            ];

            Response res = new Response();
            res.createdBooking = JSON.serialize(created);
            responses.add(res);
        }
        return responses;
    }

    public class Request {
        @InvocableVariable(
            required=true
            label='Contact ID'
            description='The contact ID of the customer.'
        )
        public String contactId;

        @InvocableVariable(
            required=true
            label='Session ID'
            description='The session ID to book.'
        )
        public String sessionId;

        @InvocableVariable(
            required=true
            label='Number of Guests'
            description='The number of guests to book the session for.'
        )
        public Double numberOfGuests;
    }

    public class Response {
        @InvocableVariable(
            label='Created Booking'
            description='The created booking, serialized as a JSON string.'
        )
        public String createdBooking;
    }
}
