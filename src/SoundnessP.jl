# Parallel soundness computation for the Markov chain model
#
# Usage:
# julia --project="." -p 16 src/SoundnessP.jl

using Distributed

@everywhere include("Markov.jl")
@everywhere using .Markov

using Printf
using Base.Iterators



@everywhere function dyn_soundness(p, n, k, m)
    equi_state = markov(p, n, m)
    return -log(sum(equi_state[1:k])) / log(2)
end



xt = [4, 8, 16, 32, 64]
p = [0.25, 0.38, 0.5]

@everywhere  m=3

res = pmap(function(e)
    (_xt, __p) = e
    _p = BigFloat(__p)
    s_128 = dyn_soundness(_p, _xt * 128, 128, m)
    s_64 = dyn_soundness(_p, _xt * 64, 64, m)
    s_32 = dyn_soundness(_p, _xt * 32, 32, m)
    s_1 = dyn_soundness(_p, _xt * 1, 1, m)
    return (_xt, __p, s_128, s_64, s_32, s_1)
end, collect(Iterators.product(xt, p)))



println("""
| Blowup | \$p\$ | \$k=128\$ | \$k=64\$ | \$k=32\$ | \$k=1\$ |
| --- | --- | --- | --- | --- | --- |""")

function _format(x)
    res = @sprintf("%.1f", x)
    if endswith(res, ".0")
        res = res[1:end-2]
    end
    return res
end



for r in res
    (_xt, _p, s_128, s_64, s_32, s_1) = r
    println("| $_xt | $_p | $(_format(s_128)) | $(_format(s_64)) | $(_format(s_32)) | $(_format(s_1)) |")
end
