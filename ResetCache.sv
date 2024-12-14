package ResetCache;
    import cache_define::*;
    import UtilFunctions::*;

    function automatic void ResetCache();
    for(int i=0;i<SETS;i++) begin
            for(int j=0;j<WAYS;j++) begin
                cache[i][j].tag = 0;
                cache[i][j].MESI= I;
            end
    end
    endfunction
endpackage