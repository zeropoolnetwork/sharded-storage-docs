# Efficient Data Distribution with Reed-Solomon Codes for Blockchain Storage

## Introduction

This writeup presents an efficient method for distributing N data elements across n nodes using Reed-Solomon (RS) encoding, specifically designed for blockchain storage solutions. We address the challenge of scaling blockchain storage by introducing techniques that achieve O(N log n) decoding complexity, where N is the total amount of data and n is the number of nodes.

A naive approach would be to simply blow up the data from N to bN, where b is the blowup factor. However, this would result in O(N log N) decoding complexity. Our method, by representing data as a table and creating data shards, achieves O(N log n) decoding complexity, which is significantly faster.

It's crucial to note that we don't need to apply RS codes to all data together. This is because a node can only go offline as a whole - there can't be a situation where two nodes lose half of their data each, requiring RS codes to recover the data. A node either loses all its data or provides it entirely.

While our method doesn't significantly improve the speed of calculating polynomial commitments (which remains O(N log N) for FRI), it greatly optimizes the data encoding-decoding procedure.

## Notation and Definitions

Before proceeding with the detailed description of our method, let's define the key terms and symbols used throughout this writeup:

- N: Total amount of data elements
- n: Number of nodes in the network
- k: Minimum number of nodes required to recover the original data
- b: Blowup factor, defined as b = n/k
- m: Number of rows in the data table representation

## 2-Adicity Fields Case

We consider a 2-adic prime field, specifically the BabyBear field with prime p = 15 * 2^27 + 1.

Let's consider we have a vector ${a_i}$ of N elements of field $F_p$. We want to distribute this vector among n servers, such that any k servers can recover the original vector. We use Reed-Solomon codes to achieve this.

We represent the vector ${a_i}$ as a table ${a_{ij}}$ of size $m \times k$ with $m$ rows and $k$ columns.

We define a bivariate polynomial $f(x,y)$ to represent our data:

$$f(x,y) = \sum\limits_{ij} a_{ij} L_i(x) \lambda_j(y)$$

where $L_i(x)$ is a Lagrange polynomial of degree $m-1$ and $\lambda_j(y)$ is a Lagrange polynomial of degree $k-1$.


After performing FFT over each row of the table, $f(x,y)$ takes the following form:

$$f(x,y) = \sum\limits_{ij} b_{ij} L_i(x) y^j = \sum\limits_{j} f_j(x) y^j$$

where $f_j(x)=\sum\limits_{i} b_{ij} L_i(x)$ is a polynomial of degree $m-1$.


Each node should receive a unique linear combination of the columns of the table. Then we can recover the original vector by solving a system of linear equations. Let's represent the data shard as $f(x,y_0)$, where $y_0$ is a fixed value for each shard.

$$f(x,y) - f(x,y_0) = \sum\limits_{j} (y^j - y_0^j) f_j(x) = (y-y_0) q(x,y)$$

where $q(x,y)$ is a quotient polynomial.


We make the substitution $y=x^m$ without loss of any inner polynomial structure. This substitution effectively concatenates all columns of the table, one after another, which is convenient for creating a polynomial commitment.

After the substitution, we get the following polynomial equation to check that the shard is a valid part of the original data:

$$ f(x,x^m) - f(x, y_0) = (x^m - y_0) q(x,x^m) $$

## Circle Fields Case

We now consider the M31 field with p = 2^32 - 1. [HLP24] proposed a method called CFFT (Circular Fast Fourier Transform), which is analogous to FFT but works with polynomials defined on a complex circle.

In the circle representation, the polynomial takes the form $f(x,y)=\Re(f(z))$, where $|z|=1$.

Due to the circle constraint $|z|^2 = x^2 + y^2 = 1$, the polynomial can be represented as:

$$f(x,y) = f_0(x) + y f_1(x)$$

where $f_0(x)$ and $f_1(x)$ are polynomials of degree $N/2-1$. Note that we have two polynomials of this degree, providing sufficient degrees of freedom.

Let's represent the data vector ${a_i}$ as a table ${a_{ij}}$ of size $m \times k$ with $m$ rows and $k$ columns. We perform circle FFT (CFFT) on each row of the table, resulting in $m$ vectors of size $n$.

$$f(x,y,u,v) = \sum\limits_{ij} a_{ij} L_i(x,y) \lambda_j(u,v)$$

It's important to note that the function $f(x,y,u,v)$ is defined on a torus: $x^2+y^2=1$, $u^2+v^2=1$.

Let's consider $f(x,y,u,v)$ as $v$-even function. This approach is not useful directly for SNARKs, because then we have even constraint on function values and next row could be dependent on the previous one. However, it's useful for data distribution.

Then 

$$f(x,y,u,v) = f(x,y,u) = \sum\limits_{ij} a_{ij} L_i(x,y) \Lambda_j(u) $$,
where $\Lambda_j(u)$ is even Lagrange basis on the circle.



After applying CFFT over each row, we get:

$$f(x,y,u) = \sum\limits_{ij} b_{ij} L_i(x,y) u^j = \sum\limits_{j} f_j(x,y) u^j$$

where $f_j(x,y)=\sum\limits_{i} b_{i} L_i(x,y)=f_{j,0}(x) + y f_{j,1}(x)$ and each polynomial is $(m/2-1)$-ordered.

Let's consider $f(x,y,u_0)$ as a data shard, where $u_0$ is a fixed value for each shard.

$$f(x,y,u) - f(x,y,u_0) = \sum\limits_{j} (u^j - u_0^j) f_j(x,y) = (u-u_0) q(x,y,u)$$

where $q(x,y,u)$ is a quotient polynomial.

We make the substitution $u=x^{m/2}$ in $f(x,y,u)$. This substitution does not result in information loss because $f_j(x,y)=f_{j,0}(x) + y f_{j,1}(x)$, where the degrees of $f_{j,0}(x)$ and $f_{j,1}(x)$ are $m/2-1$. The resulting polynomial $f(x,y,x^{m/2})$ maintains the structure $f_0(x) + y f_1(x)$ and remains defined on a circle, albeit with each one-dimensional component now of degree $N/2-1$. This substitution effectively concatenates all columns of the table, similar to the 2-adicity case.


After the substitution, we get the following polynomial equation to check that the shard is a valid part of the original data:

$$f(x,y,x^{m/2}) - r(x,y) = (x^{m/2}-u_0)q(x,y,x^{m/2})$$

## Conclusion

We have extended our method of data representation to the M31 field, providing a robust framework for efficient data distribution in blockchain storage. By representing data as a table and using FFT/CFFT techniques, we achieve O(N log n) decoding complexity, significantly optimizing the data encoding-decoding procedure. This approach is particularly valuable in blockchain systems where nodes can only fail as a whole, and efficient data recovery is crucial.

While the complexity of polynomial commitment calculations remains O(N log N) for FRI, our method provides substantial benefits in the overall data handling process, making it a promising solution for scalable blockchain storage.

## References

[HLP24] [Add full reference for the CFFT method in M31 field]

[Add other relevant references]