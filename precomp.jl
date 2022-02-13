function precompile_pkgs() end
try
    @eval using ProgressMeter
    @eval function precompile_pkgs()
        @showprogress for pkg in collect(keys(Pkg.installed()))
            if !isdefined(Symbol(pkg))
                info("Importing $(pkg)...")
                try (@eval import $(Symbol(pkg))) catch end
            end
        end
    end
catch
    function precompile_pkgs()
        for pkg in collect(keys(Pkg.installed()))
            if !isdefined(Symbol(pkg))
                info("Importing $(pkg)...")
                try (@eval import $(Symbol(pkg))) catch end
            end
        end
    end
end
precompile_pkgs()