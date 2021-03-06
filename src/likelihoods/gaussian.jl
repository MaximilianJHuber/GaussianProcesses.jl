"""
# Description
Constructor for the Gaussian, aka Normal, likelihood

p(y|μ,σ²) = 1/(√(2πσ²))*exp(-(x-μ)²/2σ²)
# Arguments:
* `lσ::Float64`: Log of the signal standard deviation σ
"""
type GaussLik <: Likelihood
    σ::Float64     # standard deviation
    priors::Array          # Array of priors for likelihood parameters
    GaussLik(lσ::Float64) = new(exp(lσ),[])
end

#log of probability density
function log_dens(gauss::GaussLik, f::Vector{Float64}, y::Vector{Float64})
    return -0.5*log(2*pi) - log(gauss.σ) -0.5*((y-f)/gauss.σ).^2
end

#derivative of log pdf wrt latent function
function dlog_dens_df(gauss::GaussLik, f::Vector{Float64}, y::Vector{Float64})
    return [(yi-fi)/gauss.σ^2 for (fi,yi) in zip(f,y)]
end                   

#derivative of log pdf wrt to parameters
function dlog_dens_dθ(gauss::GaussLik, f::Vector{Float64}, y::Vector{Float64})
    return gauss.σ*[-1/gauss.σ + 1/gauss.σ^3*(yi-fi).^2 for (fi,yi) in zip(f,y)]
end                   

#mean and variance under likelihood
mean_lik(gauss::GaussLik, f::Vector{Float64}) = f
var_lik(gauss::GaussLik, f::Vector{Float64}) = ones(length(f))*gauss.σ^2


function set_params!(gauss::GaussLik, hyp::Vector{Float64})
    length(hyp) == 1 || throw(ArgumentError("Gaussian/Normal likelihood has only one free parameter"))
    gauss.σ = exp(hyp[])
end

get_params(gauss::GaussLik) = Float64[log(gauss.σ)]
num_params(gauss::GaussLik) = 1


#Computes the predictive mean and variance 
function predict_obs(gauss::GaussLik, fmean::Vector{Float64}, fvar::Vector{Float64}) 
    return fmean, fvar + gauss.σ^2
end





