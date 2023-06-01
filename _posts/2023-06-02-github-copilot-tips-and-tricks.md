---
layout: post
title: GitHub Copilot Tips and Tricks
date: 2023-06-01 09:00:00
summary: Some tips and tricks for using GitHub Copilot in VSCode
---

![](/images/copilot.png)

# GitHub Copilot Tips and Tricks

## Enable/Disable Specific Languages in VSCode

In VSCode you can enable and disable specific languages by adding the following to your settings.json file:

{% highlight json %}
    "github.copilot.enable": {
        
        "*": true,
        "plaintext": true,
        "markdown": true,
        "scminput": false,
        "yaml": false
    },
{% endhighlight %}

## Enable/Disable Specific files in your project

If you want to enable or disable specific files in your project you can add a `.copilotignore` file to your project. This has the same syntax as a `.gitignore` file.

{% highlight text %}
# Ignore all files in the .vscode folder
.vscode

# Ignore all certificate files
*.cer

# Ignore all files in the bin folder
bin/
{% endhighlight %}

## Master the Shortcut Keys

Action | Shortcut
------ | --------
Accept an inline suggestion	| `Tab`
Dismiss an inline suggestion | `Esc`
Show next inline suggestion	| `Alt` + `]`
Show previous inline suggestion	| `Alt`+ `[`
Trigger inline suggestion	| `Alt` + `\`
Open GitHub Copilot (additional suggestions in separate pane)	| `Ctrl` + `Enter`

## Use Copilot for non-programming tasks

Copilot can be used for more than just programming tasks. It can also be used for writing documentation, emails, and even poetry!