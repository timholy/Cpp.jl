using Cpp

# Find the test library (this is not normally needed)
fnames = ["libdemo.so", "libdemo.dylib", "libdemo.dll"]
paths = [pwd(), joinpath(Pkg.dir(), "Cpp", "deps")]
global libname
found = false
for path in paths
    if !found
        for fname in fnames
            libname = Base.find_in_path(joinpath(path, fname))
            if isfile(libname)
                found = true
                break
            end
        end
    end
end
if !isfile(libname)
    error("Library cannot be found; it may not have been built correctly.\n Try include(\"build.jl\") from within the deps directory.")
end
const libdemo = libname


x = 3.5
x2 = @cpp ccall((:timestwo, libdemo), Float64, (Float64,), x)
@assert x2 == 2x
y = 3
y2 = @cpp ccall((:timestwo, libdemo), Int, (Int,), y)
@assert 2y == y2
