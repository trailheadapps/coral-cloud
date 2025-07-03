public with sharing class SetupServiceAgentUser {
    private final static String USERNAME = Test.isRunningTest()
        ? 'agent-user@mock.com'
        : 'agent-%%SF_CC_PLACEHOLDER_USERNAME%%';
    private final static String NICKNAME = Test.isRunningTest()
        ? 'ccagent-mock'
        : 'ccagent';

    @TestVisible
    private final static Set<String> PERM_SET_LICENSES = new Set<String>{
        'AgentforceServiceAgentUserPsl',
        'GenieDataPlatformStarterPsl'
    };

    private final static Set<String> PERM_SETS = new Set<String>{
        'AgentforceServiceAgentUser',
        'GenieUserEnhancedSecurity',
        'Coral_Cloud_Service_Agent'
    };

    public static void setup() {
        // Check all security permissions upfront
        checkSecurityAccess();

        // Get agent profile
        Profile p = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Einstein Agent User'
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        // Create user or use existing one
        User u;
        List<User> users = [
            SELECT Id
            FROM User
            WHERE Username = :USERNAME
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        if (users.size() == 0) {
            u = new user();
            u.LastName = 'Coral Cloud Agent User';
            u.Email = USERNAME;
            u.Alias = 'ccagent';
            u.Username = USERNAME;
            u.CommunityNickname = NICKNAME;
            u.LocaleSidKey = 'en_US';
            u.TimeZoneSidKey = 'GMT';
            u.ProfileID = p.id;
            u.LanguageLocaleKey = 'en_US';
            u.EmailEncodingKey = 'UTF-8';
            insert as user u;
            System.debug('Created user: ' + u.Username);
        } else {
            System.debug('Skipped user creation');
            u = users[0];
        }

        // Get permission set licenses (PSL)
        Set<Id> targetPslIds = getPermissionSetLicenseIds();

        // Exclude already assigned PSLs
        List<PermissionSetLicenseAssign> userPslas = [
            SELECT PermissionSetLicenseId
            FROM PermissionSetLicenseAssign
            WHERE AssigneeId = :u.Id AND PermissionSetLicenseId IN :targetPslIds
            WITH SECURITY_ENFORCED
        ];
        Set<Id> userPslIds = new Set<Id>();
        for (PermissionSetLicenseAssign userPsla : userPslas) {
            userPslIds.add(userPsla.PermissionSetLicenseId);
        }
        targetPslIds.removeAll(userPslIds);

        // Assign PSLs to user
        if (targetPslIds.size() > 0) {
            List<PermissionSetLicenseAssign> pslas = new List<PermissionSetLicenseAssign>();
            for (Id pslId : targetPslIds) {
                PermissionSetLicenseAssign psla = new PermissionSetLicenseAssign();
                psla.AssigneeId = u.Id;
                psla.PermissionSetLicenseId = pslId;
                pslas.add(psla);
            }
            insert as user pslas;
            System.debug(
                'Assigned permission set licenses: ' + PERM_SET_LICENSES
            );
        } else {
            System.debug('Skipped permission set license assignment.');
        }

        // Get permission sets (PS)
        Set<Id> targetPsIds = new Map<Id, PermissionSet>(
                [
                    SELECT Id
                    FROM PermissionSet
                    WHERE Name IN :PERM_SETS
                    WITH SECURITY_ENFORCED
                ]
            )
            .keySet();

        // Exclude already assigned PSs
        List<PermissionSetAssignment> userPsas = [
            SELECT PermissionSetId
            FROM PermissionSetAssignment
            WHERE AssigneeId = :u.Id AND PermissionSetId IN :targetPsIds
            WITH SECURITY_ENFORCED
        ];
        Set<Id> userPsIds = new Set<Id>();
        for (PermissionSetAssignment userPsa : userPsas) {
            userPsIds.add(userPsa.PermissionSetId);
        }
        targetPsIds.removeAll(userPsIds);
        // Assign PSs to user
        if (targetPsIds.size() > 0) {
            List<PermissionSetAssignment> psaas = new List<PermissionSetAssignment>();
            for (Id psId : targetPsIds) {
                PermissionSetAssignment psa = new PermissionSetAssignment();
                psa.AssigneeId = u.Id;
                psa.PermissionSetId = psId;
                psaas.add(psa);
            }
            insert as user psaas;
            System.debug('Assigned permission set: ' + PERM_SETS);
        } else {
            System.debug('Skipped permission set assignment.');
        }
    }

    @TestVisible
    private static void checkSecurityAccess() {
        // Check CRUD permissions for Profile
        if (!Schema.sObjectType.Profile.isAccessible()) {
            throw new SecurityException(
                'Insufficient permissions to access Profile'
            );
        }

        // Check CRUD permissions for User
        if (
            !Schema.sObjectType.User.isAccessible() ||
            !Schema.sObjectType.User.isCreateable()
        ) {
            throw new SecurityException(
                'Insufficient permissions to access or create User'
            );
        }

        // Check CRUD permissions for PermissionSetLicense
        if (!Schema.sObjectType.PermissionSetLicense.isAccessible()) {
            throw new SecurityException(
                'Insufficient permissions to access PermissionSetLicense'
            );
        }

        // Check CRUD permissions for PermissionSetLicenseAssign
        if (
            !Schema.sObjectType.PermissionSetLicenseAssign.isAccessible() ||
            !Schema.sObjectType.PermissionSetLicenseAssign.isCreateable()
        ) {
            throw new SecurityException(
                'Insufficient permissions to access or create PermissionSetLicenseAssign'
            );
        }

        // Check CRUD permissions for PermissionSet
        if (!Schema.sObjectType.PermissionSet.isAccessible()) {
            throw new SecurityException(
                'Insufficient permissions to access PermissionSet'
            );
        }

        // Check CRUD permissions for PermissionSetAssignment
        if (
            !Schema.sObjectType.PermissionSetAssignment.isAccessible() ||
            !Schema.sObjectType.PermissionSetAssignment.isCreateable()
        ) {
            throw new SecurityException(
                'Insufficient permissions to access or create PermissionSetAssignment'
            );
        }
    }

    @TestVisible
    private static Set<Id> getPermissionSetLicenseIds() {
        return new Map<Id, PermissionSetLicense>(
                [
                    SELECT Id
                    FROM PermissionSetLicense
                    WHERE DeveloperName IN :PERM_SET_LICENSES
                    WITH SECURITY_ENFORCED
                ]
            )
            .keySet();
    }
}
