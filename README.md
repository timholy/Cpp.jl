# Cpp.jl

Simple utilities for calling C++ from Julia

See also [CxxWrap](https://github.com/JuliaInterop/CxxWrap.jl), [Clang](https://github.com/ihnorton/Clang.jl), and [Cxx](https://github.com/Keno/Cxx.jl).
CxxWrap is the recommended solution for calling C++ and supersedes this package.

# Overview

[Julia][Julia] can call C code with no overhead, but it does not natively
support C++. However, the C++ [ABI][ABIdef] is essentially "C plus some extra
conventions," of which the most noteworthy is [name mangling][mangle]. Name
mangling is used to support function overloading, a key C++ (and Julia) feature.
Infamously, different compilers use different mangling conventions, and this has
lead to more than a few headaches. However, in recent years there has been a
greater push for standardization of the C++ ABI, and there is [good
documentation][ABI] available on calling conventions of different compilers.

This package provides utilities to call functions in C++ shared libraries as if
they were C. Currently it consists of a single macro, `@cpp`.

# Installation

Install from the Julia prompt via `Pkg.add("Cpp")`.

# Usage

An example C++ shared library, `libdemo`, is provided in the `deps` directory.
It contains the function `timestwo`, defined for two different C++ types:

     int timestwo(int x) {
       return 2*x;
     }

     double timestwo(double x) {
       return 2*x;
     }

Within Julia, let's suppose you've defined the variable `libdemo` to be a constant string
containing the path to this library. You can use these functions by placing the
``@cpp`` macro prior to a ccall, for example:

     x = 3.5
     x2 = @cpp ccall((:timestwo, libdemo), Float64, (Float64,), x)
     y = 3
     y2 = @cpp ccall((:timestwo, libdemo), Int, (Int,), y)
     
The macro performs C++ ABI name-mangling, using the types of the parameters, to determine the correct library symbol. On a UNIX/gcc system, the first will generate a call to
`_Z8timestwod`, and the second to `_Z8timestwoi`.

# Limitations/TODO

Like ``ccall``, this performs library calls without overhead. However, currently
it has a number of limitations:

   * It does not support pure-header libraries
   * Using C++ objects has not been tested, and probably won't work without additional effort
   * Currently there is no C++ namespace support
   * Currently there is no support for templated functions
   * Currently only g++ is supported

The latter three may not be difficult to [fix][ABI]. 



[Julia]: http://julialang.org "Julia"
[mangle]: http://en.wikipedia.org/wiki/Name_mangling "name mangling"
[ABIdef]: http://en.wikipedia.org/wiki/Application_binary_interface "application binary interface"
[ABI]: http://www.agner.org/optimize/calling_conventions.pdf "C++ ABI"
