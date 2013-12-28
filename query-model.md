---
layout: page
title: "Query dissemination and result accumulation"
description: "Describes how a traversal query is disseminated and it's results accumulated"
---
{% include JB/setup %}

## Dissemination

## Accumulation

## Query modes
Different cases may demand a different query mode depending on the amount of potential data in the result. There are two modes, namely immediate or synchronous and deferred or asynchronous modes.

### Immediate/Sync queries

Immediate query mode runs queries where the expected result set can easily fit in memory. When this query mode is used the query's leader disseminates the query, accumulates the result in its entirety before returning everything to the client.

### Deferred/Async queries

Deferred queries can handle a result set of any size. When the other nodes involved in the query return results the results are immediately pushed to the client.

## Persistent, long lived, real time graph traversals

In real-time situations queries can be left running. Only async queries can support this and as new vertices or edges are added that match a query, they are immediately accumulated and pushed to the client. If the client for a persistent query has disconnected, its data can be disk cached locally on the query's leader node. When the client reconnects the cached results can be delivered.

## Path prediction

Given a query and any data at any given time. Predict which vertex will be involved. If on a different node then issue the query on that node. And the results can all be accumulated. Does the resulting traversal converge, such that were the query done sequentially any vertex that would have been traversed has been?
If that is the case and the prediction can be made extremely early in the traversal then the result should be that any query is completely performed in parallel.
Perhaps one approach is to predict vertices every n-hops. Then using the resulting vertex to predict the next vertex. Where n is a configurable number > 1.
The larger n is the more parallel a query is but the probability of an erronous prediction increases. Using this strategy a single query is dynamically broken down into multiple smaller queries accross the cluster.
[Path prediction algorithms](https://www.google.co.uk/search?q=path+prediction+algorithm&oq=path+predi&aqs=chrome.3.69i57j0l3.3517j0j1&sourceid=chrome&ie=UTF-8)

Maybe use some kind of marker technique to say that if you start from this vertex i you are guaranteed to get to this vertex j. Possibly precomputed marks? Or continuously computed marks so that when a query is run you're not running the prediction algorithm but using it's results from before. If it's continually re-computed as the graph changes then the "predictions" are guaranteed to be accurate at a given time (or at least until something is removed to cause it to become invalid).
When you hop from i to j then all vertices between are included in the result set.
When those vertices are processed if a query criteria isn't fulfilled then all the sub queries issued prior to the marker that failed the query can be terminated because their results will never be valid. This implies that the vertices from i to j cannot be returned in a result until the previous set of vertices have been verified to be valid for the query. 

This could result in unnecessary computations but significantly reduces the need to communicate a lot....maybe? that may still be affected by vetex placement in the cluster but if |j...i| is big enough the number of network hops required is already reduced anyway because none of the vertices between i and j will perform a network hop...unless the vertices between i and j create a branch which leads to another marker. but perhaps the markers from the prediction algorithm could be created such that none of the vertices between i and j will hit such a branch creating vertex.

With regards to extra computation, if |i...j| is small enough to be performed in micro or milliseconds the extra computation is likely to be cheaper than network hops since the entire operation is local.

### Super Fast Query Prediction

To take the path prediction to the next level. Real time queries are loaded and remain so on the server. As new data is added it is analyzed and marked. This means that when a request is made for the results of a query, the traversal can be initialized on all Nodes at the same time by using the pre-marked vertices as starting points.