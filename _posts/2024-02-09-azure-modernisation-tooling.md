---
layout: post
title: Microsoft Tooling for Application Modernisation
date: 2024-02-09 09:00:00
summary:  Microsoft provide various tooling options for application modernisation. Whether you are working with ASP.NET or Java, Microsoft provides a range of tools to help you discover, containerise, and migrate your applications to Azure 
---

In this blog post, we will explore the various Microsoft tooling options available for application modernisation. Whether you are working with ASP.NET or Java, Microsoft provides a range of tools to help you discover, containerise, and migrate your applications to Azure services such as Azure Kubernetes Service (AKS) and Azure App Service. Let's dive in and explore the options.

## Azure Migrate: App Containerization tool

[https://learn.microsoft.com/en-us/azure/migrate/tutorial-app-containerization-aspnet-kubernetes](https://learn.microsoft.com/en-us/azure/migrate/tutorial-app-containerization-aspnet-kubernetes)

[https://learn.microsoft.com/en-us/azure/migrate/tutorial-app-containerization-java-kubernetes](https://learn.microsoft.com/en-us/azure/migrate/tutorial-app-containerization-java-kubernetes)

Stack: `ASP.NET` `Java`

Targets: `AKS`

Discovery and containerisation of .NET or Java apps. Discovers your applications. Builds the container image. Deploys to the Azure Kubernetes Service. Suitable for application discovery, containerisation and deployment of multiple apps, or 3rd party apps.


## Azure Migrate: Migrate Web Apps to App Service (Containers)

[https://learn.microsoft.com/en-us/azure/migrate/tutorial-app-containerization-aspnet-app-service](https://learn.microsoft.com/en-us/azure/migrate/tutorial-app-containerization-aspnet-app-service)

[https://learn.microsoft.com/en-us/azure/migrate/tutorial-app-containerization-java-app-service](https://learn.microsoft.com/en-us/azure/migrate/tutorial-app-containerization-java-app-service)

Stack: `ASP.NET` `Java`

Targets: `App Service (Containers)`

Discovery and migration of .NET or Java apps with containerisation. Discovers your applications. Deploys to the Azure App Service as a container.

## Azure Migrate: Migrate Web Apps to App Service (Code)

[https://learn.microsoft.com/en-us/azure/migrate/tutorial-modernize-asp-net-appservice-code](https://learn.microsoft.com/en-us/azure/migrate/tutorial-modernize-asp-net-appservice-code)

Stack: `ASP.NET`

Targets: `App Service`

Discovery and migration of .NET apps without containerisation. Discovers your applications. Deploys to the Azure App Service as native code. Suitable for discovering apps, and migrating their source code, without using containers.

## Azure Migrate: Migrate web apps to AKS (preview)

[https://learn.microsoft.com/en-us/azure/migrate/tutorial-modernize-asp-net-aks](https://learn.microsoft.com/en-us/azure/migrate/tutorial-modernize-asp-net-aks)

Stack: `ASP.NET (on VMWare)`

Targets: `AKS`

Discovery, modernisation and containerisation of .NET apps running on VMWare. Includes automated modernization. Suitable for application discovery, modernisation, containerisation and deployment of multiple apps.

## AppCat: Azure Migrate application and code assessment for .NET

[https://learn.microsoft.com/en-us/azure/migrate/appcat/dotnet](https://learn.microsoft.com/en-us/azure/migrate/appcat/dotnet)

Stack: `ASP.NET`

Targets: `AKS` `App Service` `Container Apps`

For modernising a .NET code base, and analysing which app hosting service is the most suitable. Analyses application code for suitability for Azure App Service AKS, and Azure Container Apps, and then migrating to Azure Analysis application code, migrates the application, and built into Visual Studio.

## AppCat: Azure Migrate application and code assessment for Java

[https://learn.microsoft.com/en-us/azure/migrate/appcat/java](https://learn.microsoft.com/en-us/azure/migrate/appcat/java)

Stack: `Java`

Targets: `AKS` `App Service` `Container Apps` `Spring Apps`

For analysing application code for suitability for Azure App Service, Azure Spring Apps, AKS, Azure Container Apps. Command line tool which can assess application code against various target hosting services. Helps you to understand which service is the most suitable for the codebase.

## .NET Upgrade Assistant

[https://learn.microsoft.com/en-us/dotnet/core/porting/upgrade-assistant-overview](https://learn.microsoft.com/en-us/dotnet/core/porting/upgrade-assistant-overview)

Stack: `.NET`

Targets: `AKS` `App Service` `Container Apps`

Helps you upgrade apps from previous versions of .NET, .NET Core, and .NET Framework to the latest version. A Visual Studio extension and command-line tool that's designed to assist with upgrading apps to the latest version of .NET. Modernise legacy .NET applications for porting to Linux or containers.

## Dotnet Publish

[https://learn.microsoft.com/en-us/dotnet/core/docker/publish-as-container](https://learn.microsoft.com/en-us/dotnet/core/docker/publish-as-container)

Stack: `.NET`

Targets: `AKS` `App Service` `Container Apps`

Containerise a modern .NET application Creates a container image of a .NET application Publish a modern .NET application to a container based service

