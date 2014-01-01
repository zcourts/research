---
layout: page
title: "Rated resource access windows, 2RAW"
description: "Describes the rated resource access windows management algorithm"
---
{% include JB/setup %}

# Abstract - Introduction

It is often the case that the system resources that are needed the most are the most limited. The primary resource considered here is system file descriptors (network connections included). While it would be ideal if we could maintain an open file or a network connection persistently, doing so often causes undersirable side effects, and in the case of a Linux system there are often very restrictive limits (configurable but still restrictive). {% cite cardwell2000modeling %} for example has shown that startup activities such as connection establishment and TCP slow start often domminate the latency involved in network communication.


Here, a resource management algorithm is proposed which takes a different approch to reducing access latency (particularly, first access). {% cite griffioen1994reducing %} have taken a similar approach by attempting to predict usage and pre-fetching data and {% cite padmanabhan1996using %} have explored the predictive approach for networks. The trade of between time and space skews towards space being traded for the reduced latency in the case of file systems. Unfortunately an undesired side effect of such approach is the increased IO as not all data pre-fetched is always required/used.

2RAW is similar but stops short of fetching data unless it is known 100% that the entirety of what is fetched will be used. The connected property of graph data means we know that given a series of connected vertices, unless a stop criteria prevents it, each Vertex will be accessed in the order the are connected. Further, we can predict which data files will be accessed the most using historical access metrics to determine "hot" files and thus pool the connection or file handle.

# Resource management

2RAW is a combination of two things, pooling/caching the most used file descriptors and prefetching data only when it is guaranteed that the data fetched will be used in its entirety. 

## Resource access windows

The resource manager is configured to maintain the top n file descriptors. Using the access windows file descriptors "bubble" to the top. Any open files above n are closed immediately until the next request that demands it. Access windows can be described as:

For every time tick t where a file is accessed its file descriptor earns a +1 rating. For each tick where the file isn't accessed, the file descriptor gets a -1 rating. These ratings are cumulative. A tick is a unit of time which begins from the last time a file descriptor was used (usage includes read and write operations). Every operation creates a new window of time during which if the file is used it gains a rating and after which if it hasn't been used it loses a rating. The following pseudo-code describes how resource access windows works:

{% highlight bash %}
t = 10s # how big is a tick?
n = 250 #max number of files descriptors to cache
h = 0 # value at which a file is removed independently of Q eval
priorityQueue = {}

open(p)
	if priorityQueue.contains p
		f = priorityQueue[p]
		tick(f)
		return f
	f = openFile(p)
	while(priorityQueue.size >= n)
		destroy(priorityQueue.pull_minimum_element)
	priorityQueue += f
	tick(f)	
	return f

read(f)
	tick(f)
	...

write(f)
	tick(f)
	...

tick(f)
	if f.scheduled
	   f.ts.cancel
	   f.scheduled = False
	f.rating += 1	

	f.scheduled = True
	f.ts = after t
			f.rating -= 1
			if f.rating <= h
				priorityQueue -= f
				destroy(f)

destroy(f)
	f.close				
{%endhighlight%}

Given the max number of file descriptors, n to manage; the time unit considered to be 1 tick, t; the threshold at which a file is considered "not hot enough" to be managed, h and a priority queue which ranks it's items using the ratings value, the algorithm proceeds as such. 

When a file is opened, If the file is in the priority queue it is returned and ticked, otherwise the file is opened.

Once opened, if the priority queue's size is at least n, file descriptors starting with the lowest rated are removed from the queue and destroyed. The new file descriptor is then added, ticked and returned.

Each file operation open, read and write results in a tick. 
A tick checks if a file descriptor has been scheduled for a rating. If it has, the schedule is cancelled. The file descriptor then receives a +1 rating and is marked as scheduled.
The scheduling occurs as a background task and after a time tick, t has passed, the scheduler runs. If a scheduler runs it means there hasn't been a tick early enough to cancel the scheduler, hence the file descriptor receives a -1 rating. The scheduler then proceeds to check if the rating after the -1 results in the file descriptor having a rating equal to or below the allowed threshold. If so, the file descriptor is removed from the queue and destroyed.

Two important things happen as a result of this algorithm, if a file is constantly being used, it is kept open, the more the file is used the longer it is kept open as it will take more -1 ticks for it to be destroyed. 

Secondly resource usage remains proportional to system usage, i.e. if for some reason no files are being used by the system, then the resource manager will eventually close all file descriptors automatically when all the files reach the threshold after not being used. This means that even if the process remains running forever, it'll never keep a file descriptor permanently open unless it was being used.

_Side note:_ If a priority queue's implementation doesn't support O(1) lookup (i.e. hash based) then the manager can include a hash map which maintains the path => file descriptor and both the map and queue are updated during addition or removal. Operations are done to the queue first.

## Guaranteed data access prediction


## References

{% bibliography -c %}