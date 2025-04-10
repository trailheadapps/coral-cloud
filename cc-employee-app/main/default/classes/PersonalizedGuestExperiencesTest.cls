@IsTest
private class PersonalizedGuestExperiencesTest {
    @IsTest
    static void testGetSessions_Success() {
        // Create test contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Guest',
            Email = 'test@example.com'
        );
        insert testContact;

        // Create test request
        PersonalizedGuestExperiences.Request request = new PersonalizedGuestExperiences.Request();
        request.myContact = testContact;

        // Start test execution context
        Test.startTest();
        List<PersonalizedGuestExperiences.Response> responses = PersonalizedGuestExperiences.getSessions(
            new List<PersonalizedGuestExperiences.Request>{ request }
        );
        Test.stopTest();

        // Verify response
        Assert.areEqual(1, responses.size(), 'Should return one response');
        Assert.isNotNull(responses[0].Prompt, 'Prompt should not be null');
    }
}
