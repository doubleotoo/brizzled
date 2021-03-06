---
layout: post
comments: true
title: "War Stories: Deadlocks and Semaphores"
date: 2005-08-28 00:00
categories: [phlx, deadlock, programming, semaphore]
---

At [work][] a couple of days ago, we had a
lively discussion about deadlocks and deadlock avoidance, as it
relates to our product. The discussion somehow reminded me of my
first job, and similar problems we sometimes encountered there.

After graduating from [Temple University][]
in 1983, with a degree in computer science, I took a job with the
[Philadelphia Stock Exchange][], working in the
small group that built and maintained its
[online trading system.][]
The system was written in an extended and robust dialect of the
[Pascal programming language][],
and it ran on Honeywell DPS-6/90 minicomputers.

This system used two locking mechanisms to protect access to
[critical regions][] of code. The first locking mechanism was an explicit
system lock (a system [semaphore][])), and the second was a priority switch. We
had three classes of processes. Each class ran at a different priority; within
a class, all processes ran at the same priority. If you had to lock a resource
(e.g., a queue) that could be used across process classes, you had to use the
more expensive system semaphore. If you simply wanted to lock a region of
memory that was shared by processes *within* a class, you made a significantly
cheaper system call that temporarily raised the process's priority, ensuring
that none of its brethren could preempt it until it finished; at the end of the
critical region, you'd make another call to reset the process's priority.

Obviously, attempting to put something on a queue (thus using a semaphore)
within a "raised priority" region was a strict no-no, because it could result
in a deadlock. Naturally, there were occasional bugs, usually in code written
in haste under deadline pressure, where that happened. Having a real-time stock
trading system grind to a halt because of a hard-to-reproduce deadlock (or, for
that matter, because of *any* bug) was no fun. As we sat in the computer room
at the console, desperately trying to diagnose the problem (not always easy to
do), Stock Exchange VPs would start to trickle in. A row of executives with
crossed arms and tapping feet is not conducive to solving a deadlock problem.

[work]: http://www.fulltilt.com/
[Temple University]: http://www.temple.edu/
[Philadelphia Stock Exchange]: http://www.phlx.com/
[online trading system.]: http://www.clapper.org/bmc/resume/resume.html#centramart
[Pascal programming language]: http://en.wikipedia.org/wiki/Pascal_programming_language
[critical regions]: http://en.wikipedia.org/wiki/Critical_region
[semaphore]: http://en.wikipedia.org/wiki/Semaphore_(programming
