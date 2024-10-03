@isTest
private class SampleDataTest {
    private static final Decimal SESSION_CAPACITY = 100;

    @isTest
    static void generateData_works() {
        List<Contact> contacts = getMockContacts(20);
        insert contacts;
        List<Experience__c> experiences = getMockExperiences(1);
        insert experiences;
        List<Session__c> initialSessions = getMockSessions(experiences, 1);
        insert initialSessions;

        Test.startTest();
        SampleDataGenerator.generateData();
        Test.stopTest();

        // Check that previous session was removed
        Assert.areEqual(
            0,
            [SELECT Id FROM Session__c WHERE Id = :initialSessions[0].Id].size()
        );
        // Check for the right amount of new sessions
        List<Session__c> sessions = [SELECT Date__c FROM Session__c];
        Assert.isTrue(sessions.size() > 0, 'Expected some new sessions');
        // Check that the right amout of days are covered
        Set<Date> daysCovered = new Set<Date>();
        for (Session__c session : sessions) {
            daysCovered.add(session.Date__c);
        }
        Assert.areEqual(
            SampleDataGenerator.PAST_DAYS_COVERED +
            SampleDataGenerator.FUTURE_DAYS_COVERED,
            daysCovered.size(),
            'Expected sessions to cover all days'
        );
    }

    @isTest
    static void generateData_fails_when_base_data_is_missing() {
        Test.startTest();
        try {
            SampleDataGenerator.generateData();
            Assert.fail('Expected SampleDataGeneratorException');
        } catch (Exception e) {
            Assert.isInstanceOfType(
                e,
                SampleDataGenerator.SampleDataGeneratorException.class
            );
            Assert.isTrue(e.getMessage().contains('Failed to find contact'));
        }
        Test.stopTest();
    }

    @isTest
    static void sampleBookingBatch_works() {
        List<Contact> contacts = getMockContacts(20);
        insert contacts;
        List<Experience__c> experiences = getMockExperiences(1);
        insert experiences;
        List<Session__c> sessions = getMockSessions(experiences, 3);
        insert sessions;

        Test.startTest();
        SampleBookingBatch batch = new SampleBookingBatch(
            experiences,
            sessions,
            contacts
        );
        Database.executeBatch(batch);
        Test.stopTest();

        List<Booking__c> bookings = [
            SELECT Session__c, Number_of_Guests__c
            FROM Booking__c
        ];
        Map<Id, Decimal> sessionGuests = new Map<Id, Decimal>();
        for (Booking__c booking : bookings) {
            Decimal guestCount = sessionGuests.get(booking.Session__c);
            if (guestCount == null) {
                guestCount = 0;
            }
            guestCount += booking.Number_of_Guests__c;
            sessionGuests.put(booking.Session__c, guestCount);
        }
        Assert.areEqual(
            sessions.size(),
            sessionGuests.size(),
            'Expected bookings to cover all sessions'
        );
        for (Id sessionId : sessionGuests.keySet()) {
            Decimal guestCount = sessionGuests.get(sessionId);
            Assert.isTrue(
                guestCount >=
                SESSION_CAPACITY * SampleBookingBatch.MIN_SESSION_FILL_PERCENT,
                'Expected guests count to be greater or equal to min fill target'
            );
            Assert.isTrue(
                guestCount <=
                SESSION_CAPACITY * SampleBookingBatch.MAX_SESSION_FILL_PERCENT,
                'Expected guests count to be lower or equal to max fill target'
            );
        }
    }

    private static List<Contact> getMockContacts(Integer count) {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < count; i++) {
            contacts.add(
                new Contact(FirstName = 'fn' + i, LastName = 'ln' + i)
            );
        }
        return contacts;
    }

    private static List<Experience__c> getMockExperiences(Integer count) {
        List<Experience__c> experiences = new List<Experience__c>();
        for (Integer i = 0; i < count; i++) {
            Experience__c experience = new Experience__c(Name = 'mockExp');
            experience.Name = 'activity' + i;
            experience.Activity_Level__c = 'Low';
            experience.Capacity__c = 100;
            experience.Default_Start_Time__c = Time.newInstance(0, 0, 0, 0);
            experience.Description__c = 'desc';
            experience.Duration_Hours__c = 1;
            experience.Location__c = 'Ocean Cruise';
            experience.Picture_URL__c = 'https://salesforce.com';
            experience.Price__c = 0;
            experience.Type__c = 'Nightlife & Entertainment';
            experiences.add(experience);
        }
        return experiences;
    }

    private static List<Session__c> getMockSessions(
        List<Experience__c> experiences,
        Integer count
    ) {
        List<Session__c> sessions = new List<Session__c>();
        for (Experience__c experience : experiences) {
            for (Integer i = 0; i < count; i++) {
                Session__c session = new Session__c();
                session.Date__c = Date.today();
                session.Experience__c = experience.Id;
                session.Start_Time__c = Time.newInstance(0, 0, 0, 0);
                sessions.add(session);
            }
        }
        return sessions;
    }
}
