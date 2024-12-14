package EvictPlru;
  import cache_define::*;
  function automatic bit [$clog2(SETS):0] victim_cache(ref bit[PLRU_BITS-1:0]PLRU);
    int index=0;
    bit [$clog2(SETS):0] victim;
    for (int i = $clog2(SETS); i >=0; i--) begin
      if (PLRU[index] == 0)
       begin
        PLRU[index] = 1;
        victim[i]=1;
        index = 2 * index + 2;        
       end
      else
       begin
        PLRU[index] = 0;
        victim[i]=0;
        index = 2 * index + 1;        
       end
    end
    return victim;
  endfunction
endpackage