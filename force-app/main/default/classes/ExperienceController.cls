public with sharing class ExperienceController {
    /**
     * Endpoint that retrieves the sessions associated with an experience and a date
     * @param experienceId Experience ID
     * @param timestamp Timestamp representing the date on which the sessions take place
     * @return List of Session__c records
     */
    @AuraEnabled(cacheable=true scope='global')
    public static List<Session__c> getExperienceSessionsForDate(
        Id experienceId,
        Long timestamp
    ) {
        Date dateFilter = Datetime.newInstance(timestamp).date();
        List<Session__c> sessions = [
            SELECT
                Id,
                Booked_Slots__c,
                Capacity__c,
                End_Time__c,
                Percentage_Booked__c,
                Start_Time__c,
                Status__c
            FROM Session__c
            WHERE Experience__c = :experienceId AND Date__c = :dateFilter
            WITH SECURITY_ENFORCED
            ORDER BY Start_Time__c ASC
            LIMIT 10
        ];
        return sessions;
    }

    /**
     * Retrieves a list of Session__c records that match a Contact's interests for today's date.
     * This method looks for sessions where the Experience Type matches any of the three interests
     * specified in the Contact record.
     *
     * @param contact The Contact record whose interests are used to filter sessions.
     * @return List<Session__c> A list of up to 10 Session__c records matching the Contact's interests.
     */
    public static List<Session__c> getSessions(Contact contact) {
        // Get contact interests and ignore null values
        Set<String> contactInterests = new Set<String>{
            contact.Interest1__c,
            contact.Interest2__c,
            contact.Interest3__c
        };
        contactInterests.remove(null);
        // Get relevant sessions
        List<Session__c> experienceSessions = [
            SELECT
                Experience_Name__c,
                Date__c,
                Start_Time__c,
                Duration_Hours__c,
                Location__c
            FROM Session__c
            WHERE
                Experience__r.Type__c IN :contactInterests
                AND Date__c = TODAY
                AND Is_Canceled__c = FALSE
            WITH SECURITY_ENFORCED
            ORDER BY Start_Time__c ASC
            LIMIT 10
        ];
        return experienceSessions;
    }
}
