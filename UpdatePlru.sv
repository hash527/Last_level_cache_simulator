package UpdatePlru;
  import cache_define::*;
  function automatic void Update_PLRU(ref bit [PLRU_BITS-1:0]PLRU, input bit [$clog2(SETS)-1:0]way);
    int index=0;
    for (int i = $clog2(SETS)-1; i >=0; i--) begin
      if (way[i] == 0) begin
        PLRU[index] = way[i];
        index = 2 * index + 1;        
      end
      else begin
        PLRU[index] = way[i];                
        index = 2 * index + 2;        
      end
    end
      if(mode==NormalMode)
        $display("PLRU = %b",PLRU);
  endfunction
endpackage
