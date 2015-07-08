# Slack Recipes

These are some of the best recipes we've found for intergrating Pushpop and Slack

## Slash Commands

### [Company Info](company_slash_command.rb)

This creates a slash command that will retrieve info about a company from Clearbit, and send it back in to Slack.

The company info will look like this in Slack:

![Company Screenshot](http://i.imgur.com/w2BR3SJ.png)

#### Dependencies
- [Clearbit](https://clearbit.com/)
- [Slack](https://slack.com)
	
#### Setup
1. Grab your [Clearbit API key](https://dashboard.clearbit.com/keys)
2. Create a [Slack Incoming Webhook](https://keen.slack.com/services/new/incoming-webhook) (you can reuse an existing one)
	- Copy the webhook URL - you'll need that later
3. Create a [Slack slash command](https://keen.slack.com/services/new/slash-commands)
	- Preferably `/company` for the command
	- The URL should point to your Pushpop instance, on the `/slack/company` path
	- Copy the Token - you'll need that later
4. Create a new job in your Pushpop instance, using the [company info source]((company_slash_command.rb)).
5. Add all of the environment variables
	- `CLEARBIT_KEY` is the Clearbit API key from Step 1
	- `SLACK_WEBHOOK_URL` is the webhook URL from Step 2
	- `SLACK_TOKEN_COMPANY` is the slash command token from Step 3
6. Restart Pushpop (make sure you're running pushpop [as a webserver](https://github.com/pushpop-project/pushpop#custom-http-server-for-webhooks))
7. Type `/company keen.io` into slack!

### [Person Info](person_slash_command.rb)

This creates a slash command that will retrieve info about a person (via email address) from Clearbit, and send it back in to Slack.

The person info will look like this in Slack:

![Person Screenshot](http://i.imgur.com/Gu8aP3h.png)

#### Dependencies
- [Clearbit](https://clearbit.com/)
- [Slack](https://slack.com)
	
#### Setup
1. Grab your [Clearbit API key](https://dashboard.clearbit.com/keys)
2. Create a [Slack Incoming Webhook](https://keen.slack.com/services/new/incoming-webhook) (you can reuse an existing one)
	- Copy the webhook URL - you'll need that later
3. Create a [Slack slash command](https://keen.slack.com/services/new/slash-commands)
	- Preferably `/person` for the command
	- The URL should point to your Pushpop instance, on the `/slack/person` path
	- Copy the Token - you'll need that later
4. Create a new job in your Pushpop instance, using the [person info source]((person_slash_command.rb)).
5. Add all of the environment variables
	- `CLEARBIT_KEY` is the Clearbit API key from Step 1
	- `SLACK_WEBHOOK_URL` is the webhook URL from Step 2
	- `SLACK_TOKEN_COMPANY` is the slash command token from Step 3
6. Restart Pushpop (make sure you're running pushpop [as a webserver](https://github.com/pushpop-project/pushpop#custom-http-server-for-webhooks))
7. Type `/person jack@squareup.com` into slack!