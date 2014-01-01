---
layout: page
title: "Mega Push Gossip - MPG"
description: "Describes Mega Push Gossip - MPG a push push pull, gossip pprotocol"
---
{% include JB/setup %}

# Mega Push Gossip - MPG

Mega (as in Megaphone) Push Gossipe, MPG is a gossip algorithm favouring push epidemic but taking advantage of pull where appropriate.

There are lots of gossip algorithms out there. Most of them use a communication model that doesn't directly send messages to nodes in the cluster, instead, information is disseminated by spreading the message with a sub-set of the nodes that'll in turn spread the message to another sub-set until all nodes have gotten the message. Often it takes O(log(n)) hops for all nodes to be updated.

While this is perfectly reasonable and appropriate for the scenarios they were designed for, it is somewhat unnecessary in a distributed database scene. Typically a single cluster has machines in the thousands, not hundredsof thousands or millions, as evidenced by the usage of projects like Hadoop, where [Yahoo!](http://wiki.apache.org/hadoop/PoweredBy#Y) with the largest known cluster is only at 4500 nodes.

Current distributed databases are not really distributed. While their architecture tends to be designed to scale to millions or billions of nodes in a cluster, other practical limitations (usually network/hardware related) often prevent them getting anywhere near the theoretical limits of the architecture/algorithms.

#### Differences and similarities to other gossip algorithms

* MPG is a modification and merger of various gossip protocols. In reality Push Push Pull is a somewhat more suitable name because it ends up pushing at least twice as much information as it pulls. 

* The modification in the protocol is the use of O(1) communication for most operations, or all if possible. 

* Where latency or resource constraints demand it, a fanout approach is used to disamminate messages in O(log(n)) hops.

* In a typical gossip protocol a single node has a partial view of the cluster, MPG changes this so that every node has a complete view, with direct access to routing information of each.

### True cost of gossip

Gossip algorithms are typically described in terms of the number of network hops required to get all nodes up to date. While some mention the total time it takes the focus is often on network hops. With MPG, the cost of gossip has to be calculated differently. MPG assumes TCP over UDP for transmission to help improve delivery reliability. 
 
#### The latency problem 

Firstly, let's define some terms that may be used to discuss the properties of one gossip protocol.
Let:

1. `b` be buffer size of a node, i.e. the number of messages it buffers
2. `t` be a limited number of hops or time steps, i.e. how far down the hierarchy a message from a node is disseminated. If it starts at A in a cluster up to F, where does dissemination stop, B,C,D,..?
3. `f` be the number of randomly select nodes a message is forwarded to each time, i.e. how many nodes it sends messages to
4. `n` be the number of nodes in the cluster.
5. __`R`__ be the number of _r_ounds/hops required for all nodes to be updated

![Diagram of message dissemination from UCL](/assets/gossip-b-f-t.png "Diagram of message dissemination from UCL")

Some gossip algorithms are based on mathematical models of epidemics and how they spread. Two such models are called the "infect and die" and "infect forever" models.Bella Bollobás {% cite bollobas2001random %} (reviewed in {% cite eugster2004epidemic%})has shown that in an "infect and die" or "infect-forever" model, the number of rounds {%m%}R{%em%} necessary to infect the entire system is

{% math %} 
R = \frac{log(n)}{log(log(n)))} + O(1)
{% endmath %}

This assumes the number of f targets for contamination is {%m%}log(n){%em%}.


In these models, if a cluster has 100 nodes and communication of a message is required to spread a message would take

{% math %} 
R = \frac{log(100)}{log(log(100)))} + O(1); R = 7.64
{% endmath %}

To satisfy f, n would have to be 2, i.e. log(100) = 2 randomly selected nodes will have a message forwarded to them in each round. 

In a distributed network, say a mobile network with millions of users, the model is fine and works really well in terms of scalability. In a distributed database however with thousands of nodes or even 100 thousands nodes, the priority is often latency AND the number of messages. Depending on what the gossip protocol is being used for, a message can be emitted at millisecond intervals with expected response times within milliseconds as well. Using the infect-forever or infect and die approach, we can model an estimated latency for dissemination.

This is a simple model that will assume the latency between each node in the cluster is a constant time {%m%}k{%em%}. {% cite cardwell2000modeling %} shows that in a real world scenario latency is more variable and is dominated by startup effects such as establishing a connection and slow start. They present an approach for modelling TCP latency which takes into account transfer-size, round trip time and packet loss rate. The model presented here however somewhat neglects the dynamic nature of latency and assume it to be constant because even with a constant (low or high), the cumulative latency involved in the infect and die approach is demonstrably higher. In other words just using a constant is enough to prove the point.

Secondly, we assume that each node that recieves a message immediately forwards it and hence that the time taken between receiving a message and forwarding it is negligible. In practice however, not all nodes will be able to forward a message as soon as it is received and this will added to the overall perceived latency of disemminating a message.


Let {%m%}R{%em%} be the number of rounds as defined above, {%m%}n{%em%} the number of nodes in the cluster, {%m%}k{%em%} the latency per round. To spread a message to {%m%}n{%em%} nodes, it takes {%m%}R{%em%} rounds. Each round incurs a latency of {%m%}k{%em%}. Hence the latency to disseminate a message is simply the cumulative of the lot {%m%}l{%em%}:

{%math%}
l = \sum\limits_{r = 1}^R k
{%endmath%}

For a message which requires a response that can be modified as
{%math%}
l = 2 \left( \sum\limits_{r = 1}^R k \right)
{%endmath%}

Naturally, the value k can be determined {% cite cardwell2000modeling %} or other just latency prediction models. In real terms, this means that if there are 100 nodes in the cluster and a constant per round latency of 50 milliseconds, sum over k, from 1 to 7

{%math%}
l = \sum\limits_{r = 1}^{7} 50 \equiv 50 + 50 + 50 + 50 + 50 + 50 + 50 = 350ms, 2(350) =700ms
{%endmath%}

i.e given those assumptions, 350ms for a single message and 700ms for a response.

## The number of messages problem

Only the latency has been considered so far, the number of messages involved in a fanout approach however is also very important. In a distributed database, data is constantly being moved, added and queried, failures and other others are constantly adding to the number of messages that are having to be sent. {% cite voulgaris2007hybrid %} has shown that message overhead increases proportionally to the fanout. The network is a very finate and important resource. Ideally any communication protocol would not send any more messages than was absoluately necessary, in a data intensive system such as a database, a network can easily become saturated. The ideal protocol would help prevent staturation by sending a little meta-data as possible.



* [Université Catholique de louvain, UCL - Gossip lecture](http://www.info.ucl.ac.be/courses/SINF2345/2010-2011/slides/10-Gossip-lecture-hand.pdf)
* [Gossip Algorithms, MIT](http://web.mit.edu/vdb/www/6.977/l-shah.pdf)
* [T-Man: Fast gossip-based construction of large-scale overlay topologies](http://lex104.cs.unibo.it/pub/UBLCS/2004/2004-07.pdf)

## References

{% bibliography -c %}