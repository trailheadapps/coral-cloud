public with sharing class ContextService {
    @AuraEnabled(cacheable=true)
    public static Boolean isCommunity() {
        Id siteId = Site.getSiteId();
        return siteId != null;
    }
}
