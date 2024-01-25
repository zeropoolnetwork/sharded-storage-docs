from soundness import dynamic_p
from mpmath import mp, mpf, binomial, power, fabs, log
import matplotlib.pyplot as plt


def bdist(n, k, p):
    return binomial(n, k) * power(p, k) * power(1-p, n-k)

mp.dps = 100

eps = mpf(1e-6)


def zerostate(n):
    return [mpf(0)]*(n+1)

def dyn_bdist(p, n, m):
    p1 = dynamic_p(p, n, m)
    return [bdist(n, i, p1) for i in range(n+1)]


def vlog(x):
    return [log(i) for i in x]


def markov1(p, n, m):
    state = zerostate(n)
    # initial state
    state[0] = mpf(1)
    state1 = zerostate(n)

    while True:
        instate = state.copy()

        # if all elements are '0', substract '0'
        state1[0] = state[0]

        # otherwise substract '1'
        for i in range(1, n+1):
            state1[i-1] += state[i]
        
        assert fabs(1-sum(state1))< eps, "sum(state) != 1"
        assert state1[n] == mpf(0), "state[n] != 0"

        state, state1 = state1, zerostate(n)

        # substract m times random element

        for i in range(m):
            for j in range(n-i):
                # probability to substract 1
                ps1 = mpf(j) / (n-i-1)

                # substract 1
                if j > 0:
                    state1[j-1] += state[j] * ps1
                
                # substract 0
                state1[j] += state[j] * (1-ps1)
            
            assert fabs(1-sum(state1))< eps, "sum(state) != 1"
            assert state1[n-i-1] == mpf(0), "state[n-i] != 0"
            state, state1 = state1, zerostate(n)

        # add m+1 times random element outside
        
        for i in range(m+1):
            # add 1
            for j in range(n):
                state1[j+1] += state[j] * p
            
            # add 0
            for j in range(n+1):
                state1[j] += state[j] * (1-p)
            

            assert fabs(1-sum(state1))< eps, "sum(state) != 1"
            assert i==m or state[n-m+i+1] == mpf(0), "state[n-m+i+1] != 0"
            state, state1 = state1, zerostate(n)

        
        err = mpf(0)
        for i in range(n+1):
            t=state[i] + instate[i]
            if t != mpf(0):
                err += fabs(state[i] - instate[i])/(state[i] + instate[i])
        
        if err < eps:
            break

    for i in range(n+1):
        state[i] = float(state[i])
    return state



def markov2():
    state = zerostate(n)
    # initial state
    state[0] = mpf(1)
    state1 = zerostate(n)

    while True:
        instate = state.copy()

        # substract m times random element

        for i in range(m):
            for j in range(n+1-i):
                # probability to substract 1
                ps1 = mpf(j) / (n-i)

                # substract 1
                if j > 0:
                    state1[j-1] += state[j] * ps1
                
                # substract 0
                state1[j] += state[j] * (1-ps1)
            
            assert fabs(1-sum(state1))< eps, "sum(state) != 1"
            assert state1[n-i] == mpf(0), "state[n-i] != 0"
            state, state1 = state1, zerostate(n)

        # add m+1 times random element outside
        
        for i in range(m):
            # add 1
            for j in range(n):
                state1[j+1] += state[j] * p1
            
            # add 0
            for j in range(n+1):
                state1[j] += state[j] * (1-p1)
            

            assert fabs(1-sum(state1))< eps, "sum(state) != 1"
            assert i==m-1 or state[n-m+i+1] == mpf(0), "state[n-m+i+1] != 0"
            state, state1 = state1, zerostate(n)

        
        err = mpf(0)
        for i in range(n+1):
            err += fabs(state[i] - instate[i])
        
        if err < eps:
            break

    for i in range(n+1):
        state[i] = float(state[i])
    return state


p=mpf(0.5)
n=512
m=5



plt.xlabel('i')
plt.ylabel('p')
plt.title('Markov equilibrium distribution')

plt.plot(range(n+1), vlog(markov1(p,n,m)), marker='o', linestyle='-', color='b')
plt.plot(range(n+1), vlog(dyn_bdist(p,n,m)), marker='o', linestyle='-', color='r')



plt.grid()
plt.show()
            

