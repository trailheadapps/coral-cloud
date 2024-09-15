window.workshopData = {
  getData: function () {
    return [
      {
        name: "workshop-01",
        label: "Hands-on with Data Cloud",
        subtitle: "Workshop 1",
        link: "https://ai-data-workshop-74a31f4084a9.herokuapp.com/data-cloud.html",
        description:
          "Coral Cloud Resorts aims to consolidate and leverage customer data throughout the entire customer journey by utilizing Salesforce Data Cloud. The focus is on integrating diverse data sets to enable a holistic view of customer interactions, improve decision-making, and personalize the customer experience.",
          shortcuts: [
          {
            name:"shortcut-1",
            label: "Open Data Cloud Setup",
            iconName: "standard:settings",
            link: '/lightning/setup/SetupOneHome/home?setupApp=audience360'
          },
          {
            name:"shortcut-2",
            label: "Open the Data Cloud App",
            iconName: "standard:data_cloud",
            link: '/lightning/app/standard__Audience360/'
          }
          ],
          steps: [
        ]
      },
      {
        name: "workshop-02",
        label: "Hands-on with Prompt Builder",
        link: "https://ai-data-workshop-74a31f4084a9.herokuapp.com/prompt-builder.html",
        subtitle: "Workshop 2",
        description:
          "Coral Cloud would like to use Generative AI through Salesforce, but want to ensure that it is grounded in their customer data. Let's look at how you can use Prompt Builder to bring CRM and Data Cloud data securely into generative AI business workflows.",
        steps: [
          {
            name: "step-1",
            label: "Create a Sales Email Prompt Template",
            step: "Exercise 1 - Step 1",
            language: "text",
            prompt: 
              {
                label: "Prompt",
                body: `You're a receptionist for the Coral Cloud Resort hotel.
Your name is {!$Input:Sender.Name}, with phone {!$Input:Sender.Phone} and email {!$Input:Sender.Email}.
A guest has just checked-in, and you want to send them a welcome email.
                
Instructions:
                        
'''
Use clear, concise, and straightforward language using the active voice and strictly avoiding the use of filler words and phrases and redundant language.
Generate a subject line that can increase open rate using words and content that is related to the email body content.
Generate the body of the email, which will have the next format:

- First add a title that includes the name of the guest and welcomes them: {!$Input:Recipient.Name}.
- Find the current guest reservation, taking into account the checkin date: {!$Input:Guest_Event__c.CreatedDate}. These are the possible reservations: {!$RelatedList:Recipient.Reservations__r.Records}.
- Add a paragraph explaining the characteristics of the reservation, including its Check_in_Date__c, Check_out_Date__c, and Room_Type__c.
- Explain breakfast is available from 6 to 10 AM. Find in the reservation if it's included and add this information to the email, mentioning it can be included any time.
- Add the wifi network network: Coral_Cloud_Guests. Mention for password, guests will be prompted for their surname and room number.
- End the email by encouraging the guest to contact you if they have any inquiries.
'''

Now generate the welcome email to your guest.                
`
              }
          },
          {
            name: "step-2",
            label: "Create a Field Generation Prompt Template",
            step: "Exercise 2 - Step 1",
            language: "text",
            prompt: 
              {
                label: "Prompt",
               body: `You're a customer success manager for the Coral Cloud Resort hotel.

Instructions:

'''
Use clear, concise, and straightforward language using the active voice and strictly avoiding the use of filler words and phrases and redundant language.
- Generate a summary of the guest's likes and interests. These are the interests I've found: {!$Input:Contact.Interest1__c}, {!$Input:Contact.Interest2__c} and {!$Input:Contact.Interest3__c}.
'''

Now generate the summary.             
`
              },
            },
            {
              name: "step-3",
              label: "Ground the Prompt Template with Flow",
              step: "Exercise 2 - Step 3",
              language: "text",
              prompt: 
                {
                  label: "Prompt",
                 body: `You're a customer success manager for the Coral Cloud Resort hotel.

Instructions:

'''
Use clear, concise, and straightforward language using the active voice and strictly avoiding the use of filler words and phrases and redundant language.
- Generate a summary of the guest's likes and interests. These are the interests I've found:{!$Input:Contact.Interest1__c}, {!$Input:Contact.Interest2__c} and {!$Input:Contact.Interest3__c}.
- Add information of the experiences the guest may have interest in: {!$Flow:Get_Experiences_for_Contact_Interests.Prompt}. Use bullets or numbers to present the information clearly. 
'''

Now generate the summary.             
`
              },
        },
        {
          name: "step-4",
          label: "Create a Flex Template",
          step: "Exercise 3 - Step 1",
          language: "text",
          prompt: 
            {
              label: "Prompt",
             body: `You're a receptionist for {!$User.CompanyName}. Your name is {!$User.FirstName}.
Generate a report that shows Coral Cloud Resort hotel guests the different experiences that they can book during their stay.

Instructions:

'''
Use clear, concise, and straightforward language using the active voice and strictly avoiding the use of filler words and phrases and redundant language.
- Create a paragraph explaining that you'll present the different options available, introducing yourself to the guest, whose name is {!$Input:contact.Name}.
- Ask the guest to contact you if they have any questions, on the phone {!$User.MobilePhone}.
'''

Now generate the message.            
`
          },
    },
    {
      name: "step-5",
      label: "Ground the Prompt Template with Apex - Apex Class",
      step: "Exercise 3 - Step 2",
      language: "java",
      prompt: 
        {
          label: "Prompt",
         body: `public with sharing class GetExperienceInstances {
  // We activate this method to be available for grounding
  // the Generate_Experiences_Instances_Report prompt template
  @InvocableMethod(
    CapabilityType='FlexTemplate://Generate_Experiences_Instances_Report'
  )
  public static List<Response> getAvailableInstances(List<Request> requests) {
    Request input = requests[0];
    Contact contact = input.contact;

    // Query contact and reservations
    // Because we exposed Data Cloud reservations to the CRM through enrichment, we can query this way
    // If you need to query other Data Cloud records, use the Connect API or Direct API.
    contact = [
      SELECT
        Interest1__c,
        Interest2__c,
        Interest3__c,
        (
          SELECT Check_in_Date__c, Check_out_Date__c
          FROM Reservations__r
          WHERE Check_in_Date__c >= TODAY AND Check_out_Date__c > TODAY
        )
      FROM Contact
      WHERE Id = :contact.Id
    ];

    // Query possible experience instances
    sObject reservation = contact.getSObjects('Reservations__r')[0];
    Date checkInDate = (Date) reservation.get('Check_in_Date__c');
    Date checkOutDate = (Date) reservation.get('Check_out_Date__c');
    List<Experience_Instance__c> instances = [
      SELECT
        Date__c,
        Start_Time__c,
        Experience__r.Name,
        Experience__r.Description__c,
        End_Time__c,
        Is_Canceled__c,
        Status__c,
        Booked_Slots__c,
        Available_Slots__c,
        Capacity__c,
        Name
      FROM Experience_Instance__c
      WHERE
        Is_Canceled__c = FALSE
        AND Date__c >= :checkInDate
        AND Date__c < :checkOutDate
        AND Available_Slots__c > 0
        AND (Experience__r.Type__c = :contact.Interest1__c
        OR Experience__r.Type__c = :contact.Interest2__c
        OR Experience__r.Type__c = :contact.Interest3__c)
    ];

    // Create expected response
    List<Response> responses = new List<Response>();
    Response res = new Response();
    res.prompt = JSON.serialize(instances);
    responses.add(res);
    return responses;
  }

  // The variables in this class need to match the prompt template inputs,
  // that may be differnt on each prompt template
  public class Request {
    @InvocableVariable(required=true)
    public Contact contact;
  }

  public class Response {
    @InvocableVariable
    public String Prompt;
  }
}

`
      },
},
    {
      name: "step-6",
      label: "Ground the Prompt Template with Apex  - Prompt",
      step: "Exercise 3 - Step 2",
      language: "text",
      prompt: 
        {
          label: "Prompt",
         body: `You're a receptionist for {!$User.CompanyName}. Your name is {!$User.FirstName}.
Generate a report that shows Coral Cloud Resort hotel guests the different experiences that they can book during their stay.

Instructions:

'''
Use clear, concise, and straightforward language using the active voice and strictly avoiding the use of filler words and phrases and redundant language.
- Create a paragraph explaining that you'll present the different options available, introducing yourself to the guest, whose name is {!$Input:Contact.Name}.
- Describe the next experiences instances that the guest can book:{!$Apex:GetExperienceInstances.Prompt}. use bullets and sections for clarity, and don't forget to include the experience time and date.
- Ask the guest to contact you if they have any questions, on the phone {!$User.MobilePhone}.
'''

Now generate the message.           
`
      },
}
        ]
      },
      {
        name: "workshop-03",
        label: "Hands-on with Copilot",
        link: "https://ai-data-workshop-74a31f4084a9.herokuapp.com/copilot-builder.html",
        subtitle: "Workshop 3",
        description:
          "Einstein Copilot enables companies like Coral Cloud Resorts to have an AI-powered assistant right at their fingertips. Let’s take a look at how they can use the standard, out-of-the-box, functionality as well as customize it with their Salesforce skills.",
        steps: [
          {
            name: "step-1",
            label: "High Priority Cases",
            step: "Exersize 1 - Prompt 1",
            language: "text",
            prompt: 
              {
                label: "Prompt",
                body: `Are there any high priority cases open?`
              }
          },
          {
            name: "step-2",
            label: "Summarize This Case",
            step: "Exersize 1 - Prompt 2",
            language: "text",
            prompt: 
              {
                label: "Prompt",
                body: `Can you summarize the case for me?`
              }
          },
          {
            name: "step-3",
            label: "More about the Customer",
            step: "Exersize 1 - Prompt 3",
            language: "text",
            prompt: 
              {
                label: "Prompt",
                body: `Can you let me know more about the customer?`
              }
          },
          {
            name: "step-4",
            label: "Other Available Expreiences",
            step: "Exersize 1 - Prompt 4",
            language: "text",
            prompt: 
              {
                label: "Prompt",
                body: `What other Experience Instances might she be interested in that have Dates today?`
              }
          },
          {
            name: "step-5",
            label: "Total Number of Interested Contacts",
            step: "Exersize 1 - Prompt 5",
            language: "text",
            prompt: 
              {
                label: "Prompt",
                body: `Find the number of contacts that have interest on Adventure Activities.`
              }
          },
          {
            name: "step-6",
            label: "Available Experience Instances",
            step: "Exersize 2 - Prompt 1",
            language: "text",
            prompt: 
              {
                label: "Prompt",
                body: `Can you see if we have any Experience Instances for Experience Name White Water Rafting Rush that are happening tomorrow and can you register Sofia Rodriguez for it?`
              }
          },
          {
            name: "step-7",
            label: "Send a follow-up Email",
            step: "Exersize 2 - Prompt 2",
            language: "text",
            prompt: 
              {
                label: "Prompt",
                body: `Can you send an email to her letting her know about the experience that we have booked her, the details of the experience including the date and time, and apologize for the issues that are in her case.`
              }
          },
          
    {
      name: "step-8",
      label: "Ground the Prompt Template with Apex - Apex Class",
      step: "Exercise 2 - Step 2",
      language: "java",
      prompt: 
        {
          label: "Prompt",
         body: `public with sharing class CheckWeather {
  @InvocableMethod(
    label='Check Weather'
    description='Check weather at Coral Cloud Resorts at a specific date'
  )
  public static List<WeatherResponse> getWeather(
    List<WeatherRequest> requests
  ) {
    // Retrieve the date for which we want to check the weather
    Datetime dateToCheck = (Datetime) requests[0].dateToCheck;

    // Copilot was trained in 2023 so it will use 2023 as the default year if
    // the user does not specify a year in their prompt. This means that we need
    // to adjust the input date to be on the current year.
    Integer currentYear = Date.today().year();
    Integer yearDelta = currentYear - dateToCheck.year();
    dateToCheck = dateToCheck.addYears(yearDelta);
    String isoDate = dateToCheck.format('yyyy-MM-dd');
    String dateString = dateToCheck.format('MMMM d');

    // Prepare API request
    HttpRequest req = new HttpRequest();
    req.setEndpoint(
      'callout:Weather_Endpoint/weather?lat=37.789782764570425&lon=-122.39723702244089&date=' +
      isoDate
    );
    req.setMethod('GET');
    // Make callout
    Http http = new Http();
    HttpResponse res = http.send(req);
    if (res.getStatusCode() != 200) {
      throw new CalloutException('Bad response: ' + res);
    }

    // The response contains a list of temperatures for different times of the day
    // We parse the response and find the min and max temperatures
    String body = res.getBody();
    WeatherApiResponse weatherResponse = (WeatherApiResponse) JSON.deserialize(
      body,
      WeatherAPIResponse.class
    );
    List<Decimal> temperatures = new List<Decimal>();
    for (Weather item : weatherResponse.weather) {
      if (item.temperature != null) {
        temperatures.add(item.temperature);
      }
    }
    temperatures.sort();

    // Prepare temperatures
    Decimal minTempC = temperatures[0];
    Decimal maxTempC = temperatures[temperatures.size() - 1];
    Decimal minTempF = toFahrenheit(minTempC);
    Decimal maxTempF = toFahrenheit(maxTempC);

    // Create the response for Copilot
    WeatherResponse response = new WeatherResponse();
    response.minTemperature = minTempC;
    response.maxTemperature = maxTempC;
    response.temperatureDescription =
      'On ' +
      dateString +
      ', temperature should be between ' +
      minTempC +
      '°C (' +
      minTempF +
      '°F) and ' +
      maxTempC +
      '°C (' +
      maxTempF +
      '°F) at Coral Cloud Resorts.';
    return new List<WeatherResponse>{ response };
  }

  private static Decimal toFahrenheit(Decimal celsuis) {
    return (celsuis * 9 / 5 + 32).setScale(1);
  }

  public class WeatherRequest {
    @InvocableVariable(
      required=true
      description='Date for which we want to check the temperature. The variable needs to be an Apex Date type with format yyyy-MM-dd.'
    )
    public Date dateToCheck;
  }

  public class WeatherResponse {
    @InvocableVariable(
      description='Minimum temperature in Celsius at Coral Cloud Resorts location for the provided date'
    )
    public Decimal minTemperature;
    @InvocableVariable(
      description='Maximum temperature in Celsius at Coral Cloud Resorts location for the provided date'
    )
    public Decimal maxTemperature;
    @InvocableVariable(
      description='Description of temperatures at Coral Cloud Resorts location for the provided date'
    )
    public String temperatureDescription;
  }

  private class WeatherApiResponse {
    public List<Weather> weather;
  }

  private class Weather {
    public Decimal temperature;
  }
}           
`
      },
},
{
  name: "step-9",
  label: "Send a follow-up Email",
  step: "Exersize 2 - Prompt 3",
  language: "text",
  prompt: 
    {
      label: "Prompt",
      body: `Check weather for [Enter Tomorrows Date ie: April 4th].`
    }
},
{
  name: "step-10",
  label: "Send a follow-up Email",
  step: "Exersize 2 - Prompt 4",
  language: "text",
  prompt: 
    {
      label: "Prompt",
      body: `Can you check the temperature on [Enter Tomorrows Date ie: April 4th] and see which Experiences you would recommend based on the result?`
    }
},
{
  name: "step-11",
  label: "Send a follow-up Email",
  step: "Exersize 2 - Prompt 5",
  language: "text",
  prompt: 
    {
      label: "Prompt",
      body: `Generate a Experiences Report for Sofia Rodriguez.`
    }
}
        ]
      },
      {
        name: "workshop-04",
        label: "Hands-on with Advanced Programmatic AI Concepts",
        subtitle: "Workshop 4",
        link: "https://ai-data-workshop-74a31f4084a9.herokuapp.com/advanced-ai.html",
        description:
          "Coral Cloud Resorts would like to bring AI into every experience. They can do this with Prompt Builder and the ability to invoke prompts from anywhere. In this workshop you'll create a prompt template that allows you to create social posts for the hotel's experiences and you'll learn how to call the prompt template programmatically from anywhere.",
        steps: [
          {
            name: "step-1",
            label: "Generate Social Media Post",
            step: "Exersize 1 - Step 1",
            language: "text",
            prompt: 
              {
                label: "Prompt",
                body: `You're the community manager for Coral Cloud Resort hotel, which offers booking fun and lovely experiences.
Create social media posts for twitter and linkedin describing the property.

Formatting rules you must follow:
"""
> Use clear, concise, and straightforward language using the active voice and strictly avoiding the use of filler words and phrases and redundant language.
> Make sure the response is valid JSON.
> The twitter post should include emojis, and have less than 280 characters
> The linkedin post should include emojis, bullets, and have between 1500 and 2000 characters
> Both the twitter and the linked post can have Unicode formatting. Use symbols from Unicode’s Mathematical Alphanumeric Symbols block liberally to produce facsimiles of bold, italics, line separation, and other formatting. Examples for a sample sentence:

italics sans: 𝘛𝘩𝘦 𝘘𝘶𝘪𝘤𝘬 𝘉𝘳𝘰𝘸𝘯 𝘍𝘰𝘹 𝘑𝘶𝘮𝘱𝘦𝘥 𝘖𝘷𝘦𝘳 𝘵𝘩𝘦 𝘭𝘢𝘻𝘺 𝘥𝘰𝘨.
bold sans: 𝗧𝗵𝗲 𝗤𝘂𝗶𝗰𝗸 𝗕𝗿𝗼𝘄𝗻 𝗙𝗼𝘅 𝗝𝘂𝗺𝗽𝗲𝗱 𝗢𝘃𝗲𝗿 𝘁𝗵𝗲 𝗹𝗮𝘇𝘆 𝗱𝗼𝗴.
bold italic sans: 𝙏𝙝𝙚 𝙌𝙪𝙞𝙘𝙠 𝘽𝙧𝙤𝙬𝙣 𝙁𝙤𝙭 𝙅𝙪𝙢𝙥𝙚𝙙 𝙊𝙫𝙚𝙧 𝙩𝙝𝙚 𝙡𝙖𝙯𝙮 𝙙𝙤𝙜.
italics serif: 𝑇ℎ𝑒 𝑄𝑢𝑖𝑐𝑘 𝐵𝑟𝑜𝑤𝑛 𝐹𝑜𝑥 𝐽𝑢𝑚𝑝𝑒𝑑 𝑂𝑣𝑒𝑟 𝑡ℎ𝑒 𝑙𝑎𝑧𝑦 𝑑𝑜𝑔.

> The block kit code should be valid block kit code for Slack. Example of block kit code:

{
    "blocks": [
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "🌴 *Tropical Snorkel Adventure* 🐠"
            }
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "Swim alongside colorful marine life in our coral-rich tropical waters on this guided snorkeling tour.\n\n *Experience characteristics:*"
            },
            "accessory": {
                "type": "image",
                "image_url": "{!$Input:experienceInstance.Experience__r.Picture_URL__c}",
                "alt_text": "alt text for image"
            }
        },
        {
            "type": "divider"
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "• Swim alongside colorful marine life in our coral-rich tropical waters on this guided snorkeling tour."
            }
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "• Date: 3/11/2024, starting at 16:00, and finishing at 20:00."
            }
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "• Price: $50. Spots are limited, secure your spot today! 🏖️"
            }
        },
        {
            "type": "divider"
        },
        {
            "type": "divider"
        },
        {
            "type": "actions",
            "elements": [
                {
                    "type": "button",
                    "text": {
                        "type": "plain_text",
                        "text": "Book Experience",
                        "emoji": true
                    },
                    "value": "click_me_123",
                    "url": "https://coralcloud.com/book/{!$Input:experienceInstance.Id}"
                }
            ]
        }
    ]
}
"""

Instructions regarding the content to generate:
"""
For each post:
- Add a title including the name of the experience, {!$Input:experienceInstance.Experience__r.Name}
- Add a section including the experience characteristics, such as:
+ Description: {!$Input:experienceInstance.Experience__r.Description__c}
+ Date and time: {!$Input:experienceInstance.Date__c}, starting at {!$Input:experienceInstance.Start_Time__c}, and finishing at {!$Input:experienceInstance.End_Time__c}
- Also include a link to the picture of the experience: {!$Input:experienceInstance.Experience__r.Picture_URL__c}, or the picture directly in the case of the slack post.
- Finally mention the price {!$Input:experienceInstance.Experience__r.Price__c} and say spots are limited.

The final response should have the next format:
{
"twitter": [here goes the twitter post],
"linkedin": [here goes the linkedin post],
"blockkit": [here goes the slack post]
}
"""

Now generate the social media posts.
`
              }
          },
          {
            name: "step-2",
            label: "Execute a Prompt Template in Apex",
            step: "Exersize 1 - Step 2",
            language: "java",
            prompt: 
              {
                label: "Prompt",
                body: `public with sharing class SocialMediaPostsController {
  @AuraEnabled
  public static String generateSocialMediaPosts(String experienceInstanceId) {
    // Create inputs
    Map<String, String> experienceInstance = new Map<String, String>();
    experienceInstance.put('id', experienceInstanceId);
    ConnectApi.WrappedValue experienceInstanceValue = new ConnectApi.WrappedValue();
    experienceInstanceValue.value = experienceInstance;
    Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();
    inputParams.put('Input:experienceInstance', experienceInstanceValue);

    // Configure invocation parameters
    ConnectApi.EinsteinPromptTemplateGenerationsInput executeTemplateInput = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
    executeTemplateInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
    executeTemplateInput.additionalConfig.applicationName = 'PromptBuilderPreview';
    executeTemplateInput.isPreview = false;
    executeTemplateInput.inputParams = inputParams;

    try {
      // Call the service
      ConnectApi.EinsteinPromptTemplateGenerationsRepresentation generationsOutput = ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(
        'Generate_Social_Media_Posts',
        executeTemplateInput
      );
      ConnectApi.EinsteinLLMGenerationItemOutput response = generationsOutput.generations[0];
      return response.text;
    } catch (Exception e) {
      System.debug(e.getMessage());
      throw e;
    }
  }
}
                
`
              }
          },
          {
            name: "step-3",
            label: "Test the code with anonymous Apex",
            step: "Exersize 1 - Step 3",
            language: "text",
            prompt: 
              {
                label: "Prompt",
                body: `Experience_Instance__c experience = [SELECT Id FROM Experience_Instance__c WHERE Date__c = TODAY LIMIT 1];
String socialPost = SocialMediaPostsController.generateSocialMediaPosts(experience.Id);
System.debug(socialPost);
`
              }
          },
          {
            name: "step-4",
            label: "Update the HTML File",
            step: "Exersize 1 - Step 3",
            language: "html",
            prompt: 
              {
                label: "Prompt",
                body: `<template>
<lightning-card
    title="Generate Social Media Posts"
    icon-name="utility:socialshare"
>
    <div class="slds-var-p-around_small">
        <template lwc:if={error}>
            {error}
            <lightning-button
                onclick={generateSocialMediaPosts}
                label="Try again!"
                class="slds-align_absolute-center"
            ></lightning-button>
        </template>
        <template lwc:else>
            <lightning-button
                onclick={generateSocialMediaPosts}
                label="Generate Social Media Posts"
            ></lightning-button>
            <div class="slds-var-p-top_small">
                <lightning-textarea
                    name="twitter"
                    readonly
                    value={twitterPost}
                    label="Twitter Post"
                ></lightning-textarea>
            </div>
            <div class="slds-var-p-top_small">
                <lightning-textarea
                    name="linkedin"
                    readonly
                    value={linkedinPost}
                    label="Linkedin Post"
                ></lightning-textarea>
            </div>
            <div class="slds-var-p-top_small">
                <lightning-textarea
                    name="slack"
                    readonly
                    value={slackPost}
                    label="Slack Post"
                ></lightning-textarea>
            </div>
        </template>
        <template lwc:if={showSpinner}>
            <lightning-spinner alternative-text="Loading..." size="small">
            </lightning-spinner>
        </template>
    </div>
</lightning-card>
</template>
`
              }
          },
          {
            name: "step-5",
            label: "Update the Javascript File",
            step: "Exersize 1 - Step 3",
            language: "javascript",
            prompt: 
              {
                label: "Prompt",
                body: `import { api, LightningElement } from 'lwc';
import generateSocialMediaPosts from '@salesforce/apex/SocialMediaPostsController.generateSocialMediaPosts';

export default class GenerateSocialMediaPosts extends LightningElement {
    twitterPost;
    linkedinPost;
    slackPost;
    error;
    showSpinner = false;
    @api recordId;

    async generateSocialMediaPosts() {
        this.showSpinner = true;
        try {
            const posts = await generateSocialMediaPosts({
                experienceInstanceId: this.recordId
            });
            const parsedPosts = JSON.parse(posts);
            this.twitterPost = parsedPosts.twitter;
            this.linkedinPost = parsedPosts.linkedin;
            this.slackPost = JSON.stringify(parsedPosts.blockkit);
            this.error = undefined;
        } catch (error) {
            this.twitterPost = undefined;
            this.linkedinPost = undefined;
            this.error = error;
        } finally {
            this.showSpinner = false;
        }
    }
}
`
              }
          },
          {
            name: "step-6",
            label: "Update the XML File",
            step: "Exersize 1 - Step 3",
            language: "html",
            prompt: 
              {
                label: "Prompt",
                body: `<?xml version="1.0" encoding="UTF-8" ?>
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>61.0</apiVersion>
    <isExposed>true</isExposed>
    <masterLabel>Generate Social Media Posts</masterLabel>
    <targets>
        <target>lightning__RecordPage</target>
    </targets>
    <targetConfigs>
        <targetConfig targets="lightning__RecordPage">
            <objects>
                <object>Experience_Instance__c</object>
            </objects>
            <supportedFormFactors>
                <supportedFormFactor type="Large" />
                <supportedFormFactor type="Small" />
            </supportedFormFactors>
        </targetConfig>
    </targetConfigs>
</LightningComponentBundle>
`
              }
          },
          {
            name: "step-7",
            label: "Update the Input Params",
            step: "Exersize 2 - Step 1",
            language: "text",
            prompt: 
              {
                label: "javascript",
                body: `"Input:experienceInstance": {
  "value": {
      "id": "An Experience Id from your org"
  }
}

`
              }
          },
        ]
      },
      {
        name: "resources",
        label: "Resources",
        subtitle: "Build with AI + Data Tour",
        description:
          "Congratulations on completing the Build with AI + Data Tour! Together, we've explored new capabilities of Salesforce and laid the groundwork for future innovations.",
          shortcuts: [
            {
              name:"shortcut-1",
              label: "Explore Data Cloud on Trailhead",
              iconName: "standard:trailhead_alt",
              link: 'https://trailhead.salesforce.com/content/learn/trails/explore-customer-360-audiences'
            },
            {
              name:"shortcut-2",
              label: "Get Started with Einstein Copilot on Trailhead",
              iconName: "standard:trailhead_alt",
              link: 'https://trailhead.salesforce.com/content/learn/trails/build-ai-assistants-with-einstein-copilot'
            }
            ],
        steps: []
      },
      {
        name: "workshop-0",
        label: "Get Started",
        subtitle: "Build with AI + Data Tour",
        link: "https://ai-data-workshop-74a31f4084a9.herokuapp.com/get-started.html",
        description:
          "Coral Cloud Resorts is a small resort chain that combines technology with luxury hospitality to offer a personalized guest experience at a beachside location. The resort utilizes data and AI to customize every aspect of a guest's stay based on their preferences. Their goal is to create a seamless and memorable experience for each guest by integrating cutting-edge technology throughout their journey.",
          shortcuts: [
            {
              name:"shortcut-1",
              label: "Open the Code Builder App",
              iconName: "standard:code_playground",
              link: '/lightning/n/CodeBuilder__Code_Builder_Dashboard'
            },
            {
              name:"shortcut-2",
              label: "Install the Data Kit",
              iconName: "standard:data_cloud",
              link: '/packaging/installPackage.apexp?p0=04tHr000001BQic'
            }
            ],
        steps: []
      },

    ];
  }
};
