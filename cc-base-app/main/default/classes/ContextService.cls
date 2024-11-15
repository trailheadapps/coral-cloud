public with sharing class ContextService {
    /**
     * Checks whether the component is displayed within an Experience Cloud site.
     */
    @AuraEnabled(cacheable=true)
    public static Boolean isCommunity() {
        Id siteId = Site.getSiteId();
        return siteId != null;
    }
}
