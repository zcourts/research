---
layout: page
title: "Passing thoughts"
description: "Random thoughts that come to mind"
---
{% include JB/setup %}

## Possible approach to a compressed edge representation

Vertex is sent to each node and assumes a fair if not even distribution of vertices accross nodes.

Each node builds a bit graph of the vertices it currently owns.
A bit graph is a structure that represents edges using a single bit for each vertex.
Each item in the bit set is made of 2 bits. first bit is a vertex and the second bit is the vertex it connects to. if the 3rd bit is a 0 it means the 4th bit represents a vertex not connected to the previous bit/vertex....

locally each node stores a mapping of the bit position to the local vertex id

the bit graph is sent to the tesseri node from all nodes when their vertex set changes over a given threshold. the tesseri then has a complete view of the cluster and can do clustering over the entire graph because each edge is now represented by 2 bits.

This means we can use 8GB to represent up to 34359738368 edges (34.35 billion edges) big enough for many scenarios. Trouble with this and any approach which hoard the entire cluster on one machine is it doesn't take advantage of multiple machines to do the processing...but it's an idea that may be useful in another context so putting it down.

## Look ahead graph traversals

When a query is started, take advantage of the fact that we know all the vertices that will be visited.
For each vertex that is on a remote Node, issue a traversal request to the Node giving the algorithm to use and any traversal criteria. Where possible bulk these requests into one asyn action.

## Approaching as a classification problem

Data/Variables/features available include

* Number of nodes
* Number of vertices for each node
* Vertex density ratio for each node
* Number of vertices migrated to each node over a given time period

K-Means done per cluster???
Number of vertices per node must be balanced
"Rigged Hash" - Hashing a vertex ID goes to a node depending on clustering data

Two phased data organization.
Upon write, use consistent hashing to place vertex in the cluster.

Have a master node, "Tesseri, i.e. Tesseract's eye" whose sole job is to re-organize edges in the cluster to minimize network hops. 

Every edge is known to this node. With  available computing a 256GB machine is only $899 with hardware raided 1TB SSD and $679 with spindle disks from http://iweb.com/dedicated-server - there may be cheaper options.

This means practically speaking 20 billion vertices can be represented (8 bytes per vertex ID) in 150GB of RAM.

A data structure which borrows ideas from the log-structured merge tree means that even a much smaller RAM can be used, storing some data in memory and merging any overflow to an on-disk file/s. The obvious benefit to bigger ram is faster traversal in memory.

The Tesseract DB must have no single point of failure. As such the any node in the cluster can be elected to be the Tesseri. There are always at least two Nodes marked one is the current Tesseri and the other is the fallback should the first fail.

Only the current Tesseri has a copy of all edges in the cluster. If the current Tesseri fails it would have organized the cluster already so the backup Tesseri can aquire a copy of all edges, after a failure occurs. The assumption being that the backup Tesseri would be able aquire a copy of all edges before the graph becomes imbalanced enough to cause severe traversal problems.

While a node is the Tesseri it should be configurable that it is not considered a part of the cluster. So it doesn't take part in traversals and focus only on keeping the graph distribution balanced...alternatively it is worth exploring using the Tesseri as the node that performs all traversals...


## Slinky Compaction for append only file systems

Taking ideas from Haskell and Cassandra. Using an append only data structure requires compaction in order to clean up deleted or out of date versions.

Instead of doing a background clean up task which can hog resources. Use two files one is the current file being appended to and the second is the previously written to file. Data from the old file pours over from the old file to the new one while it also accepts new data. The fact that old and new data is interleaved doesn't matter because the file index is also written with this slinky like format. Once old data pours over completely into the new one, the old file is removed and the new one continues to be used until it is determined that the process should start again. This reduces the overhead associated with compactions. I've done the experiment with files up to 150GB and recorded a large improvement. Details and exact numbers will be published when I get the time to write everything up in Jan/Feb 2014. (TODO: Write up a page with the results and prepare a paper for publishing)