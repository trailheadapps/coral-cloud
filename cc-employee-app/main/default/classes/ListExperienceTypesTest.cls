@IsTest
private class ListExperienceTypesTest {
    @IsTest
    static void testGetListExperienceTypes_Success() {
        // Prepare test input
        List<ListExperienceTypes.ExperienceTypeInput> inputs = new List<ListExperienceTypes.ExperienceTypeInput>{
            new ListExperienceTypes.ExperienceTypeInput()
        };

        // Execute the method
        Test.startTest();
        List<ListExperienceTypes.ExperienceTypeOutput> results = ListExperienceTypes.getExperienceTypes(
            inputs
        );
        Test.stopTest();

        // Verify results
        Assert.isNotNull(results, 'Results should not be null');
        Assert.isTrue(results.size() > 0, 'Should return at least one result');

        ListExperienceTypes.ExperienceTypeOutput result = results[0];
        Assert.isNotNull(result, 'First result should not be null');
        Assert.isNotNull(
            result.experienceTypes,
            'Experience types list should not be null'
        );
        Assert.isTrue(
            result.experienceTypes.size() > 0,
            'Should return at least one experience type'
        );

        // Verify that we have some of the expected types
        Set<String> types = new Set<String>();
        for (
            ListExperienceTypes.ExperienceTypeItem item : result.experienceTypes
        ) {
            types.add(item.itemName);
        }
        Assert.isTrue(
            types.contains('Adventure Activities'),
            'Should contain Adventure Activities type'
        );
        Assert.isTrue(
            types.contains('Beaches & Snorkeling'),
            'Should contain Beaches & Snorkeling type'
        );
    }
}
