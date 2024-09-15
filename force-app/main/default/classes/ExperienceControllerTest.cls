@isTest
private class ExperienceControllerTest {
    private static final Datetime REFERENCE_DATETIME = Datetime.newInstance(
        2024,
        7,
        19,
        11,
        0,
        0
    );

    @testSetup
    static void setup() {
        List<Experience__c> experiences = new List<Experience__c>{
            new Experience__c(
                Name = 'xp1',
                Type__c = 'Cultural Tours & Workshops'
            ),
            new Experience__c(
                Name = 'xp2',
                Type__c = 'Nightlife & Entertainment'
            )
        };
        insert experiences;

        Datetime dayBefore = REFERENCE_DATETIME.addDays(-1);
        Datetime dayAfter = REFERENCE_DATETIME.addDays(1);

        List<Session__c> allSessions = new List<Session__c>{
            new Session__c(
                Experience__c = experiences[0].Id,
                Date__c = dayBefore.date(),
                Start_Time__c = dayBefore.time()
            ),
            new Session__c(
                Experience__c = experiences[0].Id,
                Date__c = REFERENCE_DATETIME.date(),
                Start_Time__c = REFERENCE_DATETIME.time()
            ),
            new Session__c(
                Experience__c = experiences[0].Id,
                Date__c = dayAfter.date(),
                Start_Time__c = dayAfter.time()
            ),
            new Session__c(
                Experience__c = experiences[0].Id,
                Date__c = REFERENCE_DATETIME.date(),
                Start_Time__c = REFERENCE_DATETIME.addHours(-2).time()
            ),
            new Session__c(
                Experience__c = experiences[1].Id,
                Date__c = REFERENCE_DATETIME.date(),
                Start_Time__c = REFERENCE_DATETIME.addHours(-2).time()
            ),
            new Session__c(
                Experience__c = experiences[1].Id,
                Date__c = Date.today(),
                Start_Time__c = REFERENCE_DATETIME.addHours(-2).time()
            )
        };
        insert allSessions;
    }

    @isTest
    static void getExperienceSessionsForDate_works() {
        Experience__c experience = [
            SELECT Id
            FROM Experience__c
            WHERE Name = 'xp1'
        ];
        List<Session__c> allSessions = [SELECT Id FROM Session__c];

        Test.startTest();
        List<Session__c> todaySessions = ExperienceController.getExperienceSessionsForDate(
            experience.Id,
            REFERENCE_DATETIME.getTime()
        );
        Test.stopTest();

        Assert.areEqual(2, todaySessions.size());
        Assert.areEqual(
            allSessions[3].Id,
            todaySessions[0].Id,
            'Sessions are not ordered by start time'
        );
        Assert.areEqual(allSessions[1].Id, todaySessions[1].Id);
    }

    @isTest
    static void getSessions_works() {
        Contact contact = new Contact(
            FirstName = 'fn',
            LastName = 'ln',
            Interest1__c = 'Nightlife & Entertainment'
        );
        insert contact;

        Test.startTest();
        List<Session__c> sessions = ExperienceController.getSessions(contact);
        Test.stopTest();

        Assert.areEqual(1, sessions.size());
    }
}
