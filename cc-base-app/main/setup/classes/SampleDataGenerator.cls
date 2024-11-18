public with sharing class SampleDataGenerator {
    private static final List<Time> SESSION_TIMES = new List<Time>{
        Time.newInstance(9, 0, 0, 0),
        Time.newInstance(13, 30, 0, 0)
    };

    private static final Integer SESSION_BATCH_SIZE = 500;
    @TestVisible
    private static final Integer FUTURE_DAYS_COVERED = 4;
    @TestVisible
    private static final Integer PAST_DAYS_COVERED = 1;

    @AuraEnabled
    public static Id generateData() {
        // Remove current sessions and bookings
        delete [SELECT Id FROM Booking__c];
        delete [SELECT Id FROM Session__c];

        // Get existing contacts and experiences
        List<Contact> contacts = [SELECT Id FROM Contact];
        List<Experience__c> experiences = [
            SELECT Id, Capacity__c
            FROM Experience__c
        ];
        // Check for exisisting data
        if (contacts.size() == 0 || experiences.size() == 0) {
            throw new SampleDataGeneratorException(
                'Failed to find contact and/org experience records. Did you load the sample data plan first?'
            );
        }

        // Generate new sessions
        List<Session__c> sessions = generateSessions(experiences);
        insert as user sessions;

        // Generate bookings in batch to avoid hitting DML limits
        SampleBookingBatch sampleBooking = new SampleBookingBatch(
            experiences,
            sessions,
            contacts
        );
        Id batchProcessId = Database.executeBatch(
            sampleBooking,
            SESSION_BATCH_SIZE
        );
        return batchProcessId;
    }

    private static Integer getRandomInteger(Integer min, Integer max) {
        Double rand = min + (Math.random() * (max - min));
        return Integer.valueOf(rand);
    }

    private static List<Session__c> generateSessions(
        List<Experience__c> experiences
    ) {
        List<Session__c> sessions = new List<Session__c>();
        for (Experience__c experience : experiences) {
            Date sessionDate = Date.today().addDays(0 - PAST_DAYS_COVERED);
            for (
                Integer d = 0; d < PAST_DAYS_COVERED + FUTURE_DAYS_COVERED; d++
            ) {
                sessionDate = sessionDate.addDays(1);
                Integer sessionCountForThisDay = getRandomInteger(
                    1,
                    SESSION_TIMES.size()
                );
                for (Integer t = 0; t < sessionCountForThisDay; t++) {
                    Time sessionTime = SESSION_TIMES[t];
                    Session__c session = new Session__c();
                    session.Date__c = sessionDate;
                    session.Experience__c = experience.Id;
                    session.Start_Time__c = sessionTime;
                    sessions.add(session);
                }
            }
        }
        return sessions;
    }

    public class SampleDataGeneratorException extends Exception {
    }
}
