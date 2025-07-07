@IsTest
private class SetupServiceAgentUserTest {
    private final static String USERNAME = 'agent-user@mock.com';
    private final static String NICKNAME = 'ccagent-mock';

    @IsTest
    static void testSetup_NewUser() {
        // Given
        // No existing user with the test username

        // When
        Test.startTest();
        SetupServiceAgentUser.setup();
        Test.stopTest();

        // Then
        List<User> createdUsers = [
            SELECT Id, Username, LastName, Email, ProfileId, CommunityNickname
            FROM User
            WHERE CommunityNickname = :NICKNAME
        ];
        Assert.areEqual(1, createdUsers.size(), 'Should create one user');
        User createdUser = createdUsers[0];
        Assert.areEqual(
            'Coral Cloud Agent User',
            createdUser.LastName,
            'Last name should match'
        );
        Assert.areEqual(USERNAME, createdUser.Email, 'Email should match');

        // Verify permission set license assignments
        List<PermissionSetLicenseAssign> pslAssignments = [
            SELECT Id
            FROM PermissionSetLicenseAssign
            WHERE AssigneeId = :createdUser.Id
        ];
        Integer expectedPslCount = SetupServiceAgentUser.getPermissionSetLicenseIds()
            .size();
        Assert.areEqual(expectedPslCount, pslAssignments.size());

        // Verify permission set assignments
        List<PermissionSetAssignment> psAssignments = [
            SELECT Id
            FROM PermissionSetAssignment
            WHERE AssigneeId = :createdUsers[0].Id
        ];
        Assert.isTrue(
            psAssignments.size() >= 3,
            'Should have at least 3 PS assignments'
        );
    }

    @IsTest
    static void testSetup_ExistingUser() {
        // Given
        // Create an existing user
        Profile p = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Einstein Agent User'
            LIMIT 1
        ];
        User existingUser = new User(
            LastName = 'Existing User',
            Email = USERNAME,
            Alias = 'existing',
            Username = USERNAME,
            CommunityNickname = 'existing',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'GMT',
            ProfileID = p.Id,
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8'
        );
        insert existingUser;

        // When
        Test.startTest();
        SetupServiceAgentUser.setup();
        Test.stopTest();

        // Then
        List<User> users = [
            SELECT Id, LastName
            FROM User
            WHERE Username = :USERNAME
        ];
        Assert.areEqual(1, users.size(), 'Should still have one user');
        Assert.areEqual(
            'Existing User',
            users[0].LastName,
            'Should not modify existing user'
        );
    }

    @IsTest
    static void testCheckSecurityAccess_NoAccess() {
        // Given
        Profile p = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Standard User'
            LIMIT 1
        ];
        User testUser = new User(
            LastName = 'Existing User',
            Email = USERNAME,
            Alias = 'existing',
            Username = USERNAME,
            CommunityNickname = 'existing',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'GMT',
            ProfileID = p.Id,
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8'
        );
        insert testUser;

        System.runAs(testUser) {
            // When/Then
            try {
                SetupServiceAgentUser.checkSecurityAccess();
                Assert.fail('Expected SecurityException');
            } catch (SecurityException e) {
                Assert.isTrue(
                    e.getMessage().contains('Insufficient permissions'),
                    'Should throw security exception'
                );
            }
        }
    }
}
