include("Markov.jl")

using SpecialFunctions
using .Markov

function fault_probability(p, n, k)
    return 0.5 * (1 + erf((k - 0.5 - n * p) / sqrt(2 * n * p * (1 - p))))
end

function dyn_soundness(p, n, k, m)
    equi_state = markov(p, n, m)
    return -log(sum(equi_state[1:k])) / log(2)
end

function soundness(p, xt, k)
    return -log(fault_probability(p, xt * k, k)) / log(2)
end

function soundness2(p, xt)
    return -log(1 - p) * xt / log(2)
end

function n_by_soundness(p, k, s)
    n = 2 * k
    while soundness(p, n, k) < s
        n += k
    end

    lower = n - k
    upper = n
    while lower < upper
        mid = floor((lower + upper) / 2)
        if soundness(p, mid, k) < s
            lower = mid + 1
        else
            upper = mid
        end
    end
    return lower
end

function xt_by_soundness(p, k, s)
    return n_by_soundness(p, k, s) / k
end

function xt_by_soundness2(p, s)
    return -s / log(1 - p) / log(2)
end

# p_1 = 1-\frac{(m+1)(n-1)(1-p)}{n m}
function dynamic_p(p, n, m)
    return 1 - (m + 1) * (n - 1) * (1 - p) / (n * m)
end



# Main execution
p = BigFloat("0.5")
k = 64
xt = 8
m = 3

println("Soundness for sharding p=$(p), k=$(k), xt=$(xt): $(Int(floor(soundness(p, xt, k))))")
println("Dynamic soundness for sharding for p=$(p), k=$(k), xt=$(xt), m=$(m): $(Int(floor(dyn_soundness(p, xt * k, k, m))))")

xt = 8
println("Soundness for replica p=$(p), xt=$(xt): $(Int(floor(soundness2(p, xt))))")
println("Dynamic soundness for replica for p=$(p), xt=$(xt), m=$(m): $(Int(floor(dyn_soundness(p, xt, 1, m))))")


# s = [64, 96, 128]
# k = [64, 128, 256, 512]
# p = [1/4, 1/2, 3/4]

# println("""
# | Security | \$p\$ | Sharding \$k\$ | Sharding \$n\$ | Sharding blowup | Replication blowup | Advantage of sharding |
# | --- | --- | --- | --- | --- | --- | --- |""")

# for _s in s
#     for _p in p
#         for _k in k
#             xt1 = xt_by_soundness(_p, _k, _s)
#             n = Int(xt1 * _k)
#             xt2 = xt_by_soundness2(_p, _s)
#             println("| $_s | $_p | $_k | $n | $(round(xt1, digits=1)) | $(round(xt2, digits=1)) | $(round(xt2/xt1, digits=1)) |")
#         end
#     end
# end