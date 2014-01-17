---
layout: page
title: "Terminology"
description: "Summary of terminology used in all publications"
---
{% include JB/setup %}

# Introduction

There are cases where terms overlap in definition, where context changes everything. I'll do my best to be consistent and follow the terms I set on this page, if in doubt a term is used with the intended definition being what it is on this page.

## Graph terms 

1. Vertex - A vertex is effectively a unit within a graph.
2. Edge - An edge connects to verticies and can be defined as e = (A1,B1)
3. A graph G is made up of a set of verticies and edges, G = (V,E)
4. An undirected graph is one where no distinction is made between an edge's two verticies.
5. A directed graph is one where each edge determines it's direction, i.e. e= (A1,B1) is interpretted as A1 points to B1.
6. A mixed graph is on which contains both directed and undirected edges.
7. The order of a graph is the number of verticies |V|
8. The size of a graph is the number of edges |E|
9. The degree of a vertex is the number of edges that connect to it
10. A loop is an edge whose two vertices are the same i.e. loop  e = (A1,A1), a loop is counted twice when determining a vertex's degree.
11. In-degree of a vertex is the number of edges connecting to it in a directed graph
12. Out-degree of a vertex is the number of edges leaving a vertex in a directed graph.
13. Two edges are said to be adjacent if they share a common vertex
14. Two vertices are said to be adjacent if they are connected by an edge, i.e. the edge e = (a,b) makes the vertices a and b adjacent.

## Other terms

1. Node - A node is an instance of an application running on a server.
2. Server - A server is an environment capable of executing an instance of an application (i.e. both virtualized and dedicated environments are considered to be servers).
3. _Concurrency_ the ability of one or more tasks to be scheduled such that each task appears to progress at an almost equal pace as other tasks.

4. _Parallelism_ is the ability of a system to take a number of tasks and execute them all at the same time so that progress is not just apparent but actually occurs.
