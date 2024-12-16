package PrRd;
import cache_define::*;
import UpdatePlru::*;
import EvictPlru::*;
import UtilFunctions::*;

  function automatic void ProcessorRead(input_index,input_tag);
  bit flag;
  int valid_count;
  cache_reads+=1;

  /////////CHECK FOR HIT/////////////

  if(mode==NormalMode)
      $display("OPERATION: PROCESSOR READ");
  for(int j=0; j<WAYS; j=j+1)
        begin
                if(cache[input_index][j].MESI!=I)
                begin
                    valid_count+=1;
                        if(cache[input_index][j].tag==input_tag)
                            begin
                              cache_hits+=1;
                              if(mode==NormalMode) begin
                                  $display("HIT/MISS: CACHE HIT");
                                  $display("MESI State:%b, TAG:%h",MESI_to_string(cache[input_index][j].MESI),cache[input_index][j].tag);
                              end
                              MessageToCache(SENDLINE,Address);
                              Update_PLRU(PLRU[input_index],j);
                              flag=1;
                              break;
                            end
                end
        end

    //////////CHECK FOR VACANCY//////////
    if(flag==0 && valid_count!=WAYS)
      begin
        cache_misses+=1;
        if(mode==NormalMode)
              $display("HIT/MISS: CACHE MISS");
        for(int i=0;i<WAYS;i++) begin

          if(cache [input_index][i].MESI==I)
            begin

              SnoopResult=GetSnoopResult(Address);
              BusOperation(READ,Address,SnoopResult);

              if(SnoopResult==NOHIT)
                cache [input_index][i].MESI=E;
              else
                cache [input_index][i].MESI=S;
              cache [input_index][i].tag=input_tag;
              if(mode==NormalMode)
                  $display("MESI State:%b, TAG:%h",MESI_to_string(cache[input_index][i].MESI),cache[input_index][i].tag);
              Update_PLRU(PLRU[input_index],i);

              MessageToCache(SENDLINE,Address);
              break;
            end        
        end          
      end


    /////////COLLISION MISS//////////
    if(flag==0 && valid_count==WAYS)
      begin
        bit [$clog2(SETS)-1:0]WayToEvict;
        cache_misses+=1;
        if(mode==NormalMode)
            $display("HIT/MISS: CACHE MISS");
        WayToEvict=victim_cache(PLRU[input_index]);
        if (cache [input_index][WayToEvict].MESI==M)
                MessageToCache(GETLINE, Address)
        MessageToCache(EVICTLINE,Address);
        SnoopResult=GetSnoopResult(Address);
        BusOperation(READ,Address,SnoopResult);

        if(SnoopResult!=NOHIT)
          cache [input_index][WayToEvict].MESI=S;
        else
          cache [input_index][WayToEvict].MESI=E;
        cache [input_index][WayToEvict].tag=input_tag;
        if(mode==NormalMode)
            $display("MESI State:%b, TAG:%h",MESI_to_string(cache[input_index][WayToEvict].MESI),cache[input_index][WayToEvict].tag);

        MessageToCache(SENDLINE,Address);
      end
    if(mode==NormalMode) begin
        $display("++++++++++++++++++++++++++++++++++++++++++++++++++");
        $display(" ");
    end
  endfunction

endpackage
