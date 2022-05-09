---
layout: post
title: SFTP in Azure
date: 2022-05-09 09:00:00
summary: Azure Blob Storage now provides the ability to connect to a Container using SFTP.
---

# FTP vs SFTP

FTP (or File Transfer Protocol) is a protocol that's been around for 50 years, and is used for exchanging files between a client and a server.
It supports username and password authentication, but doesn't have encrypted transport. FTPS adds TLS to this protocol to encrypt the traffic.

SFTP (or Secure Shell File Transfer Protocol) is a protocol for exchanging files between a client and server securely. It's part of the SSH
protocol and a modern version of FTP. It is not compatible with the FTP protocol.

This blob post is an overview of using SFTP.

# Installing SFTP to Blob

Azure Blob Storage now provides the ability to connect to a Container using SFTP. At the time of writing this is in a public preview.

You must first enable this feature in your subscription. You can use this command on the Azure CLI:

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

When you open the storage account in the Azure Portal you'll see a new 'SFTP (preview)' menu item under settings.

From here you can add users, and then configure which containers they have access to.

When creating a user you can either specify an SSH password, or use a public key.

![](/images/add-ssh-user.png)

You can then select which containers than can access, and what that level of access should be. You can also choose a 'Home directory', which is the default directory for that user.

![](/images/add-ssh-container.png)

# Integrating

Uploading a blob could be the first stage in a workflow. You can use a new blob upload
to trigger a function or a logic app which may process the data in the file, and call other systems. Once completed it could then delete the blob if required.

This example will then post that image to a slack channel using a web hook. 

![](/images/sftp-logic-app.png)


# Connecting

To connect to the SFTP account, you'll need to connect with credentials in this format:

Username: `STORAGE_ACCOUNT.CONTAINER.USER` 

Server: `STORAGE_ACCOUNT.blob.core.windows.net`

From there you can can `get` and `put` files.

{% highlight text %}
$ sftp STORAGE_ACCOUNT.CONTAINER.USER@STORAGE_ACCOUNT.blob.core.windows.net
{% endhighlight %}

STORAGE_ACCOUNT.CONTAINER.USER@STORAGE_ACCOUNT.blob.core.windows.net's password:
Connected to STORAGE_ACCOUNT.blob.core.windows.net.
sftp> put example.jpg
Uploading example.jpg to /example.jpg
example.jpg                                                         100%  978KB   1.8MB/s   00:00
sftp>
{% endhighlight %}

Alternatively [FileZilla](https://filezilla-project.org/) supports SFTP.

# The Result

In this example the image gets posted to a slack channel, but

![](/images/slack.png)

# Conclusion

For integrations that require SFTP to upload/download files, the Azure Blob Storage SFTP feature is a good choice for both storage of files, and for triggering workflows or functions to process the data.

# Further Reading

* [Connect to Azure Blob Storage by using the SSH File Transfer Protocol](ttps://docs.microsoft.com/en-us/azure/storage/blobs/secure-file-transfer-protocol-support-how-to)


