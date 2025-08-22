@IsTest
public class ListExperiencesFromTypeTest {
    @IsTest
    static void testListExperiencesFromType_Success() {
        // Create 2 adventure and 1 relaxation sample experience records
        List<Experience__c> sampleExperiences = new List<Experience__c>{
            new Experience__c(
                Name = 'Mountain Hiking',
                Type__c = 'Adventure',
                Picture_URL__c = 'https://example.com/hiking.jpg'
            ),
            new Experience__c(
                Name = 'Rock Climbing',
                Type__c = 'Adventure',
                Picture_URL__c = 'https://example.com/climbing.jpg'
            ),
            new Experience__c(
                Name = 'Spa Treatment',
                Type__c = 'Relaxation',
                Picture_URL__c = 'https://example.com/spa.jpg'
            )
        };
        insert sampleExperiences;

        // Prepare search for adventure experiences
        List<ListExperiencesFromType.ExperienceTypeInput> inputs = new List<ListExperiencesFromType.ExperienceTypeInput>();
        ListExperiencesFromType.ExperienceTypeInput input = new ListExperiencesFromType.ExperienceTypeInput();
        input.type = 'Adventure';
        inputs.add(input);

        Test.startTest();
        List<ListExperiencesFromType.ExperienceListWrapper> results = ListExperiencesFromType.getExperiencesFromType(
            inputs
        );
        Test.stopTest();

        // Verify results
        Assert.areEqual(1, results.size(), 'Should return one wrapper');
        Assert.areEqual(
            2,
            results[0].experiences.size(),
            'Should return 2 adventure experiences'
        );

        // Verify experience details
        ListExperiencesFromType.ExperienceItem firstExp = results[0]
            .experiences[0];
        Assert.areEqual(
            sampleExperiences[0].Name,
            firstExp.name,
            'First experience name should match'
        );
        Assert.areEqual(
            sampleExperiences[0].Picture_URL__c,
            firstExp.imageUrl,
            'Image URL should match'
        );
        Assert.areEqual(
            'image/jpeg',
            firstExp.mimeType,
            'MIME type should be image/jpeg'
        );
        Assert.areEqual(
            sampleExperiences[1].Name,
            results[0].experiences[1].name,
            'Second experience name should match'
        );
    }

    @IsTest
    static void testListExperiencesFromType_NoMatches() {
        // Test scenario with no matching experiences
        List<ListExperiencesFromType.ExperienceTypeInput> inputs = new List<ListExperiencesFromType.ExperienceTypeInput>();
        ListExperiencesFromType.ExperienceTypeInput input = new ListExperiencesFromType.ExperienceTypeInput();
        input.type = 'NonExistentType';
        inputs.add(input);

        Test.startTest();
        List<ListExperiencesFromType.ExperienceListWrapper> results = ListExperiencesFromType.getExperiencesFromType(
            inputs
        );
        Test.stopTest();

        // Verify results
        Assert.areEqual(1, results.size(), 'Should return one wrapper');
        Assert.areEqual(
            0,
            results[0].experiences.size(),
            'Should return empty experiences list'
        );
    }
}
