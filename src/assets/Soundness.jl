using PyPlot
include("../Markov.jl")
using .Markov

p = BigFloat("0.5")
n=512
m = 3

distribution = markov(p, n, m)

prefixes = cumsum(distribution)
security_bits = -log.(prefixes) ./ log(2)
x = collect(0:n)



plot(x, security_bits)
xlabel("k")
ylabel("Security bits")
title("Soundness for p = $p, n = $n, m = $m")
grid(true)
savefig("assets/soundness.svg")

#show()

