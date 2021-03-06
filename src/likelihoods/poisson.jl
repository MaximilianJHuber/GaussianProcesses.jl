"""
# Description
Constructor for the Poisson likelihood

    p(yᵢ=k|fᵢ) = θᵏ × exp(-θ)/k!

# Arguments:
* `θ::Float64`: rate parameter is the exponential of the latent function, i.e. θ = exp(f)
"""

type PoisLik <: Likelihood
    PoisLik() = new()
end

#log of probability density
function log_dens(poisson::PoisLik, f::Vector{Float64}, y::Vector{Int64})
    #where we exponentiate for positivity f = exp(fi) 
    return y.*f - exp.(f) - lgamma.(1.0 .+ y)
end

#derivative of pdf wrt latent function
function dlog_dens_df(poisson::PoisLik, f::Vector{Float64}, y::Vector{Int64})
    return y - exp.(f) 
end                   

#mean and variance under likelihood
mean_lik(poisson::PoisLik, f::Vector{Float64}) = exp.(f)
var_lik(poisson::PoisLik, f::Vector{Float64}) = exp.(f)

get_params(poisson::PoisLik) = []
num_params(poisson::PoisLik) = 0


