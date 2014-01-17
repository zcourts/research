---
layout: page
title: "Mega Push Gossip - MPG"
description: "Describes Mega Push Gossip - MPG a push push pull, gossip pprotocol"
---
{% include JB/setup %}

# Abstract - Introduction 

There are lots of gossip algorithms out there. Most of them use a communication model that doesn't directly send messages to nodes in the cluster, instead, information is disseminated by spreading the message with a sub-set of the nodes that'll in turn spread the message to another sub-set until all nodes have gotten the message. Often it takes O(log(n)) hops for all nodes to be updated.

While this is perfectly reasonable and appropriate for the scenarios they were designed for, it is somewhat unnecessary in a distributed database scene. Typically a single cluster has machines in the thousands, not hundredsof thousands or millions, as evidenced by the usage of projects like Hadoop, where [Yahoo!](http://wiki.apache.org/hadoop/PoweredBy#Y) with the largest known cluster is only at 4500 nodes.

Current "distributed" databases are not really distributed in the same sense that say, a mobile network's users are distributed. While their architecture tends to be designed to scale to millions or billions of nodes in a cluster, other practical limitations (usually network/hardware related) often prevent them getting anywhere near the theoretical limits of the architecture/algorithms.

### True cost of gossip

Gossip algorithms are typically described in terms of the number of network hops required to get all nodes up to date. While some mention the total time it takes the focus is often on network hops. With MPG, the cost of gossip has to be calculated differently. MPG assumes TCP over UDP for transmission to help improve delivery reliability. 
 
### The latency problem 

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

### The number of messages problem

Only the latency has been considered so far, the number of messages involved in a fanout approach however is also very important. In a distributed database, data is constantly being moved, added and queried, failures and other others are constantly adding to the number of messages that are having to be sent. {% cite voulgaris2007hybrid %} has shown that message overhead increases proportionally to the fanout. The network is a very finate and important resource. Ideally any communication protocol would not send any more messages than was absoluately necessary, in a data intensive system such as a database, a network can easily become saturated. The ideal protocol would help prevent staturation by sending a little meta-data as possible. In such a protocol, only failure or unexpected events should cause multiple messages to be sent for the same purpose.

# Mega Push Gossip - MPG

Mega (as in Megaphone) Push Gossipe, MPG is a gossip algorithm favouring push epidemic but taking advantage of pull where appropriate.

### Differences and similarities to other gossip algorithms

* MPG is a modification and merger of various gossip protocols. In reality Push Push Pull is a somewhat more suitable name because it ends up pushing at least twice as much information as it pulls. 

* The modification in the protocol is the use of O(1) communication for most operations, or all if possible. 

* Where latency or resource constraints demand it, a fanout approach is used to disamminate messages in O(log(n)) hops.

* In a typical gossip protocol a single node has a partial view of the cluster, MPG changes this so that every node has a complete view, with direct access to routing information of each.

### Complete view of the world

Nodes in ogssip protocol usually only have a partial view of the cluster for one reason or another. This is typically due to these protocols not being designed specifically for environements with an abundance of memory and are expected to have millions of nodes. For a database however, this assumption is not applicable, servers typically have 10s of gigabytes of RAM dedicated to handling the database. Even without this much memory a complete view of the cluster with routing information for millions of nodes can easily be represented in megabytes of memory.

Assume there are 1 million nodes, n; Each node has a numeric ID, i which is represented by a unsigned 32-bit integer ({%m%}2^{32}-1{%em%}); Routing information (host and port) r, with an average size of 40 bytes. This is the minimal amount of information required to represent all the nodes, other meta data may be included as the system requires but with this information we can estimate that size required to represent all the nodes is:

{%math%}
S = n (r + i)
{%endmath%}
i.e.
{%math%}
1,000,000 (40 + 4) = 44,000,000 bytes; 41.96MB
{%endmath%}

In practice a cluster is unlikely to reach 1 million nodes and for a modest 50K nodes :

{%math%}
50,000 (40 + 4) = 2,200,000 bytes; 2.098MB
{%endmath%}

Only a tiny 2MB is needed. 

### Independent and responsible nodes

With MPG, contrary to other gossip protocols, every node is responsible for itself and letting others know of it's existence and state. Only when a node appears to have failed/disappeared will any other node attempt to contact it. Under normal operation each node must push their state and any information they wish to share to the rest of the world.

## Common/Defined operations

Gossip protocols are used for a varient of reasons, below categorizes how MPG is used and defines some operations for each category. Each node has a numeric ID, this ID is assigned after

### Membership
Each node normally has at least one seed node, unless it is the first node in the cluster. It communicates with the seed nodes to obtain information about the rest of the cluster. Membership operations include:

* world - Request the node being sent the message sends back it's view of the cluster
* world-hash - Request the node being sent the message sends back a merkle tree representing it's view of the cluster
* join - Tell a set of nodes that it is joining
* leave - Gracefully leave the cluster by telling other nodes
* ping - Pings a set of nodes to let them know it's still alive
* pong - The response to a ping acknowledging a node's existence

_note_ When a ping-pong interaction occurs, the node that sent the pong no longer needs to send a ping to the node it sent the pong to, both nodes can be confident that they can speak to each other using these two messages.

### Dissemination and Failure detection
Using gossip to detect failed nodes. If a known node fails to ping or pong there may be a temporary issue or it may have crashed. 

### Anti-entropy
Repairing replicated data (compare replicas and reconcile differences)

### Aggregates
Collect per node stats (load etc), combine to form system wide view

### Reputation
Nodes gain a reputation by being more available and completing more of their tasks without failure. Does the reverse to lose it

* [Université Catholique de louvain, UCL - Gossip lecture](http://www.info.ucl.ac.be/courses/SINF2345/2010-2011/slides/10-Gossip-lecture-hand.pdf)
* [Gossip Algorithms, MIT](http://web.mit.edu/vdb/www/6.977/l-shah.pdf)
* [T-Man: Fast gossip-based construction of large-scale overlay topologies](http://lex104.cs.unibo.it/pub/UBLCS/2004/2004-07.pdf)

## References

{% bibliography -c %}