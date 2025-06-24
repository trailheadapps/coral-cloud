MessagingChannel channel = [SELECT Id, IsActive FROM MessagingChannel WHERE DeveloperName='Agent_Channel'];
channel.IsActive = true;
update channel;
