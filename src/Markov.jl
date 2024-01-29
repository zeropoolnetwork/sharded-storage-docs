using Combinatorics



module Markov

    DEBUG=1

    macro debug_assert(ex, msgs...)
        msg = isempty(msgs) ? ex : msgs[1]
        if !isdefined(Markov, :DEBUG) 
            return :(nothing)
        elseif isa(msg, AbstractString)
            msg = msg # pass-through
        elseif !isempty(msgs) && (isa(msg, Expr) || isa(msg, Symbol))
            # message is an expression needing evaluating
            msg = :(Main.Base.string($(esc(msg))))
        elseif isdefined(Main, :Base) && isdefined(Main.Base, :string) && applicable(Main.Base.string, msg)
            msg = Main.Base.string(msg)
        else
            # string() might not be defined during bootstrap
            msg = quote
                msg = $(Expr(:quote,msg))
                isdefined(Main, :Base) ? Main.Base.string(msg) :
                    (Core.println(msg); "Error during bootstrap. See stdout.")
            end
        end
        return :($(esc(ex)) ? $(nothing) : throw(AssertionError($msg)))
    end

    export markov

    
    function fix_zero(x)
        return x == 0 ? 1 : 0
    end

    # process with 1 honest node disconnect, 1 replacement and m mixings
    function markov1(p::BigFloat, n::Int, m::Int)
        eps = BigFloat("1e-6")
        # initial state


        state = zeros(BigFloat, n+1)
        state[1] = BigFloat(1)
        state1 = zeros(BigFloat, n+1)

        instate = zeros(BigFloat, n+1)

        while true
            instate[:] = state

            # if all elements are '0', subtract '0'
            state1[1] += state[1]

            # otherwise subtract '1'
            state1[1:n] += state[2:n+1]

            @debug_assert abs(1-sum(state1)) < eps "sum(state) != 1"
            @debug_assert state1[n+1] == BigFloat(0) "state[n] != 0"

            state, state1 = state1, state
            fill!(state1, BigFloat(0))

            # subtract m times random element
            for i in 1:m

                # probability to subtract 1
                ps1 = BigFloat.(0:n-i) / (n-i)

                # subtract 1
                state1[1:n-i] += state[2:n-i+1] .* ps1[2:n-i+1]
                # subtract 0
                state1[1:n-i+1] += state[1:n-i+1] .* (1 .- ps1)


                @debug_assert abs(1-sum(state1)) < eps "sum(state) != 1"
                @debug_assert state1[n+1-i] == BigFloat(0) "state[n+1-i] != 0"

                state, state1 = state1, state
                fill!(state1, BigFloat(0))
            end

            # add m+1 times random element outside
            for i in 1:(m+1)
                
                # add 1
                state1[2:n+1] += state[1:n] * p
                
                # add 0
                state1[1:n+1] += state[1:n+1] * (1 - p)
                
 

                @debug_assert abs(1-sum(state1)) < eps "sum(state) != 1"
                @debug_assert i==m+1 || state1[n-m+i+1] == BigFloat(0) "state[n-m+i+1] != 0"

                state, state1 = state1, state
                fill!(state1, BigFloat(0))
            end

            t = state + instate
            t += fix_zero.(t)
            err = sum(abs.(state - instate) ./ t)
            
            if err < eps
                break
            end
        end

        return state
    end




    function subs_honest(state)
        t=state[1]
        state[1:end-1] = state[2:end]
        state[end] = 0
        state[1]+=t
    end

    function subs_random(state, buf, probs)
        buf[:] = state .* (1 .- probs)
        buf[1:end-1] += state[2:end] .* probs[2:end]
        state[:] = buf
    end

    function add_random(state, buf, p)
        buf[:] = state * (1 - p)
        buf[2:end] += state[1:end-1] * p
        state[:] = buf
    end
    
    function mix(state, buf, probs, p, m)
        for _ in 1:m
            subs_random(state, buf, probs)
            add_random(state, buf, p)
        end
    end





    # 1/(m+1) probability of honest node disconnect, replacement and m-1 mixings
    # m/(m+1) probability of random mixing
    
    function markov2(p::BigFloat, n::Int, m::Int)
        eps = BigFloat("1e-6")
        # initial state

        


        state = zeros(BigFloat, n+1)
        state[1] = BigFloat(1)
        buf = zeros(BigFloat, n+1)

        state1 = zeros(BigFloat, n+1)
        state2 = zeros(BigFloat, n+1)

        instate = zeros(BigFloat, n+1)


        p1 = BigFloat(1) / (m+1)
        p2 = BigFloat(0.5) / m
        p3 = BigFloat.(0:n) / n

        while true
            state1[:] = state
            

            subs_honest(state1)
            add_random(state1, buf, p)
            mix(state1, buf, p3, p, m-1)


            state2[:] = state
            mix(state2, buf, p3, p, 1)

            state1[:] = state1 * p1 .+ state2 * (1 - p1)



            t = state + state1
            t += fix_zero.(t)
            err = sum(abs.(state - state1) ./ t)

            state[:] = state1

            
            if err < eps
                break
            end
        end

        return state
    end

    markov = markov2
end