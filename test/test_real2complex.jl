using AbstractLinearOperators, Test

# Linear operator
input_size = (2^7, 2^8)
T = Float64
A = real2complex_operator(T; size=input_size)
B = complex2real_operator(Complex{T}; size=input_size)

# Real to complex test
rtol = 1e-6
u = randn(T, input_size)
v = randn(Complex{T}, input_size)
@test A*u ≈ complex(u) rtol=rtol
@test B*v ≈ real(v) rtol=rtol

# Adjoint test
rtol = 1e-6
@test adjoint_test(A; rtol=rtol)
@test adjoint_test(B; rtol=rtol)