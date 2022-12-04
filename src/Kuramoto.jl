using Distributions

"""
Kura_step(σ::AbstractArray,ω::AbstractArray,A::Matrix,dt::Number;
        θ=nothing::AbstractArray,noise_scale=nothing,seedval=nothing,τ=nothing)

Simple Euler's method to compute the step evolution of N Kuramoto oscillators.
    
    Inputs:
        σ::AbstractArray    array of couplings
        ω::AbstractArray    array of natural frequencies
        A::Matrix           adjacency matrix of the underlying network
        Δt::Number          time-step for Euler's method
    Optional Inputs
        θ::AbstractArray    instantaneous phases
        noise_scale::Number noise coefficient
        τ::Number           phase delay

## Example:
```jldoctest
julia> Kura_step(
        [1,1],
        [1,1],
        [0 1; 1 0],
        0.02,
        θ=[2,0.5]
    )
2-element Vector{Float64}:
2.0000501002679187
0.5399498997320811
```

"""
function Kura_step(σ::AbstractArray,ω::AbstractArray,A::Matrix,Δt::Number;
	θ=nothing::AbstractArray,τ=nothing,noise_scale=nothing,seedval=nothing)
	# number of nodes N
	N=length(ω)
	
	# set optional arguments
	if θ==nothing
		θ=rand(Uniform(-π, π),N)
	end
	if noise_scale == nothing
		noise_scale=0
	end
	if seedval≢nothing
		# println("Seed value: $(round(Int,seedval))")
		Random.seed!(round(Int,seedval));
	end
	
	# check for dimension mismatch
	if size(A) ≢ (N,N)
		error("Dimension mismatch with adj matrix")
	end
	if length(θ) ≢ N
		error("Dimension mismatch with phases array")
	end
	if length(σ) ≢ N
		error("Dimension mismatch with couplings array")
	end

	# update dθ
	if τ == nothing
		θj_θi_mat=repeat(θ',N)-repeat(θ',N)' # matrix of θ_j-θ_i
	else
		θj_θi_mat=(repeat(θ',N)-repeat(θ',N)').-τ
		setindex!.(Ref(θj_θi_mat), 0.0, 1:N, 1:N) # set diagonal elements to zero (self-interaction terms)
	end
	k1 = *(A.*sin.(θj_θi_mat), σ)
	θ += Δt.*(ω + k1) + noise_scale*(rand(Normal(0,1),N))*sqrt(Δt)		
	return θ
end

# Probably no need to include the seedvalue in the step function as well, since it is
# already in the Kura_sim function

"""

"""