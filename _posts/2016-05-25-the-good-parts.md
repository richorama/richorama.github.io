---
layout:     post
title:      The Good Parts
date:       2016-05-25 09:00:00
summary:    Yesterday I was trying to learn F# by reading through the O'Reilly book and trying a few code samples. I then made a flippant remark...
---

Yesterday I was trying to learn F# by reading through the O'Reilly book and trying a few code samples.

I then made a flippant remark:

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">I wish someone would write &#39;F# - the good parts&#39;</p>&mdash; Richard Astbury (@richorama) <a href="https://twitter.com/richorama/status/735122629275836416">May 24, 2016</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

I got quite a few responses, with people joking that it was all good, or all bad, but I also got serious offers of help.

I've spent some more time thinking about this, so I thought I would jot some ideas down.

But first of all, I have nothing against F#, I'm trying to learn it because it looks like a powerful language, and it
has an active and friendly community. Please don't take anything here as a criticism against F#.

## JavaScript

![JavaScript the Good Parts](/images/jsgoodparts.jpg)

Whether you love or hate JavaScript, this is probably the best book you can buy on the language.
It's a bold book.
Most programming books aim to cover as many language features as possible, maximising book thickness to occupy as
much shelf space as possible.
But this book is different.
It's relatively thin (JavaScript is a small language) and it walks you through the parts of the language you should use.
It leaves the other bits for an appendix.

## Why is less more?

I find learning hard. It takes time (I don't have much free time) and it takes effort (I don't have much of that either).
When learning a language I don't want to know all of it, I want to know the pieces that I need. But it's difficult to
know what you need until you know the language. Which is why Crockford's book is so great, he's made those
decisions (mistakes) for you, and he made the right decisions.

## What about F#?

My frustrations yesterday went something like this:

* `BOOK>` __There is this concept called modules, here is some information about it.__
* `ME>` _attempt to retain information_
* `BOOK>` __Oh, modules aren't much good for large projects and .NET interop, use namespaces instead.__
* `ME>` _purge module knowledge_
* `BOOK>` __You can have explicit constructors on objects.__
* `ME>` _attempt to retain information_
* `BOOK>` __Oh, don't use those things, use implicit constructors.__
* `ME>` _purge explicit constructor knowledge_
* `BOOK>` __You can use lists to hold a number of values.__
* `ME>` _attempt to retain information_
* `BOOK>` __But a sequence is better, because it's lazy!__
* `ME>` _purge list knowledge_
* `BOOK>` __Here is how to do a pattern match, use the `match` keyword.__
* `ME>` _attempt to retain information_
* `BOOK>` __Or you can just use this `function` keyword instead, it's more terse.__
* `ME>` _send frustrated tweet_

This dialogue is not exhaustive.

## Classifying language features

I've come up with a way of classifying language features, something like this:

__`Essential`__ - features that you must have to write a program.

__`Advanced`__ - features that you don't need, but will make your program more efficient/elegant/maintainable.

__`Occasional`__ - features that are seldom required, and it's OK to google when you need to use.

__`Avoid`__ - features which you shouldn't use, just forget they exist.

To help illustrate what I mean, I'll classify some C# keywords:

![C# quadrants](/images/csharpquadrants.png)

_Yes [C# has `goto`](https://msdn.microsoft.com/en-gb/library/13940fs2.aspx) ;¬)_

People might disagree about where some of the finer points about where keywords might sit,
but I don't think that many people would argue that `goto` is essential, and you should avoid `namespace`.

As a language evolves you can expect these classifications to change. When new features arrive, they might displace older
features, and relegate them to 'Occasional' or 'Avoid'. We do this to maintain backwards compatibility (although languages
like Python and Ruby have sacrificed this).

In C# and JavaScript, I have (unconsciously) built this mental model of the language.
This has taken a long time, and it's probably an ongoing process.
But now I know there are parts of these languages which I know aren't useful, or can cause problems,
so I don't use them. I can unlearn them.

With F# the canvas is blank. I don't know where to put things. Is it really important for me to know how to use
discriminated unions for tree structures? Do people use records, or do they just build classes? Should I always
use a sequence in preference to a list?

## In conclusion

This is why I would like a book that can take someone's experience with the language and records it in a way that
makes it easier for me to learn. Just like Crockford did.
Perhaps it starts with the 'Essentials', and finishes with the 'Advanced'.
I'll just google the 'Occasional' stuff, and please leave out the 'Avoid' stuff, thanks!
