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
ylabel("Value")
title("Array Plot")
grid(true)
show()

