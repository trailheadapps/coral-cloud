@isTest
private class ExperienceControllerTest {
    @isTest
    static void getExperienceSessionsForDate_works() {
        Experience__c experience = new Experience__c(
            Name = 'Sample experience'
        );
        insert experience;

        Datetime refTime = Datetime.newInstance(2024, 7, 19, 11, 0, 0);
        Datetime dayBefore = refTime.addDays(-1);
        Datetime dayAfter = refTime.addDays(1);

        List<Session__c> allSessions = new List<Session__c>{
            new Session__c(
                Experience__c = experience.Id,
                Date__c = dayBefore.date(),
                Start_Time__c = dayBefore.time()
            ),
            new Session__c(
                Experience__c = experience.Id,
                Date__c = refTime.date(),
                Start_Time__c = refTime.time()
            ),
            new Session__c(
                Experience__c = experience.Id,
                Date__c = dayAfter.date(),
                Start_Time__c = dayAfter.time()
            ),
            new Session__c(
                Experience__c = experience.Id,
                Date__c = refTime.date(),
                Start_Time__c = refTime.addHours(-2).time()
            )
        };
        insert allSessions;

        Test.startTest();
        List<Session__c> todaySessions = ExperienceController.getExperienceSessionsForDate(
            experience.Id,
            refTime.getTime()
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
}
