public with sharing class SetupServiceAgentUser {
    public static void setup() {
        Profile p = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Einstein Agent User'
            LIMIT 1
        ];

        User u = new user();
        u.LastName = 'Coral Cloud Agent User';
        u.Email = '%%SF_CC_PLACEHOLDER_USERNAME%%';
        u.Alias = 'ccagent';
        u.Username = 'agent-%%SF_CC_PLACEHOLDER_USERNAME%%';
        u.CommunityNickname = 'ccagent';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileID = p.id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        insert u;

        List<PermissionSetLicense> psls = [
            SELECT Id
            FROM PermissionSetLicense
            WHERE
                DeveloperName = 'AgentforceServiceAgentUserPsl'
                OR DeveloperName = 'GenieDataPlatformStarterPsl'
        ];

        List<PermissionSetLicenseAssign> pslas = new List<PermissionSetLicenseAssign>();

        for (PermissionSetLicense psl : psls) {
            PermissionSetLicenseAssign psla = new PermissionSetLicenseAssign();
            psla.AssigneeId = u.Id;
            psla.PermissionSetLicenseId = psl.Id;
            pslas.add(psla);
        }

        insert pslas;

        List<PermissionSet> pss = [
            SELECT Id
            FROM PermissionSet
            WHERE
                Name = 'AgentforceServiceAgentUser'
                OR Name = 'GenieUserEnhancedSecurity'
                OR Name = 'Coral_Cloud_Service_Agent'
        ];

        List<PermissionSetAssignment> psaas = new List<PermissionSetAssignment>();

        for (PermissionSet ps : pss) {
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = u.Id;
            psa.PermissionSetId = ps.Id;
            psaas.add(psa);
        }

        upsert psaas;
    }
}
