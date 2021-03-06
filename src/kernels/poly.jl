# Polynomial covariance function 

@doc """
# Description
Constructor for the Polynomial kernel (covariance)

k(x,x') = σ²(xᵀx'+c)ᵈ
# Arguments:
* `lc::Float64`: Log of the constant c
* `lσ::Float64`: Log of the signal standard deviation σ
* `d::Int64`   : Degree of the Polynomial
""" ->
type Poly <: Kernel
    c::Float64      # constant
    σ2::Float64      # Signal variance
    deg::Int64       # degree of polynomial
    priors::Array          # Array of priors for kernel parameters
    Poly(lc::Float64, lσ::Float64, deg::Int64) = new(exp(lc), exp(2.0*lσ), deg, [])
end

function KernelData{M<:MatF64}(k::Poly, X::M)
    XtX=X'*X
    Base.LinAlg.copytri!(XtX, 'U')
    LinIsoData(XtX)
end
kernel_data_key{M<:MatF64}(k::Poly, X::M) = "LinIsoData"

_cov(poly::Poly, xTy) = poly.σ2*(poly.c.+xTy).^poly.deg
function cov{V1<:VecF64,V2<:VecF64}(poly::Poly, x::V1, y::V2)
    K = _cov(poly, dot(x,y))
end
function cov!{M<:MatF64}(cK::MatF64, poly::Poly, X::M, data::LinIsoData)
    cK[:,:] = _cov(poly, data.XtX)
    return cK
end
function cov{M<:MatF64}(poly::Poly, X::M, data::LinIsoData)
    K = _cov(poly, data.XtX)
    return K
end

get_params(poly::Poly) = Float64[log(poly.c), log(poly.σ2)/2.0]
get_param_names(poly::Poly) = [:lc, :lσ]
num_params(poly::Poly) = 2

function set_params!(poly::Poly, hyp::Vector{Float64})
    length(hyp) == 2 || throw(ArgumentError("Polynomial function has two parameters"))
    poly.c = exp(hyp[1])
    poly.σ2 = exp(2.0*hyp[2])
end

@inline dk_dlc(poly::Poly, xTy::Float64) = poly.c*poly.deg*poly.σ2*(poly.c+xTy).^(poly.deg-1)
@inline dk_dlσ(poly::Poly, xTy::Float64) = 2.0*_cov(poly,xTy)
@inline function dKij_dθp{M<:MatF64}(poly::Poly, X::M, i::Int, j::Int, p::Int, dim::Int)
    if p==1
        return dk_dlc(poly, dotij(X,i,j,dim))
    else
        return dk_dlσ(poly, dotij(X,i,j,dim))
    end
end
@inline function dKij_dθp{M<:MatF64}(poly::Poly, X::M, data::LinIsoData, i::Int, j::Int, p::Int, dim::Int)
    if p==1
        return dk_dlc(poly, data.XtX[i,j])
    else
        return dk_dlσ(poly, data.XtX[i,j])
    end
end
