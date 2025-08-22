public with sharing class ListExperiencesFromType {
    @InvocableMethod(
        label='List Experiences from Type'
        description='Returns a list of experiences based on their type'
    )
    public static List<ExperienceListWrapper> getExperiencesFromType(
        List<ExperienceTypeInput> experienceTypeInputs
    ) {
        List<ExperienceListWrapper> experienceWrappers = new List<ExperienceListWrapper>();
        for (ExperienceTypeInput experienceTypeInput : experienceTypeInputs) {
            // Get the experience type from the input
            String type =
                '%' +
                experienceTypeInput.type.toLowerCase().trim() +
                '%';
            // Fetch experiences records
            List<Experience__c> experiences = [
                SELECT Id, Name, Picture_URL__c
                FROM Experience__c
                WHERE Type__c LIKE :type
                WITH SYSTEM_MODE
            ];
            // Prepare the response
            ExperienceListWrapper experienceListWrapper = new ExperienceListWrapper();
            for (Experience__c experience : experiences) {
                experienceListWrapper.experiences.add(
                    new ExperienceItem(
                        experience.Name,
                        experience.Picture_URL__c,
                        'image/jpeg'
                    )
                );
            }
            experienceWrappers.add(experienceListWrapper);
        }
        return experienceWrappers;
    }

    public class ExperienceTypeInput {
        @InvocableVariable(
            label='Experience Type'
            description='The type of experience to list'
            required=true
        )
        public String type;
    }

    public class ExperienceListWrapper {
        @InvocableVariable(
            label='Experiences'
            description='The list of experiences of the given type'
        )
        public List<ExperienceItem> experiences;

        public ExperienceListWrapper() {
            this.experiences = new List<ExperienceItem>();
        }
    }

    public class ExperienceItem {
        public String name;
        public String imageUrl;
        public String mimeType;

        public ExperienceItem(String name, String imageUrl, String mimeType) {
            this.name = name;
            this.imageUrl = imageUrl;
            this.mimeType = mimeType;
        }
    }
}
