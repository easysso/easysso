# EasySSO #

Welcome to the EasySSO project!

EasySSO is a project led by Ashish and Sagar to simplify the integration of Azure AD Single Sign-On for solutions running on Azure. We work with the Independent Software Vendor (ISV) partners and it has been our experience that the authentication and authorization mechanism in use vary greatly between one solution to another.

With this project, we want to enable our ISV partners to take the first steps toward implementing a full-fledged Azure AD Single Sign-on for their authentication and authorization requirements with minimal effort and little coding.

Azure AD is the backbone of the Identity and Access Management capabilites on Azure, Office 365 and the Power Platform. Enterprises gain robust identity management, security and access control for internal resources, apps as well as 3rd party SaaS applications. See this [doc](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-whatis) for more information on Azure AD.

Implementing Azure AD Single Sign-On is similar to other OAuth/OpenID Connect developer experience and you can read all about it [here](https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-overview)

With this project, we want to give a headstart to anyone who is looking at doing it for their solutions and projects.

At the core of this project is the built-in authentication and authorization support available with Azure App Service. To learn more please visit this [documentation](https://docs.microsoft.com/en-us/azure/app-service/overview-authentication-authorization).

This feature allows developers to add federated authentication from providers such as Azure Active Directory, Microsoft Accounts, Facebook, Google and Twitter with zero code and we use it to give you a quick path to integrate the same in your applications. You can take a look the guides available from this [link](https://docs.microsoft.com/en-us/azure/app-service/configure-authentication-provider-aad) to learn how to do it manually but with EasySSO, we have automated this process for you.

Here's a concise overview of all the steps involved -

1. Create an Azure App Service instance
2. Configure this instance to use Azure Active Directory authentication with Express or Advanced configuration
3. Configure the Service Principal used in step 2 to redirect to a callback API which can process the access and/or id tokens
4. Enable other APIs to use this token to grant access to your app

With EasySSO, you can complete all of this and simply get your hands on the token(s) in less that a minute!

All you will need do is to direct your users to the URL that is shared with you at the end of deployment, where they can log in using their work or school accounts backed by Azure AD. We also share the code that you can use to validate the tokens, read the claims and perform your own authorization routines as appropriate.

Using the Azure AD portal, you can also enable to receive the Access Token along with ID Token and configure the Service Principal to include optional claims and additional access to users' information - we enable just the read profile permissions to get going.
