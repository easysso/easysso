# EasySSO  

Welcome to the EasySSO project!

EasySSO is a project to simplify the integration of [Azure Active Directory](https://docs.microsoft.com/en-in/azure/active-directory/) Single Sign-On for solutions. We work with the Independent Software Vendor (ISV) partners and it has been our experience that the authentication and authorization mechanism in use vary greatly between one solution to another.

With this project, we want to enable everyone to take the first steps toward implementing a full-fledged Azure AD Single Sign-on for their authentication and authorization requirements with **minimal effort**  and background.

Azure AD is the backbone of the Identity and Access Management capabilites on Azure, Office 365 and the Power Platform. Enterprises gain robust identity management, security and access control for internal resources, apps as well as 3rd party SaaS applications. See this [doc](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-whatis) for more information on Azure AD.

Implementing Azure AD Single Sign-On is similar to other OAuth/OpenID Connect developer experience and you can read all about it [here](https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-overview).

With this project, we want to give a headstart to anyone who is looking at doing it for their solutions and projects.

# How the project is intended to be used 

This project is build on top of authentication and authorization support available with Azure App Service. To learn more please visit this [documentation](https://docs.microsoft.com/en-us/azure/app-service/overview-authentication-authorization).

This feature allows developers to add federated authentication from providers such as Azure Active Directory, Microsoft Accounts, Facebook, Google and Twitter with zero code and we use it to give you a quick path to integrate the same in your applications. You can take a look the guides available from this [link](https://docs.microsoft.com/en-us/azure/app-service/configure-authentication-provider-aad) to learn how to do it manually but with EasySSO, we have automated this process for you.

Here's an overview of steps involved -

1. Create an Azure App Service instance
2. Configure this instance to use Azure Active Directory authentication with Express or Advanced configuration
3. Configure the Service Principal used in step 2 to redirect to a callback API which can process the access and/or id tokens
4. Enable other APIs to use this token to grant access to your app

With EasySSO, you can complete all of this and simply get your hands on the token(s) in a few minutes!

All you will need do is to direct your users to the URL that is shared with you at the end of deployment, where they can log in using their work or school accounts backed by Azure AD. We also share the code that you can use to validate the tokens, read the claims and perform your own authorization routines as appropriate.

Using the Azure AD portal, you can also enable to receive the Access Token along with ID Token and configure the Service Principal to include optional claims and additional access to users' information - we enable just the read profile permissions to get going.

In short, this is how it works :

![diagram](https://github.com/easysso/easysso/raw/master/diagram.png)

# Structure of the repo

This project is organized as following -
```
EasySSO
│
├───App
│   └───App ──> this directory contains the demo web app  
│
├───release
│       App.zip ──> this zip file contains the release of the demo app that is deployed by the provisioning script
│
└───script
        easysso.sh ──> this script automates the deployment of various entities, Azure servics and the demo app
```

# Deploy EasySSO

This project comes with a demo ASP.NET core web app to demonstrate how it works. This web app is provisioned for you as part of the deployment.

Following are the steps you can use to deploy this project -

1. clone the repository on your system -
```
git clone https://github.com/easysso/easysso.git
```

2. Run the provisioning script from a BASH shell. The script requires two parameters - first, the name of the function app that orchestrates the auth flow and second, the location where the function app will be provisioned - 
```
cd easysso
cd script
bash ./easysso.sh easyssoapp southindia 
```
*Note: If you are on Windows, you can use Windows Subsystem for Linux (WSL) or Cloud Shell.*

The script verifies if the app name is unique so you may want to use a name that is unique to your solution.

The provisioning script does the following -

1. Create a Service Principal that is the core of the authntication and authorization flow orchestrated by EasySSO
2. Create a resource group based on the name of the app that you provided
3. Create a basic app service plan and use that to create the demo web app
4. Deploy the demo code to the demo web app
5. Create a storage account required for the function app
6. Create a function app that uses consumption plan
7. Associate this function app with the Service Principal created earlier.
8. Configure the function app to generate the access token in the right format

# How to Test

The provisioning script outputs a URL that you can use to redirect your users to log in using their Azure Active Directory credentials. The URL is formatted as below -

1. Microsoft identity platform endpoint - https://login.microsoftonline.com/{tenantId}/oauth2/authorize?
2. Tenant ID above can be set to *common* for a multi-tenant application 
3. The response type needed - valid values: id_token 
4. The redirect URI where the token will be forwarded after the successful authentication
5. Client ID of the Service Principal
6. Scope - set to openid+profile+email
7. Response mode set to form_post
8. Resource - set to blank
9. Nonce

You can use copy and paste this URL to test the authentication flow. Once the users have authenticated successfully, they will be redirected to the *success* endpoint provided by the demo web app which only shows the claims that were forwarded to the app.

In production, you will use a URL that is part if your web app to recieve this information. To make it work, you can replace the demo web app URL with a URL from your solution by going to *Azure Active Directory -> App Registrations > App name that you provided > Authentication > Redirect URLs* 

You can log the users out by redirecting them to the following URL -
```
https://login.microsoftonline.com/common/oauth2/v2.0/logout
```
Thanks!

