# Blockchain Sharded Storage: Integrating Shamir Secret Sharing for Web2 Costs and Web3 Security

## Abstract

CPU scaling for blockchain is solved. However, storage scaling is still a problem. This document describes a sharded storage solution for blockchain to store really big amounts of data (beyond petabytes) with Web2 cost and Web3 security. The solution is based on [Shamir's Secret Sharing](https://en.wikipedia.org/wiki/Shamir%27s_Secret_Sharing) and [Fast Fourier Transform](https://zcash.github.io/halo2/background/polynomials.html#fast-fourier-transform-fft). If we have N numbers, we can represent it as a polynomial of degree N-1. We can evaluate this polynomial at M points and get M values. Then we can restore the polynomial from any N values. In the note, we will show how to use this approach to build horizontal scalable fault-tolerant storage.

## Introduction

### Background

### Problem Statement

One of the commonly used existing solutions is replication of data. It stores each data chunk should at multiple nodes. Nodes produce zero-knowledge proofs of data availability. When the number of nodes storing the chunks is low, the network distributes the chunks to other nodes.

Let's discuss some of the disadvantages of this approach making it more expensive than Web2 storage.

1. Replication of data. If we want to build a 50% fault-tolerant network with 128 bits of security, we need to replicate data 128 times. It means that the network should store and transfer 128 times more data than the original data size.

2. Zero-knowledge proofs of data availability. The data replicas contain the same information. However, we need to implement a unique representation for each replica. Otherwise, multiple nodes can collude and store only one replica. Replica-to-replica transformation should be a complex problem to prevent collusion and force each node to store its replica. It means that the zero-knowledge proof of data availability becomes a complex problem.

3. Data distribution. The nodes go online and offline. If a malicious actor controls a significant part of the network, they can try to collect all data replicas for one file one by one, which will lead to data loss. The sound way to prevent it is random redistribution of data replicas when some of the nodes go offline.

Below we propose a solution using 35 times less storage space for the same security level and with simple space-time proofs of data availability instead of replica proofs.

## Theoretical Framework

### Shamir's Secret Sharing

[Shamir's Secret Sharing](https://en.wikipedia.org/wiki/Shamir%27s_Secret_Sharing) is a method for distributing a secret among a group of participants, each of which is allocated a share of the secret. The secret can be reconstructed only when a sufficient number of shares are combined. The sufficient number is called the threshold. The threshold can be any number between 1 and the total number of shares. The secret cannot be reconstructed from any number of shares less than the threshold.

One of the simplest ways to implement Shamir's Secret Sharing is to use a polynomial of degree N-1. We can represent the N-sized secret as a polynomial of degree N-1. We can evaluate this polynomial at M points and get M values. Then we distribute these values among M participants. The secret can be restored from any N values.


> [!TIP]
> The way we use Shamir's Secret Sharing here can be alternatively characterized as encoding the data with [Reed–Solomon Error Correcting Code](https://en.wikipedia.org/wiki/Reed%E2%80%93Solomon_error_correction) and decoding with erasures (not errors). Especially since the message we encode is not secret. In the following, we keep calling it Secret Sharing because more readers may be familiar with this term.

For well-selected $N$ and $M$, we can restore the secret if most of the participants will go offline. We will use this property to build a fault-tolerant storage of publicly available data.

### Polynomial Computation for Data Recovery

Let's consider $p(x)$ is a polynomial of degree $N-1$ and the secret is the evaluation representation of this polynomial over evaluation domain $\mathbf{D}=\{0,\ 1,\ 2,\ ...,\ N-1\}$:

$\mathbf{S} = \{p(0),\ p(1),\ p(2),\ ...,\ p(N-1)\}$

We will compute the polynomial over the extended evaluation domain $0,\ 1,\ 2,\ ...,\ M-1$ and distribute the values to M participants.

Let's represent the case when all participants excluding N are going offline. So, we get the following values:

$\mathbf{V} = \{p(k_0),\ p(k_1),\ p(k_2),\ ...,\ p(k_{N-1})\}$
over evaluation domain
$\mathbf{K} = \{k_0,\ k_1,\ k_2,\ ...,\ k_{N-1}\}$.

Let's define Lagrange polynomials over evaluation domain $\mathbf{K}$:

$$\mathbf{L}_i(x) = c_i \prod_{j \neq i} x - k_j,$$

where $c_i$ is a constant coefficient, so that $\mathbf{L}_i(k_i) = 1$.

Let's define matrix $\mathbf{L}_{ij}=\mathbf{L}_i(j)$.

Then the secret can be restored as follows:

$$\mathbf{S}_j = \sum_{i} \mathbf{V}_i \cdot L_{ij}$$

> [!NOTE]
> What happens, if some of the participants are malicious and send incorrect values? To prevent this problem, there are a lot of ways. For our partial case, we will merkelize all values and distribute them to all participants with Merkle proofs. Then we can check the correctness of each value, checking the root of the Merkle proof. If the root is incorrect, we can ignore the value.


### Soundness  Analysis

Let's consider $p$ as part of honest nodes in the network, So, if a total number of nodes is $N$, $pN$ are honest, and $(1-p)N$ of them are malicious. If shards are distributed by nodes by random, $p$ also is the probability, that the node will be honest. Then if we have $n$ shards with threshold $k$, the probability that the secret cannot be restored means that only strictly less than $k$ shards are stored by honest nodes. The probability is defined by the following binomial distribution:

$$\mathbf{P}(p,n,k) = \sum_{i=0}^{k-1} \binom{n}{i} p^i (1-p)^{n-i},$$

where 

$$\binom{n}{i} = \frac{n!}{i!(n-i)!}$$

is a binomial coefficient.

For $0.05 < p < 0.95$, $n>30$, $np>5$, $n(1-p)>5$, we can use the normal approximation of the binomial distribution ([source](https://online.stat.psu.edu/stat414/lesson/28/28.1)).

$$\mathbf{P}(p,n,k) \approx \frac{1}{2} \left[1 + \mathrm{erf}\left(\frac{k-1/2-np}{\sqrt{2np(1-p)}}\right)\right].$$

The soundness of could be defined as follows:

$$\mathbf{S}(p,n,k) = -\log_2 \mathbf{P}(p,n,k).$$

Then we can calculate the soundness for different values of $p$, $n$, and $k$. For example, if $p=1/2$, $n=1024$, $k=256$,

then $\mathbf{S}(1/2,1024,256) = 190$ bits of security.

### Comparison with Replication

For replication, the probability of data loss could be computed with the following formula:

$$\mathbf{P}(p,n) = (1-p)^n,$$

where $p$ is the probability that a node is honest, otherwise it is malicious, and $n$ is the number of replicas.

The soundness of replication could be defined as follows:

$$\mathbf{S}(p,n) = -\log_2 \mathbf{P}(p,n).$$

To compare sharding using Shamir's Secret Sharing and replication, we will compare the blowup factor for 64 and 128 bits of security in case the 1/4, 1/2, and 3/4 nodes of the network are honest. 

The comparison is shown in the table in Appendix A. Looking at this data, we can observe:

1. The blowup factor for replication is much higher than for sharding
2. The blowup factor for sharding is growing slower than for replication when security is growing
3. The blowup factor depends on the sharding threshold $k$, the higher the threshold, the lower the blowup factor


### Dynamic Nodes Mixing against Malicious Actors

If sharding is static, we need just initially select the nodes for each pool. However the uptime of the nodes is not infinite, and if only malicious nodes are left in the pool, the data will be lost. To prevent this problem, we need to mix the nodes in the pools periodically. The mixing should be done in a way, that the malicious nodes cannot predict the new shard for the data.


Let's consider $n$ as the number of nodes in a pool.

For the best strategy for the malicious actor: keep the malicious nodes in the pool and wait when the honest node to go offline, we can describe the evolution of the pool as a Markov process. We can find the equilibrium distribution for this process and find the probability that less than $k$ nodes in the pool are honest.

For example, if $p=1/2$, $k=64$, $n=512$, $m=4$, then soundness is $101$ bits of security.

## Brief protocol description



## Economic Incentives and Protocol Design

### Incentive Structures

### Protocol Design Challenges

## Security Considerations

### Handling Malicious Actors

## Proof of Spacetime Mining Mechanisms

To prevent spam from malicious nodes with not enough space, we should implement an efficient mechanism, allowing for nodes to prove, that they have enough space to store the data.

### Plotting

### Proof of spacetime

When the node receives the data to store, it can remove the ending part of the plot because then it is not needed for the proof. The node selects $n$ random elements of the remaining plot and sends Merkle proof of these elements to the network.

Another approach is used to make proof, that files are stored at the node. The node picks a random file, represents it as a polynomial, and shows the opening for the commitment of this polynomial to the network. With high probability, if the node can provide this opening, the node stores the file.




## Rollup and Sequencer

### Data Management

### Economic Model

## Mathematical Methods for Rapid Data Recovery

## Conclusion

### Summary of Findings

### Future Research Directions

## Appendices





