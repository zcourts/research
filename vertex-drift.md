---
layout: page
title: "Vertex Drift"
description: "Describes the vertex drift distributed graph partitioning algorithm"
---
{% include JB/setup %}

# Abstract - Introduction

Here I propose "Vertex Drift" a dynamic partitioning algorithm suited to the [query model](/query-model.html) being used in the Tesseract. Most current dynamic graph partition algorithms are focused on inter processor communication and data migration, i.e. on a single node. {% cite walshaw1997parallel %} for example introduces the relative gain optimization technique. This and other algorithms require some amount of data migration or are iterative techniques. Vertex drift requires neither iteration or data migration and instead of working with multiple processors it is focused on working with multiple machines. It borrows ideas from Dynamo's virtual nodes {% cite dynamo %} to create a technique where by a vertex or some of it's data splits, and pieces "drift" around the cluster. The Tesseract query model where "markers" and path prediction are used, means that when a vertex is drifted around the cluster we know a lot about a vertex in advance. Using the vertex drift algorithm, only {%m%}O(2n){%em%} messages are required for a traversal (in the worse case) which involves the vertex, where  {%m%}n{%em%} is the number of nodes in the cluster. Only  {%m%}O(n){%em%} messages are required in the best case.

# Background - Why is this needed?

Every day graphs as they occur in the real world can be very disproportionate. This makes it tricky to create an algorithm that will automatically partition data in a reasonable way that ensures minimum network communication during traversals.

As an example, consider the social graph for some Twitter users with 40+ million followers, while the average number of followers for a twitter user is only about 200. The following images represent the number of followers, those they follow and Tweets from Justin Bieber, Kety Perry, Lady Gaga and myself.

![Number of Justin Bieber followers](/assets/bieber-graph.png "Number of Justin Bieber followers")
![Number of Katy Perry followers](/assets/perry-graph.png "Number of Kety Perry followers")
![Number of Lady Gaga followers](/assets/gaga-graph.png "Number of Lady Gaga followers")
![Number of Courtney Robinson's followers](/assets/zcourts-graph.png "Number of Courtney Robinson's followers")

These images form a clear demonstration of how ill proportioned a real world graph can be. The question now becomes, how can the relationship of each of these disproportionate vertices be stored such that, traversal is evenly spread across the cluster. One answer is vertex drift, by splitting up the number of in and out edges across multiple machines with this technique a traversal involving this vertex can run against in or outbound edges in parallel across the entire cluster.

# Edge partitioning

Based on the concepts in [virtual nodes](http://www.datastax.com/dev/blog/virtual-nodes-in-cassandra-1-2) from Dynamo and implemented in Cassandra. While the application is different it is a similar concept with optimizations for graphs.


## References

{% bibliography -c %}