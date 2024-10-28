/**
 * ExperienceSessionController provides methods to fetch Experience Sessions related to a Contact's interests.
 *
 * This class is designed to support fetching sessions that match any of the specified interests
 * of a contact on the current date. The sessions are limited to 10 to ensure performance and relevance.
 */
public with sharing class ExperienceSessionController {
    /**
     * Retrieves a list of Session__c records that match a Contact's interests for today's date.
     * This method looks for sessions where the Experience Type matches any of the three interests
     * specified in the Contact record.
     *
     * @param contact The Contact record whose interests are used to filter sessions.
     * @return List<Session__c> A list of up to 10 Session__c records matching the Contact's interests.
     */
    public static List<Session__c> getSessions(Contact contact) {
        List<Session__c> experienceSessions = [
            SELECT
                Experience_Name__c,
                Date__c,
                Start_Time__c,
                Duration_Hours__c,
                Location__c
            FROM Session__c
            WHERE
                (Experience__r.Type__c = :contact.Interest1__c
                OR Experience__r.Type__c = :contact.Interest2__c
                OR Experience__r.Type__c = :contact.Interest3__c)
                AND Date__c = TODAY
                AND Is_Canceled__c = FALSE
            WITH USER_MODE
            ORDER BY Start_Time__c ASC
            LIMIT 10
        ];
        return experienceSessions;
    }
}
