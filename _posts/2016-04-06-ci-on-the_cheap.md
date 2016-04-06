---
layout:     post
title:      Continuous Integration on the Cheap
date:       2016-04-06 09:00:00
summary:    I used Azure Web Apps to build my small .NET application, which is held in a private BitBucket repository, without having to pay anything for a CI service.
---

Continuous integration is a development practice where every commit to a repository is built and tested.

There are some excellent services available, such as [Travis CI](https://travis-ci.org/) and
[AppVeyor](https://www.appveyor.com/) which you should use. They're even free for open source projects.

I wanted to build my small .NET application, which is held in a private BitBucket repository, without
having to pay anything for a CI service. I don't need all the bells and whistles,
I just want a service to build my code and run the tests (I'm too lazy to run the tests myself).

[Azure Web Apps](https://azure.microsoft.com/en-gb/services/app-service/web/) does half
of this already. It integrates with BitBucket and GitHub, and will fetch my project on every commit and build it.
It's just missing the last mile of being able to run the tests and notify me of any problems.

The good news, is that you can customise your build script, and get it to do the remaining pieces.

To do that, you'll need to generate a build script, to do that you'll need the Azure CLI tooling, which is a
node.js module. I'm assuming you've already got Node.js installed.

Here's the process:

__Install Azure CLI:__

{% highlight text %}
$ npm install azure-cli -g
{% endhighlight %}

__Create the deployment script:__

There are lots of options here, if you type...

{% highlight text %}
$ azure site deploymentscript
{% endhighlight %}

...you'll get a list of options.

This is what I used for a traditional ASP.NET web application:

{% highlight text %}
$ azure site deploymentscript --aspWAP ProjectFile.csproj --solutionFile SolutionFile.sln
{% endhighlight %}

__Customise the deployment script:__

Now you can add some lines to build your tests project, and run the tests.

Identify the point in the build script after the nuget packages have been restored, and the project has been built, and insert this line,
to build your project containing the tests:

{% highlight text %}
:: Building test project
echo Building test project
"%MSBUILD_PATH%" "%DEPLOYMENT_SOURCE%\TestProjectFile.csproj"
IF !ERRORLEVEL! NEQ 0 goto error
{% endhighlight %}

Then you can run the tests, and store the output to a file:

{% highlight text %}
:: Running tests
echo Running tests
vstest.console.exe "%DEPLOYMENT_SOURCE%\bin\Debug\TestProject.dll" > testoutput.txt 2>&1
{% endhighlight %}

I then use curl to call the sendgrid API, to email me the test output file:

{% highlight text %}
IF /I !ERRORLEVEL! NEQ 0 (
    curl https://api.sendgrid.com/api/mail.send.json -F to=recipient@email.com -F toname="YOUR NAME" -F subject="PASSED :¬)" -F text=@testoutput.txt  -F from=sender@email.com -H "Authorization: Bearer SG.SEND_GRID_BEARER_TOKEN"
) ELSE (
    curl https://api.sendgrid.com/api/mail.send.json -F to=recipient@email.com -F toname="YOUR NAME" -F subject="FAILED :¬(" -F text=@testoutput.txt  -F from=sender@email.com -H "Authorization: Bearer SG.SEND_GRID_BEARER_TOKEN"
)
{% endhighlight %}

> The code should be immediately after the test runner.

There you are. After you've added the deployment files to the repo, and pushed it, Azure Web Apps should start building and running your tests.
You might want to extend this further, and send emails when deployments have been successful/unsuccessful.

Happy CIing!
