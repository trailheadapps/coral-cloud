@IsTest
private class SocialMediaPostsControllerTest {
    @IsTest
    static void testGenerateSocialMediaPosts_Success() {
        // Given
        String mockSessionId = 'mockSessionId';

        // When
        String result = SocialMediaPostsController.generateSocialMediaPosts(
            mockSessionId
        );

        // Then
        Assert.areEqual('Fake call with ' + mockSessionId, result);
    }
}
