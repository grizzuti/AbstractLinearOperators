export ConvolutionOperator, convolution_operator

mutable struct ConvolutionOperator{T,N}<:AbstractLinearOperator{T,N,T,N}
    stencil::AbstractArray{T,N}
    cdims::Union{Nothing,DenseConvDims}
end

convolution_operator(stencil::AbstractArray{T,N}) where {T,N} = ConvolutionOperator{T,N}(stencil, nothing)

is_init(C::ConvolutionOperator) = ~isnothing(C.cdims)

AbstractLinearOperators.domain_size(C::ConvolutionOperator) = is_init(C) ? NNlib.input_size(C.cdims) : nothing
AbstractLinearOperators.range_size(C::ConvolutionOperator) = is_init(C) ? NNlib.output_size(C.cdims) : nothing
AbstractLinearOperators.label(::ConvolutionOperator) = "Conv"

function AbstractLinearOperators.matvecprod(C::ConvolutionOperator{T,N}, u::AbstractArray{T,N}) where {T,N}
    ~is_init(C) && (C.cdims = DenseConvDims(reshape_conv(u), reshape_conv(C.stencil)))
    return dropdims(conv(reshape_conv(u), reshape_conv(C.stencil)); dims=(N+1,N+2))
end
AbstractLinearOperators.matvecprod_adj(C::ConvolutionOperator{T,N}, v::AbstractArray{T,N}) where {T,N} = dropdims(∇conv_data(reshape_conv(v), reshape_conv(C.stencil), C.cdims); dims=(N+1,N+2))

reshape_conv(u::AbstractArray) = reshape(u, size(u)..., 1, 1)