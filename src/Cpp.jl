module Cpp

export @cpp

# Useful references:
# http://www.agner.org/optimize/calling_conventions.pdf
# http://mentorembedded.github.io/cxx-abi/abi.html#mangling

const SUBSTITUTION = [""; map(string, collect(0:9)); map(string, collect('A':'Z'))]  # FIXME more than 37 arguments?

# Allow calling of functions in C++ shared libraries.
# Usage: a = @cpp ccall((:mysymbol,mylib),...)
macro cpp(ex)
    # If you get "undefined symbol" errors, use nm or readelf to view
    # the names of the symbols in the library. Then use the resulting
    # information to help improve this macro!
    # Note: for global objects without class or namespace qualifiers
    # (e.g., global consts), you do not need to use this macro (it
    # will work with a plain ccall, even though it is a C++ library)
    msg = "@cpp requires a ccall((:mysymbol, mylib),...)  expression"
    if !isa(ex,Expr) || ex.head != :ccall
        error(msg)
    end

    # Parse the library symbol's name
    exlib = ex.args[1]
    if !(isa(exlib,Expr) && exlib.head == :tuple)
        error(msg)
    end
    sym = exlib.args[1]
    fstr = string(eval(sym))
    #GNU3-4 ABI
    fstr = string("_Z",length(fstr),fstr)

    # Parse the arguments to ccall and construct the parameter type string
    exargtypes = ex.args[3]
    if exargtypes.head != :tuple
        error(msg)
    end
    exargs = exargtypes.args
    pstr = ""
    symtable = (:Void,:Bool,:Cchar,:Char,:ASCIIString,:Int,:Int8,:Uint8,:Int16,:Uint16,:Int32,:Cint,:Uint32,:Int64,:Uint64,:Float32,:Float64)
    # GNU3-4 ABI v.3 and v.4
    ptable =   ('v',  'b',  'c',   'w',  "Pc",        'i', 'a',  'h',   's',   't',    'i',   'i',  'j',    'l',   'm',    'f',     'd')
    msub = ASCIIString[]
    for iarg = 1:length(exargs)
        thisarg = exargs[iarg]
        thisargm = ""
        while isa(thisarg,Expr) && thisarg.head == :curly && thisarg.args[1] == :Ptr
            thisargm = string(thisargm,'P')
            thisarg = thisarg.args[2]
        end
        matched = false
        for isym = 1:length(symtable)
            if thisarg == symtable[isym]
                matched = true
                thisargm = string(thisargm, ptable[isym])
                # Cchar is a special notation just for name mangling,
                # convert back to :Int8
                if thisarg == :Cchar
                    ex.args[3].args[iarg] = :Int8
                end
                break
            end
        end
        if matched
            if length(thisargm) > 1
                # Use substitution
                idx = indexin([thisargm], msub)[1]
                if idx != 0
                    pstr = string(pstr, "S"*SUBSTITUTION[idx]*"_")
                else
                    push!(msub, thisargm)
                    pstr = string(pstr, thisargm)
                end
            else
                pstr = string(pstr, thisargm)
            end
        else
            println(thisarg)
            error("@cpp: argument not recognized")
        end
    end
    ex.args[1].args[1] = Expr(:quote, symbol(string(fstr,pstr)))
    ex.args[1].args[2] = esc(ex.args[1].args[2])
    for ival = 4:length(ex.args)
        ex.args[ival] = esc(ex.args[ival])
    end
    ex
end

end
