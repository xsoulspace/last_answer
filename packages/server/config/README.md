Original article:
https://medium.com/serverpod/integrating-google-sign-in-with-serverpod-authentication-part-2-6fade3099baf

Introduction
In the first part of our series, we delved into the fundamental aspects of Serverpod and set up an authentication system using email and password. We employed the Serverpod_auth module for this purpose, which offered a seamless backend and frontend integration for our Flutter application.

As we move forward in our journey with Serverpod, we will explore another pivotal feature of modern applications — third-party logins. In this tutorial, specifically, we will focus on Google Login integration. By allowing users to sign in with their existing Google accounts, we can provide a more streamlined, convenient, and secure authentication experience.

In this second part of the series, we will guide you step-by-step on how to integrate Google Login with Serverpod for your Flutter application. We will set up the necessary configurations in Google Cloud Project, modify our Serverpod_auth module to handle Google Login, implement platform-specific client-side integrations for Android, iOS, Web, MacOS, Windows, and Linux.

If you didn’t checkout Part 1 we recommend you at least complete setting up the project and auth module before moving on to this tutorial.

The complete example project we are creating in this tutorial can be found here

Let’s get started!

Prerequisite
Before proceeding with this tutorial, ensure you have:

A functioning Serverpod project with CLI and Docker, as covered in Part 1.
A Google Cloud account for configuring Google Login.
Appropriate SDKs and emulators for your desired platforms (Android, iOS, Web, MacOS, Windows, Linux).
A database viewer like Postico2, PgAdmin, or DBeaver. We’ll use Postico2 in this tutorial.
With these elements in place, you’re prepared to integrate Google Login with Serverpod.

Setting up the Google Cloud Project
To implement Google Login, we need to create a Google Cloud Project and obtain the OAuth 2.0 credentials. Follow these steps to set up the project:

Log in to Google Cloud Console: Navigate to the Google Cloud Console and log in with your Google account.
Create a new project: Click on the project drop-down menu and select ‘New Project’. Give your project a name and select ‘Create’.
Enable Peoples API: On the dashboard, navigate to the ‘Library’ section under ‘APIs & Services’. Search for ‘Google People API’, select it, and click on ‘Enable’.
Create OAuth consent screen: Go to ‘OAuth consent screen’ under ‘APIs & Services’. Choose ‘External’ for user type, then click ‘Create’. Fill in the required fields, including ‘App name’, ‘User support email’, and ‘Developer contact information’. Click ‘Save and Continue’.
Add Scopes: On the ‘Scopes’ page, add the scopes .../auth/userinfo.email and .../auth/userinfo.profile click ‘Save and Continue’.
Add Test Users: On the ‘Test Users’ page, add your Google account email as a test user, then click ‘Save and Continue’.
Your Google Cloud Project is now ready, but we still need to create the credentials for your server and your flutter apps.

Server Integration of Google Login
Create Credentials: Navigate to ‘Credentials’ under ‘APIs & Services’. Click ‘Create Credentials’ and select ‘OAuth client ID’. Configure the OAuth client as a ‘Web application’. Name your client and leave the Authorized JavaScript originsand Authorized redirect URIs fields blank for now.
Obtain the JSON credentials: After creating the credentials, you’ll be provided with an option to download the secrets as a json. Click the “DOWNLOAD JSON” button. Rename the file to google_client_secret.json.
Add secret to Serverpod: Move the secret file into your server project and put it under config/google_client_secret.json. Serverpod will by default look for this file to interact with google.
