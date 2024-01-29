using Combinatorics



module Markov

    DEBUG=0

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
    
    function markov(p::BigFloat, n::Int, m::Int)
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

end