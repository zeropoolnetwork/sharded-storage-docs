using PyPlot
include("Markov.jl")
using .Markov

p = BigFloat("0.5")
k = 64
xt = 8
m = 3

distribution = markov(p, k*xt, m)

plot(distribution)
xlabel("Index")
ylabel("Probability")
title("Number of honest nodes in pool distribution")
grid(true)
show()

