from mpmath import mp, log, mpf, erf, sqrt, floor, power
from markov import markov

def fault_probability(p,n,k):
    return 0.5*(1+erf((k-0.5-n*p)/sqrt(2*n*p*(1-p))))

def dyn_soundness(p,n,k,m):
    equi_state = markov(p, n, m)
    return -log(sum(equi_state[:k]),2)


def soundness(p,xt,k):
    return -log( fault_probability(p,xt*k,k),2)

def soundness2(p,xt):
    return -log(1-p, 2)*xt



def n_by_soundness(p,k,s):
    n=2*k
    while soundness(p,n,k)<s:
        n+=k

    lower=n-k
    upper=n
    while lower<upper:
        mid=(lower+upper)//2
        if soundness(p,mid,k)<s:
            lower=mid+1
        else:
            upper=mid
    return lower

def xt_by_soundness(p,k,s):
    return n_by_soundness(p,k,s)/k

def xt_by_soundness2(p,s):
    return -s/log(1-p,2)

# p_1 = 1-\frac{(m+1)(n-1)(1-p)}{n m}
def dynamic_p(p, n, m):
    return 1-(m+1)*(n-1)*(1-p)/(n*m)


if __name__ == "__main__":
    # Set the precision
    mp.dps = 1024

    p=0.5
    k=64
    xt=8
    m=4
    print(f"Soundness for sharding p={p}, k={k}, xt={xt}: {int(soundness(p,xt,k))}")
    print(f"Dynamic soundness for sharding for p={p}, k={k}, xt={xt}, m={m}: {int(dyn_soundness(p, xt*k, k, m))}")

    xt = 8
    print(f"Soundness for replica p={p}, xt={xt}: {int(soundness2(p,xt))}")
    print(f"Dynamic soundness for replica for p={p}, xt={xt}, m={m}: {int(dyn_soundness(p, xt, 1, m))}")
    



    # s = [64, 96, 128]
    # k = [64, 128, 256, 512]
    # p = [1/4, 1/2, 3/4]

    # print("""
    # | Security | $p$ | Sharding $k$ | Sharding $n$ | Sharding blowup | Replication blowup | Advantage of sharding |
    # | --- | --- | --- | --- | --- | --- | --- |""")

    # for _s in s:
    #     for _p in p:
    #         for _k in k:
    #             xt1 = xt_by_soundness(_p, _k, _s)
    #             n = int(xt1*_k)
    #             xt2 = xt_by_soundness2(_p, _s)
    #             print(f"| {_s} | {_p} | {_k} | {n} | {float(xt1):.1f} | {float(xt2):.1f} | {float(xt2/xt1):.1f} |")

