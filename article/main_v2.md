# Blockchain Sharded Storage: Web2 Costs and Web3 Security with Shamir Secret Sharing

## Abstract

CPU scaling for blockchain is solved. However, storage scaling is still a problem. This document describes a sharded storage solution for blockchain to store really big amounts of data (beyond petabytes) with Web2 cost and Web3 security. With this solution, rollups no longer need to store their blocks on-chain. In other words, we can upgrade validiums to rollups. The solution is based on [Shamir's Secret Sharing](https://en.wikipedia.org/wiki/Shamir%27s_Secret_Sharing) and [Fast Fourier Transform](https://zcash.github.io/halo2/background/polynomials.html#fast-fourier-transform-fft). If we have N numbers, we can represent it as a polynomial of degree N-1. We can evaluate this polynomial at M points and get M values. Then we can restore the polynomial from any N values. In the note, we will show how to use this approach to build horizontal scalable fault-tolerant storage.

## Introduction

### Problem Statement

One of the commonly used existing solutions is replication of data. It stores each data chunk should at multiple nodes. Nodes produce zero-knowledge proofs of data availability. When the number of nodes storing the chunks is low, the network distributes the chunks to other nodes.

Let's discuss some of the disadvantages of this approach making it more expensive than Web2 storage.

1. Replication of data. If we want to build a 50% fault-tolerant network with 128 bits of security, we need to replicate data 128 times. It means that the network should store and transfer 128 times more data than the original data size.

2. Zero-knowledge proofs of data availability. The data replicas contain the same information. However, we need to implement a unique representation for each replica. Otherwise, multiple nodes can collude and store only one replica. Replica-to-replica transformation should be a complex problem to prevent collusion and force each node to store its replica. It means that the zero-knowledge proof of data availability becomes a complex problem.

3. Data distribution. The nodes go online and offline. If a malicious actor controls a significant part of the network, they can try to collect all data replicas for one file one by one, which will lead to data loss. The sound way to prevent it is random redistribution of data replicas when some of the nodes go offline.

Below we propose our solution to solve these problems.

Also, our solution is native zkSNARK-friendly. That means that we can include proofs of data availability in proofs of rollup state transitions. It will allow us 


### Comparison with existing solutions

    TODO: write a table with a comparison of sharding and replication


## Architecture

![Architecture](../assets/architecture.svg)

Let's consider a 4-level model of the sharded storage network:

At the first level, we have the L1 blockchain. The L2 rollup publishes state-to-state transition proofs and the root hash of the state.

    [!TIP] We do not need to publish the data of blocks. We are describing sharded storage, so, all data will be safely stored at the nodes and the zk proof contains the proof of data availability.

At the second level, we have the L2 rollup. It checks proofs of space-time for new nodes, adds it to the list of active nodes, removes inactive nodes, and performs mixing of nodes between pools to prevent potential attacks. Also, state-to-state transition proofs for L3 rollups are published here.


At the third level, we have the L3 rollup. The sharding means that we need to convert the data into $n$ shards when $k\leq n$ shards are enough to restore the data. The L3 rollup is responsible for consistency between all nodes. Also, users rent space at the L3 rollup using their payment channels. L3 rollup aggregates proof of the data availability using function interpolation at random points for data blocks.

At the third level, we have storage nodes. The nodes are part of the consensus for the corresponding pool. Also, the nodes store the data and provide proof of data availability. All empty space of the nodes should be filled with the special plots, like in Chia Network, but with some differences, making it more suitable for our case and ZK friendly.


## Economic Model


## Theoretical framework


## Appendices

