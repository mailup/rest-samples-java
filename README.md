Java Rest API Client 
================
Java REST API integration/implementation samples

Requirements
------------------------
* Java Netbeans EE edition
* A valid MailUp account ( trial accounts allowed )
* Your own API application keys [1] 

notes : 
* For further API information, please visit [MailUp REST API Help] [2] 
* For MailUp trial account activation please go to [MailUp web site] [3] 

  [1]: http://help.mailup.com/display/mailupapi/Get+a+Developer+Account        "Get API application keys" 
  [2]: http://help.mailup.com/display/mailupapi/REST+API        "MailUp REST API Help"
  [3]: http://www.mailup.com/p/pc/mailup-free-trial-d44.htm        "MailUp web site"  
  
Samples overview 
------------------------
This project encloses a short list of "ready to use" samples, which represent some of the most common actions you can do with MailUp.

* Sample 1   - Importing recipients into a new group
* Sample 2   - Unsubscribing a recipient from a group
* Sample 3   - Updating the recipient's profile data
* Sample 4   - Creating a message from a custom template (at least one template must be available in list 1)
* Sample 5   - Building a message with images and attachments
* Sample 6   - Tagging an email message
* Sample 7   - Sending an email message
* Sample 8   - Displaying mailing statistics at message level (e.g. it may be used to get the results of sample 7)

Before starting 
------------------------
After you get the MailUp account ID and the API application keys, please set them into your local config file. You can find the path of the config file here: 
```
rest-samples-java/MailUpExample/src/java/com/mailup/mailup.properties
```   

Debugging tool 
------------------------


Notes
------------------------
To learn more about API keys and how to get them, please refer to [MailUp REST API Keys and endpoints] [4] 

  [4]: http://help.mailup.com/display/mailupapi/All+API+Keys+and+Endpoints+in+one+page        "MailUp REST API Keys and endpoints"

Revision history
------------------------
