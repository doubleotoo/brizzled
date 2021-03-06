---
layout: post
comments: true
title: "Running a Ruby block as another user"
date: 2011-01-01 00:00
categories: [ruby, unix, processes, programming]
---

Recently, on [stack**overflow**][SO], someone asked:

> Can you execute a block of Ruby code as a different OS user?
> 
> What I, ideally, want is something like this:
> 
>     user("christoffer") do
>       # do something
>     end

My proposed solution, for Unix-like systems, turns out to be trivial and
seems worth blogging about. It makes use of:

* Ruby's block syntax, which allows a block of code (between `do` and `end`,
  or between curly brackets) to be passed, as an object, to a function.
* Ruby's [`etc` module][Ruby-etc] which, on Unix-like systems, allows
  access to the password database via familiar functions like `getpwnam`.
* Ruby's [`Process` module][Ruby-process], for forking a child process.

The function to run a block of Ruby code as another user is trivial:

{% gist 757519 %}

Using the function is also trivial:

<script src="https://gist.github.com/761820.js?file=asusertest.rb"> </script>

Of course, the calling code has to be running as *root* (or *setuid* to
*root*) to switch to another user. Running the above code on my Mac OS X
laptop yields this output:

    $ sudo ruby u.rb
    Caller PID = 98003
    Caller UID = 0
    In child process. User=bmc, PID=98004, UID=501

[SO]: http://stackoverflow.com/questions/4548151/run-ruby-block-as-specific-os-user/
[Ruby-etc]: http://ruby-doc.org/core-1.9/classes/Etc.html
[Ruby-process]: http://ruby-doc.org/core-1.9/classes/Process.html
