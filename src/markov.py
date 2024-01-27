from mpmath import mp, mpf, binomial, power, fabs, log

def zerostate(n):
    return [mpf(0)]*(n+1)


def markov(p, n, m):
    eps = mpf(1e-6)
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

    return state

