---
layout: post
title: Converting to TypeScript
date: 2019-11-18 09:00:00
summary: On a couple of recent projects at work I've been forced to really use TypeScript. I've emerged from this experience loving the language. I'll attempt to show you what I've discovered.
---

I started took to JavaScript seriously in 2012 with node.js. It offered a nice module system, a rich package ecosystem and a fast startup/development cycle.
However the most compelling thing about JavaScript was that it took me out of the .NET world including the painfully slow Visual Studio
and the cumbersome static type system of C#. JS gave me a refreshing new world. It felt really flexible, the language felt more expressive and I
felt happier.

Fast forward 7 years and I still love JavaScript. It must be said that .NET has changed in the meantime and dotnet core has definitely made C# a nicer place to work.

During these last few years I've kept bumping into TypeScript. I've always tried to avoid it. It looked like it attempted to convert JS back into C#,
not that I hate C#, but I just wanted to develop somewhere different. JavaScript felt like a 'cool hipster language', TypeScript looks like it was
trying to put a 'corporate' finish on it.

On a couple of recent projects at work I've been forced to really use TypeScript. I've emerged from this experience loving the language.

I'll attempt to show you what I've discovered (note this is not an exhaustive list of language features, just some nice things I found):

## 1. It's easy to get started

CRA (Create React App) seems to be the generally preferred way of starting a front-end project.

To create a TypeScript app you can just do this:

{% highlight text %}
$ npx create-react-app my-app --typescript
{% endhighlight %}

https://create-react-app.dev/docs/adding-typescript/

## 2. Type annotations aren't all that intrusive

In this example we annotate the function parameter as a string.

The function return type is inferred from inspecting the function body.

{% highlight ts %}
function sayHello(name: string) {
  return `Hello ${name}`
}

// -- or --

const sayHello = (name: string) => `Hello ${name}`
{% endhighlight %}

Compare to JS, the only extra overhead here is the `: string` annotation.

C# could learn from this kind of type inference.

## 3. You can auto generate TypeScript classes from C#

I've made good use of the CsToTs package to auto generate TypeScript classes from C# classes.

https://www.nuget.org/packages/CsToTs/

https://github.com/DogusTeknoloji/cs-to-ts

When dealing with an HTTP API written in C#, the chances are that a good number of the classes in your
front end code will be returned by the API. Being able to auto generate these saves development time and
reduces the chance of TS classes being out of step with their C# counterparts.

## 4. TS works nicely with React

{% highlight ts %}
import React from 'react'

interface IProps {
  example1: boolean
}

interface IState {
  example2: string
}

const ExampleComponent = class extends React.Component<IProps, IState> {
  state = {
    example2: 'example'
  }

  render() {
    return <>{this.state.example2}</>
  }
}
{% endhighlight %}

A stupid example, but I'm attempting to show that there's a bit of overhead with having to specify what your props and state are,
but very little else. The benefit here is that you then get intellisense on your state and props which is really nice. So many
times when working on React components I have to flick back and forth to remind myself what the props are when using a component.

Now VSCode will tell me, and in fact complain when I get it wrong.

## 5. Duck typing for the win

{% highlight ts %}
// define a class
class Foo {
  bar: string
}

// you can either create it using its constructor
const foo1 = new Foo()

// or just provide an object that looks the same
const foo2 = {
  bar: ''
}
{% endhighlight %}

## 6. --strictNullChecks

The `--strictNullChecks` switch stops you from having null values for variables or properties, unless you explicitly allow nulls.

{% highlight ts %}
let x: number
x = null  // compilation error
{% endhighlight %}

## 7. Expressive type system

I won't go into all the details, but union types, nullable types, and string enums are all nice (and useful) features.

## 8. Enabling VSCode

One of the greatest advantages is that the type information gives VSCode much more to work on. It allows intellisense to provide
much more support which saves a lot of time, both in terms of going and figuring out the names of variables/properties, and in
terms of catching bugs at the time of writing/compilation.

# Conclusion

If you're struggling with maintaining a large JavaScript codebase take a look at TypeScript. It's not that bad.

I honestly believe that the extra learning required to use TypeScript, and the overhead in terms of keystrokes to annotate the types
is quickly regained by the productivity boost and reduced bugfixing.
