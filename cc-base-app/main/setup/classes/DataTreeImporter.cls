public with sharing class DataTreeImporter {
    private static final String GITHUB_BASE_URL = 'https://raw.githubusercontent.com/trailheadapps/coral-cloud/main/data';

    @TestVisible
    private static final String GITHUB_CONTACTS_URL =
        GITHUB_BASE_URL + '/data-Contact.json';
    @TestVisible
    private static final String GITHUB_EXPERIENCE_URL =
        GITHUB_BASE_URL + '/data-Experience__c.json';
    @TestVisible
    private static final String GITHUB_GUEST_REVIEW_URL =
        GITHUB_BASE_URL + '/data-Guest_Review__c.json';
    @TestVisible
    private static final String GITHUB_CASE_URL =
        GITHUB_BASE_URL + '/data-Case.json';

    public class SObjectTree {
        public List<SObject> records;
    }

    @AuraEnabled
    public static void importData() {
        try {
            // Check Experience__c CRUD permissions
            if (!Schema.sObjectType.Experience__c.isAccessible()) {
                throw new SecurityException(
                    'Insufficient permissions to access Experience__c'
                );
            }
            // Check Contact CRUD permissions
            if (!Schema.sObjectType.Contact.isAccessible()) {
                throw new SecurityException(
                    'Insufficient permissions to access Contact'
                );
            }

            // Parse JSON data into a list of ObjectData
            List<Contact> contacts = (List<Contact>) fetchJsonFromGitHub(
                GITHUB_CONTACTS_URL
            );
            System.debug('Loaded ' + contacts.size() + ' contacts from GitHub');

            List<Experience__c> experiences = (List<Experience__c>) fetchJsonFromGitHub(
                GITHUB_EXPERIENCE_URL
            );
            System.debug(
                'Loaded ' + experiences.size() + ' experiences from GitHub'
            );

            List<Guest_Review__c> reviews = (List<Guest_Review__c>) fetchJsonFromGitHub(
                GITHUB_GUEST_REVIEW_URL
            );
            System.debug('Loaded ' + reviews.size() + ' reviews from GitHub');

            List<Case> cases = (List<Case>) fetchJsonFromGitHub(
                GITHUB_CASE_URL
            );
            System.debug('Loaded ' + cases.size() + ' cases from GitHub');

            insert as user contacts;
            insert as user experiences;

            Experience__c experience = [
                SELECT Id
                FROM Experience__c
                WHERE Name = 'Tropical Snorkel Adventure'
                WITH USER_MODE
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
                WITH USER_MODE
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
