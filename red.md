---
layout: page
title: "Slinky"
description: ""
---
{% include JB/setup %}

# Replicated Edge Distribution, RED

One of the big problems with distributed traversals is fetching all vertices involved in the query while minimizing the number of network hops. It follows that an ideal graph would have all the vertices required for a query on the same node. 

It is extremely difficult for an algorithm to always figure out the best way to partition a graph across multiple nodes, that would yield an ideal distribution for any query. Even if the user provided some kind of meta-data, a change in access pattern at the application level is likely to render the meta-data redundant or incorrect to the extent where the old distribution creates a bottle neck or causes too many network hops leading to network saturation or other failures.

On the premise that minimizing or removing network hops is an absolutely requirement which, if achieved will provide a huge improvement to query performance; It would be ideal if the entirety of any query could be performed on a single node. 

The problem with bringing all data on a cluster on to a single node is it defeats the purpose of having a cluster in the first place. However, observe that in order to perform a query only the edges are required.

Every edge that's created is sent to each replica node in the cluster.
The SVC stores the edge information (from and to vertices).

OR

Using consistent hashing a vertex goes to it's node and replicas
When an edge is added the edge is stored on both nodes the edge points to.
Starting a query from any node, consistent hashing determines which node becomes leader the same way the decision would be made of where to place the vertex.
When a query is run the leader will have a copy of all the edges needed to complete the query, without making any network requests.

For e.g. in a 3 node cluster with labels A,B,C, the following are created.
Vertices 1...10 
Edges (1,2),(2,3),(2,4),(1,4),(3,8),(4,8),(5,8),(4,6),(4,7),(2,6),(2,8),(1,9),(7,10) 

Assume vertex id ~= hash

Assume the data is distributed across the three nodes with consistent hashing such that the following distribution is achieved.

A 	B 	C
1	2	3
4	5	6
7	8	9
10	11	12

data Vertex = Vertex { name::String, id:Int }
data Edge = { from::Vertex, to::Vertex, directed::Bool }

add :: Vertex -> None
add :: Edge -> None


The following is a dry run of what would be added to each node A,B,C

Edge 	Send to 	Edges on A 				Edges on B 			Edges on C
===========================================================================
1,2		A,B 		1,2						1,2
2,3		B,C 								2,3					2,3				
2,4		A,B 		2,4						2,4
1,4		A 			1,4
3,8		B,C 								3,8					3,8
4,8		A,B 		4,8						4,8
5,8 	B 									5,8
4,6 	A,C 		4,6											4,6
4,7 	A 			4,7
2,6 	B,C 								2,6 				2,6
2,8 	B,C 								2,8					2,8
1,9 	A,C 		1,9 										1,9
7,10 	A 			7,10
===========================================================================
Total				8						8					6




The following are example queries:

Depth first search assuming a directed graph where no loops are allowed.

Starting from 4, which belongs to node A.
4->8->6->7->10

Starting from 1, which belongs to node A
1->2->4->8->6->7->10 __[FAIL]__ 2->3 but is not available on A.