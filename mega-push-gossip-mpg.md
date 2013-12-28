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
 
#### Other Gossip protocols

Firstly, let's define some terms that may be used to discuss the properties of one gossip protocol.
Let:

1. `b` be buffer size of a node, i.e. the number of messages it buffers
2. `t` be a limited number of hops or time steps, i.e. how far down the hierarchy a message from a node is disseminated. If it starts at A in a cluster up to F, where does dissemination stop, B,C,D,..?
3. `f` be the number of randomly select nodes a message is forwarded to each time, i.e. how many nodes it sends messages to
4. `n` be the number of nodes in the cluster.
5. __`R`__ be the number of _r_ounds/hops required for all nodes to be updated

![Diagram of message dissemination from UCL](/assets/gossip-b-f-t.png "Diagram of message dissemination from UCL")



In other gossip protocols if a cluster has 100 nodes and communication of a message is required. Assuming each node

#### Sources

* [Université Catholique de louvain, UCL - Gossip lecture](http://www.info.ucl.ac.be/courses/SINF2345/2010-2011/slides/10-Gossip-lecture-hand.pdf)
* [Gossip Algorithms, MIT](http://web.mit.edu/vdb/www/6.977/l-shah.pdf)
* [T-Man: Fast gossip-based construction of large-scale overlay topologies](http://lex104.cs.unibo.it/pub/UBLCS/2004/2004-07.pdf)

## References
{% bibliography -c %}