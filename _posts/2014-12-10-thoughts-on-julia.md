---
layout:     post
title:      Thoughts on Julia
date:       2014-12-10 16:15:00
summary:    I have been playing around with the Julia programming language for about a week. I like it. It has a easy to read syntax, and makes sense.
categories: blog
---

I have been playing around with the Julia programming language for about a week. I like it. It has a easy to read syntax, and makes sense.

What surprised me the most was after an afternoon I had submitted two PRs on GitHub for libraries in the HTTP stack. It's not normally the case that I can get my head around a language that fast. Ok, my contribution was small, and I have by no means mastered the language.

## The Good

(Edit) First of all I'd like to say how responsive and supportive the Julia community are. This is probably the most important point.

I like the syntax, for example:

{% highlight julia %}
function foo(z)
  for x in z
    println(x)
  end
end

type Point
  x::Int64
  y::Int64
end

point = Point(1,2)
point.x = 3
{% endhighlight %}

Nice language features including:

* Destructuring assignment
* Coroutines
* Callback functions have a slightly odd, but nice syntax
* Optional type system
* ...lots more

The callback syntax looks like this:

{% highlight julia %}
function bar(callback::Function)
  callback()
end

bar() do 
  # this is the implementation of the callback
  # which is the first argument of the bar function
end
{% endhighlight %}

Code is just in time compiled, and it feels like a scripting language from a developer's perspective. You just point `julia.exe` at your source code and you're away.

Another oddity is string concatenation:

{% highlight julia %}
"this is how you" * " add strings " * "together"
{% endhighlight %}

Anyway, any syntax looks odd until you get used to it.

There are a couple of ways (well there are lots actually) of importing modules. You can use `using` or `import`. This confused me until I read the documentation. `using` will take everything in the module, and add it to the scope. `import` namespaces everything with the modules name. I still prefer the `require` approach in node, but that's just me.

Another things I like is that Julia uses libuv (and many other libraries) under the covers.

## The Bad

Julia takes ages to start. I know it's still work in progress, and improvements are being made to cache the compiled code, but it just feels too sluggish.

I have also found small stability problems, and find that my console can lock up when exiting a program.

The julia process locks the source files, stopping you from editing them while the program is running.

The string implementation makes me a bit sad, I seem to be spending too much time worrying about whether I've got a `UTF8String` or an `ASCIIString`.

## The Ugly

The package system is not up to standard.

All packages seem to be installed globally (you can tell your program to search elsewhere) but I prefer my packages to be installed alongside my application. This makes it easer to copy my application from one machine to another.

I haven't quite got my head around how the package versioning works, but it looks like you pick one version of a package for the machine. I think this is a poor choice, when compared to node.js, which is able to support multiple package versions in the same application.

The package repository is a [GitHub repo](https://github.com/JuliaLang/METADATA.jl). This on the face of it is a good idea. It's a public database that you can take a local offline clone of. My problem with it is that it has gatekeepers (who (may) approve your contribution). I found some resistance to contributing. This can be a good thing, maintaining a high level of quality is important, but if there's too much of a barrier to package entry, I'm not interested thanks.

## Conclusion

I'll stick with it and report back.