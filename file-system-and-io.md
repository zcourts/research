---
layout: page
title: "High throughput file system with guaranteed sequential IO"
description: "Proposes a file system/data structure optimized for sequential file IO"
---
{% include JB/setup %}

# Sequential read and write file system

Read and write access on spindle disks will perform better if the data to be read and written can be done sequentially. The read throughput is far more important for query performance. To address this a novel technique which builds on earlier work (LSM) is proposed.

## Write journal / Write ahead log

A journal is a simple log of all actions to be performed on data. The contents of a journal can be used to recover the entire file system be replaying each action sequentially.
* All write requests are written to the journal.
* All requests are final, once written it can be read but not edited

## Sequentially consistent commit file

As a graph evolves (more vertices or edges added) the structure can become suboptimal for IO throughput as the disk head is having to do more repositioning to access the next vertex in a traversal.
A graph database has the advantage of knowing exactly what data it will access next. Taking advantage of this fact can improve the read throughput by reducing the number of repositioning the disk head has to do.

* Every vertex knows it's edges and hence its adjacent vertices.
* All properties of a vertex can be stored next to each other. Properties here means all a vertex's data attributes and all the edge information (and their data attributes) associated with the vertex.
* After a vertex's properties are written, the next vertex and it's properties are written in the same way, where the next vertex is one of the adjacent vertices.
* Determining which vertex is written next can be determined by whether the file system is optimized for depth or breadth first traversal. This is also a micro-optimization since the very act of placing one of the next vertices after the current one already minimizes how much the disk head has to seek. For a vertex with a small number of adjcent vertices or a large number of small vertices the  movement of the disk head is likely small enough to be negligable.

# Online file compaction

To avoid locking immutability is used where reasonable to do so. This means that the entire filesystem is largely write only. A side effect of this is that the commit file does not remain sequentially consistent as data can only be appended. In order to remain consistently sequential, some sort of re-ordering must be done. To achieve this, the slinky compaction mechanism is proposed.

## Slinky Compaction for append only file systems

Taking ideas from Haskell and Cassandra. Using an append only data structure requires compaction in order to clean up deleted or out of date versions.

Instead of doing a background clean up task which can hog resources. Use two files one is the current file being appended to and the second is the previously written to file. Data from the old file pours over from the old file to the new one while it also accepts new data. The fact that old and new data is interleaved doesn't matter because the file index is also written with this slinky like format. Once old data pours over completely into the new one, the old file is removed and the new one continues to be used until it is determined that the process should start again. This reduces the overhead associated with compactions. I've done the experiment with files up to 150GB and recorded a large improvement. Details and exact numbers will be published when I get the time to write everything up in Jan/Feb 2014. (TODO: Write up a page with the results and prepare a paper for publishing)

# Generational data indexing

The journal and slinky mechanism introduces 3 potential locations for data to be available from. In order to avoid random disk seeks and data searches over potentially several gigabytes or terabytes of data, the file system uses a vertex index, where, given any vertex ID, the index can give the exact byte offset at which the vertex's data begines and in the correct file.

## Garbage collection style indexing

Trishul M. Chilimbi and James R. Larus (Using Generational Garbage Collection To Implement  Cache-Conscious Data Placement) explored how a generational garbage collector can be used to re-organize data structures in object oriented languages, such that objects with a high temporal affinity are placed next to each other to increate the likely hood of those objects being placed in the same cache block.

While their goals are somewhat different a similar technique can be used for disk based file systems.
There are three primary files involved in the file system and at any point the system must be able to specifically identify which file and which byte offset a vertex's data starts at.

Classify each file as a generation such that eden or first generation is the journal, tenured or second generation is old commit file to be compacted and perm or third generation is the new commit file being written to.

When an operation is performed that modifies data e.g. add, remove, "update", vertex or edge, this is written to the journal. 

A record is then placed in the index acknowledging the existence of the data, if something was added, if it was removed the record is removed from the index.

### Add vertex or edge

When a vertex, edge or an attribute of either is added, the operation is written to the journal. After it is written to the journal the index is updated with the byte offset. The data remains in this generation until sweep operation is performed.


### Edit vertex or edge
Edit's are strictly speaking not supported as a user operation. Any action akin to an edit actually creates a new version of the old data. No in place edit is exposed to the user.

## Remove vertex or edge

main point is write to journal then gc phase copy to commit log after commit log update index, after index points to new location log can optionally be truncated.
point is that index isn't update until after data exists in the next generation.

then like GC 2nd gen is copied to 3rd gen but again index isn't updated until after data is commited to 3rd gen


during slinky compaction deleted data is not copied from the 2nd to the 3rd gen hence resulting in compaction

# Data format specification
The byte structure of the data is needed to ensure consistency across implementations.

## File segmentation

The amount of data in a single file can grow to the point where seeking becomes a bottle neck. To avoid this, all files (persistent index and 1st to 3rd gen data files) are segmented when the data reaches a given size, m. What this means for the in memory data structures is that they need to be segment aware. Segments are simply named incrementally. 

To avoid approaching or hitting the OS's file system limits the segmentation (e.g. 31998 sub-directory limit in ext3, 16GB max file size with 1KB blocks) is taken further.

## Index format

