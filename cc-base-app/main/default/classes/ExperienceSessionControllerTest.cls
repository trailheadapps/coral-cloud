@isTest
private class ExperienceSessionControllerTest {
    @IsTest
    static void testGetSessions() {
        // Create test data
        Experience__c experience = new Experience__c(
            Name = 'Test Experience',
            Type__c = 'Adventure Activities'
        );
        insert experience;

        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            Interest1__c = 'Adventure Activities'
        );
        insert testContact;

        Session__c testSession = new Session__c(
            Experience__c = experience.Id,
            Date__c = Date.today(),
            Start_Time__c = Time.newInstance(9, 0, 0, 0),
            Is_Canceled__c = false
        );
        insert testSession;

        // Run test
        List<Session__c> experienceSessions = ExperienceSessionController.getSessions(
            [
                SELECT Id, Interest1__c, Interest2__c, Interest3__c
                FROM Contact
                WHERE FirstName = 'Test'
                LIMIT 1
            ]
        );
        Assert.areEqual(
            1,
            experienceSessions.size(),
            'Expected exactly one session to be returned'
        );
        Assert.areEqual(
            'Test Experience',
            experienceSessions[0].Experience_Name__c,
            'Expected session name to be "Test Experience"'
        );
    }
}
