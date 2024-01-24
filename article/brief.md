# Brief description of sharded storage

## Overview

We are seeing a definite demand for such tools, as rollups have scaled up CPUs, but effective tools for scaling data are not yet available. EthStorage has made the most progress, but they charge 4.5 ETH for 1GB and use replication instead of sharding.

Our idea is data sharding. We represent the data as values of a polynomial of degree k-1 at k points and then interpolate the polynomial values at n points. Then, any k out of n values are sufficient to recover the data.

## Soundness 

We have solved the reliability problem when scaling: even if someone controls 50% of the network and uses various strategies to gain control over the data, they will only gain control over at least one file with a probability of 2^-80 (80 bits of security). This is with a blowup factor of 8 (64 to 512).

This is an asymptotic estimate in the case of an infinitely large number of nodes in the network; if there are fewer nodes, the reliability against a 51% attack is higher.

If the attacker has significant power in absolute terms but less than 50%, they cannot concentrate it on one file to make the network forget it.

If the attacker has more than 50% of the power, the bits of security will be less than 80, but this does not mean that the attacker will immediately break everything, because each attempt involves transmitting tens of terabytes of data over the network.

Replication with a blowup factor of 8, for comparison, only offers 8 bits of security if the attacker does not use strategies to gain control over the data. And if they do, even less.

A separate problem with replication is forcing all nodes to store unique representations of replicas. If this is not done, replication nodes will have an economic incentive to simply be frontends to a single physical storage. For sharding, where all data is unique, this problem does not exist.


## Network

The network consists of pools of 512 nodes. Files are split into words of 64 numbers, and these sequences of 64 numbers are encoded as one word for each node. There can be many pools. When a node goes offline, it is replaced by a free node with a random shuffling of a small number of nodes between pools (up to 2 swaps, but can be less) to prevent an attacker from concentrating malicious nodes in one pool.

Free nodes queue for files and mine on plots, like in Chia, thus proving they have disk space. Non-free nodes occasionally perform a random data access proof, which proves that the node stores a specific file in its entirety. Such proofs can be made frequently and aggregated.

Node management is done through a smart contract.

All proofs and the smart contract can be represented as a recursive SNARK on Plonky3 or its elements, such as polynomial commitments.

In its basic implementation, it is similar to a low-level web3 RAID disk of several petabytes in size, with no upper limit, because all nodes only participate in a smart contract that mixes them in pools, and this is a relatively rare event. The size of the nodes (tens of terabytes) is orders of magnitude larger than the information needed to manage their mixing in pools.

## Economics

All nodes are economically incentivized to store data because they receive rewards for proof of data availability or proof of storage mining (like in Chia). 

Also, nodes could be motivated to transfer the data in case of large data amounts (tens of terabytes) with async payment channels, working parallel with data transfer. This solution prevents nodes from spamming.


## Applications

The main use case of such a network is rollups can store their blocks in it. Moreover, in such a case, a rollup can on-chain publish a proof, which already contains proof that the data of the block is reliably available off-chain.

Even on rollups, various fast file storage and CRUD databases are possible. In fact, they work incrementally, storing the blocks of the rollup, which contain transactions, but it's always possible to publish a snapshot and forget the history before it.

