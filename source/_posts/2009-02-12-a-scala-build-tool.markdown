---
layout: post
comments: true
title: "A Scala build tool"
date: 2009-02-12 00:00
categories: [scala, ant, rake, make, DSL, programming]
---

I've decided to write a build tool in [Scala][].

(**Update**: No, I haven't. See [below](#update1).)

# Because I don't like Ant

For awhile now, I have truly disliked [Ant][], the standard build utility
for Java. Ant (and [Maven][]) use XML build files, which means you're often
standing on your head to get around limitations imposed by the choice of
XML as a syntax.

<!-- more -->

I dislike the whole trend of using XML as a configuration file format. Yes,
XML is human-readable. But it isn't always human-*friendly*. I agree with
[Terence Parr][], author of [ANTLR][] and [StringTemplate][], who wrote, in
2001, that XML is a poor human interface:

> XML should be a safe bet for most of your program-to-program data format
> needs. What about programs, specifications, initialization files, and the
> like that are conversations between a human and a computer? In this
> section, I hope to convince you that humans should not have to write and
> grok XML. Besides the many existing standard special-purpose languages
> that provide superior interfaces, XML is about as far away from natural
> human language as you can get.

See "[Humans should not have to grok XML][]".

# And then there's *make*

Meanwhile, our old friend, [*make*][], uses a syntax that is good and bad.
What's good is that it's relatively easy to see what depends on what.
However, make's tab-sensitive syntax is problematic, and it uses an
external shell process as its "programming" language, which imposes
overhead and restricts expressiveness.

Martin Fowler talks about many of these issues in his 2005 article entitled
"[Using the Rake Build Language][]".

# A build file is ...

In my view, a build file serves two main purposes:

1. It is a manifest, of sorts, for the components of the system being built.
2. It must be able to contain custom logic for building, since there are
   often site-specific or project-specific tasks that must be performed.

As my friend and former colleague, Steve Sapovits, and I have often
argued in the past, build files are code. They are maintained like
code, they can be buggy like code, and they often require
"escaping" to code to do things.

So why not *make* them code?

# The Rake approach

That's what Rake did. A Rakefile is pure
[Ruby][], surrounded by an infrastructure
to manage dependencies, build certain common things, etc. But the
syntax of Rake is Ruby--simplified and customized by an internal
[DSL][] built
using native Ruby semantics. Thus, any editor or IDE that speaks
Ruby can handle a Rakefile. Better yet, if you have to do something
custom, something that the built-in Rake tasks cannot do, you have
the full power of Ruby at your disposal, right there in the
Rakefile.

Contrast that approach with Ant or *make*.

* You can customize Ant, but you can only get the full power of a real
  programming language by writing an Ant task in Java (or another JVM
  language), compiling it, and making it available to Ant. You can't put
  little scriptlets of Java in an Ant file.
* With *make*, you're pretty much stuck with either the shell, with all its
  limitations, or (in the case of [GNU Make][]), a macro syntax that
  becomes all but unmaintainable if you define complex macros (which I've
  done).


I much prefer the Rake approach.

# Python?

Since I do a lot of development in [Python][] these days, I tried building
a Rake-like tool in Python. I know there are existing Python build tools,
such as [SCons][], [Vellum][], [zc.buildout][] and [Paver][], but I wanted
something that used a simpler build file syntax, more akin to a classic
Makefile, while retaining the full power of Python.

It was a fun project, but Python presented some DSL limitations
that Ruby does not have. For instance:

* In Python, you cannot capture an arbitrary block of code and save it for
  later. In Ruby (and Scala), you can. You can define a [lambda][] in
  Python, but lambdas have syntax limitations that make them unfriendly in
  this particular context. You can capture a function, but I wanted a
  simpler, more make-like syntax, instead of requiring people to define
  functions all over the place.
* Python does not permit you to override operators. While this isn't a big
  deal at all in typical Python programming, it's awfully useful when
  defining a DSL.

As a result, the Python build tool (which I actually did implement, but
never released) uses a special external DSL that permits embedded snippets
of Python. (It uses David Beazley's excellent [PLY][] Python lex and yacc
implementation to parse the file.)

But, of course, the resulting build file isn't actually Python, even if it
does contain Python, so none of my editor modes or IDEs grok the syntax.

# Enter Scala

Meanwhile, I've been playing with Scala. Like Ruby, Scala has a looser
syntax (though, unlike Ruby, it's type safe). The relaxed syntax, along
with Scala's operator overloading, closures, and other features, permit the
definition of pretty powerful internal DSLs. So I decided to try an
experiment.

Using very little code, I was able to create a DSL that supports this
syntax:

{% codeblock lang:scala %}
    target("foo") -> ("foo.o", "lib.a")
    
        target("bar") -> ("bar.o", "lib.a") ===
        {
            // Scala logic goes here
        }
{% endcodeblock %}

Further, by judicious use of an [implicit conversion][], I was able to
remove the need for a `target()` function entirely, so that the following
syntax is equivalent to the above:

{% codeblock lang:scala %}
    "foo" -> ("foo.o", "lib.a")
    
        "bar" -> ("bar.o", "lib.a") ===
        {
            // Scala logic goes here
        }
{% endcodeblock %}

The code I wrote does not include any of the supporting build logic,
because I haven't implemented that yet. But the syntax is simple and easy
to understand, while retaining the ability to use Scala.

Just as a Rakefile is Ruby, this is perfectly legal Scala, provided my
small DSL classes are in scope. Thus, custom Scala build logic can use any
Scala or Java code that's in the CLASSPATH, and the build file can define
its own Scala classes and functions, as necessary.

For my money, that's way better than Ant.

I've decided to build this tool. It's a small and well-defined project that
I can use to come up to speed on Scala. And, when it's done, I intend to
replace all my uses of Ant with this Scala-based build tool. Maybe I'll
even include an Ant adapter, enabling me to make use of existing Ant tasks.

# Update: July 19, 2009 # {#update1}

I've finally taken the time to play with both [Gradle][] and [SBT][].
(Thanks to Daniel Spiewak for the pointers.) Both tools are easy to
configure and have built-in support for external dependency management
(i.e., what [Maven][] and [Apache Ivy][] do).

Rather than spend time building yet another tool that does exactly the same
thing (only with a different syntax), I've elected to go with [SBT][]. See
my [blog post][] on SBT.

[Scala]: http://www.scala-lang.org/
[Ant]: http://ant.apache.org/
[Maven]: http://maven.apache.org/
[Python]: http://www.python.org/
[Terence Parr]: http://www.cs.usfca.edu/~parrt/
[ANTLR]: http://www.antlr.org/
[StringTemplate]: http://stringtemplate.org/
[Humans should not have to grok XML]: http://www.ibm.com/developerworks/xml/library/x-sbxml.html
[*make*]: http://en.wikipedia.org/wiki/Make_(software)
[Using the Rake Build Language]: http://martinfowler.com/articles/rake.html
[Ruby]: http://www.ruby-lang.org/
[DSL]: http://en.wikipedia.org/wiki/Domain-specific_language
[GNU Make]: http://www.gnu.org/software/make/
[SCons]: http://www.scons.org/
[Vellum]: http://www.zedshaw.com/projects/vellum/
[zc.buildout]: http://www.python.org/pypi/zc.buildout
[Paver]: http://www.blueskyonmars.com/projects/paver/
[lambda]: http://p-nand-q.com/python/stupid_lambda_tricks.html
[PLY]: http://www.dabeaz.com/ply/
[implicit conversion]: http://www.artima.com/weblogs/viewpost.jsp?thread=179766
[Gradle]: http://www.gradle.org/
[SBT]: http://code.google.com/p/simple-build-tool/
[Maven]: http://maven.apache.org/
[Apache Ivy]: http://ant.apache.org/ivy/
[SBT]: http://code.google.com/p/simple-build-tool/
[blog post]: /id/92/
