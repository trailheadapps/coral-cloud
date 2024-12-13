@isTest
private class CommunitiesLandingControllerTest {
    @isTest
    static void getResortWeather_works() {
        CommunitiesLandingController ctrl = new CommunitiesLandingController();
        PageReference ref = ctrl.forwardToStartPage();
        Assert.isNotNull(ref);
    }
}
