---
layout: post
title: SFTP in Azure
date: 2022-03-28 09:00:00
summary: ***
---

# FTP vs SFTP

FTP (or File Transfer Protocol) is a protocol that's been around for 50 years, and is used for exchanging files between a client and a server.
It supports username and password authentication, but doesn't have encrypted transport. FTPS adds TLS to this protocol to encrypt the traffic.

SFTP (or Secure Shell File Transfer Protocol) is a protocol for exchanging files between a client and server securly. It's part of the SSH
protocol and a modern version of FTP. It is not compatible with the FTP protocol.

This blob post is an overview of using SFTP.

# Installing SFTP to Blob

Azure Blob Storage now provides the ability to connec to a Container using SFTP. At the time of writing this is in a public preview.

You must first enable this feature in your subscripion. You can use this command on the Azure CLI:

```
az feature register --namespace Microsoft.Storage --name AllowSFTP
```

You can check to see if the feature is enabled using this command:

```
az feature show --namespace Microsoft.Storage --name AllowSFTP
```

SFTP is only supported on Storage Accounts created with this feature enabled.

You can create an account with SFTP enabled with this command:

```
az storage account update -g <resource-group> -n <storage-account> --enable-sftp=true
```

# Configuring SFTP






# Further Reading

* [Connect to Azure Blob Storage by using the SSH File Transfer Protocol](ttps://docs.microsoft.com/en-us/azure/storage/blobs/secure-file-transfer-protocol-support-how-to)


