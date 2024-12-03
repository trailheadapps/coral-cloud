public with sharing class DataTreeImporter {
    static String githubContacts = 'https://raw.githubusercontent.com/trailheadapps/coral-cloud/main/data/data-Contact.json';
    static String githubExperience = 'https://raw.githubusercontent.com/trailheadapps/coral-cloud/main/data/data-Experience__c.json';
    static String githubGuestReview = 'https://raw.githubusercontent.com/trailheadapps/coral-cloud/main/data/data-Guest_Review__c.json';
    static String githubCase = 'https://raw.githubusercontent.com/trailheadapps/coral-cloud/main/data/data-Case.json';

    public class SObjectTree {
        public List<SObject> records;
    }

    @AuraEnabled
    public static void importData() {
        try {
            // Parse JSON data into a list of ObjectData
            List<Contact> contacts = (List<Contact>) fetchJsonFromGitHub(
                githubContacts
            );

            List<Experience__c> experiences = (List<Experience__c>) fetchJsonFromGitHub(
                githubExperience
            );

            List<Guest_Review__c> reviews = (List<Guest_Review__c>) fetchJsonFromGitHub(
                githubGuestReview
            );
            List<Case> cases = (List<Case>) fetchJsonFromGitHub(githubCase);

            insert as user contacts;
            insert as user experiences;

            Experience__c experience = [
                SELECT Id
                FROM Experience__c
                WHERE Name = 'Tropical Snorkel Adventure'
            ];

            List<Guest_Review__c> newReviews = new List<Guest_Review__c>();
            for (Guest_Review__c review : reviews) {
                review.Experience__c = experience.Id;
                review.Contact__c = contacts[0].Id;
                newReviews.add(review);
            }
            insert as user newReviews;

            Contact cont = [
                SELECT Id
                FROM Contact
                WHERE LastName = 'Rodriguez'
            ];
            for (Case c : cases) {
                c.ContactId = cont.Id;
            }
            insert as user cases;

            System.debug('Data import completed successfully!');
        } catch (Exception e) {
            System.debug('Error during data import: ' + e.getMessage());
        }
    }

    private static List<sObject> fetchJsonFromGitHub(String url) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            SObjectTree treeData = (SObjectTree) JSON.deserialize(
                res.getBody(),
                SObjectTree.class
            );

            // Parse JSON data into a list of ObjectData
            List<sObject> records = treeData.records;
            return records;
        } else {
            throw new CalloutException(
                'Failed to fetch JSON data. Status: ' + res.getStatus()
            );
        }
    }
}
