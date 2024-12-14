package PrWr;
    import cache_define::*;
    import UpdatePlru::*;
    import EvictPlru::*;
    import UtilFunctions::*;
    function automatic void ProcessorWrite(input_index,input_tag);
    bit flag;
    int valid_count;
    cache_writes+=1;
        /////////CHECK FOR HIT///////////
        if(mode==NormalMode)
            $display("OPERATION: PROCESSOR WRITE");
        for(int j=0; j<WAYS; j=j+1)
            begin
                if(cache[input_index][j].MESI!=I)
                    begin
                        valid_count+=1;
                        if(cache[input_index][j].tag==input_tag)
                        begin

                        cache_hits+=1;
                        if(mode==NormalMode)
                            $display("HIT/MISS: CACHE HIT");
                        MessageToCache(SENDLINE,Address);

                        if(cache[input_index][j].MESI==S)
                            BusOperation(INVALIDATE,Address,SnoopResult);

                        cache[input_index][j].MESI= M;
                        if(mode==NormalMode)
                            $display("MESI State:%b, TAG:%h",MESI_to_string(cache[input_index][j].MESI),cache[input_index][j].tag);                        
                        Update_PLRU(PLRU[input_index],j);
                        flag=1;
                        break;
                        end
                    end
            end


        //////////CHECK FOR VACANCY///////////

        if(flag==0 && valid_count!=WAYS)
            begin
                cache_misses+=1;
                if(mode==NormalMode)
                    $display("HIT/MISS: CACHE MISS");
                for(int i=0;i<WAYS;i++) begin
                    if(cache [input_index][i].MESI==I)
                        begin
                            BusOperation(RWIM,Address,SnoopResult);
                            cache [input_index][i].MESI=M;
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
            bit [$clog2(WAYS)-1:0]WayToEvict;
            cache_misses+=1;
            if(mode==NormalMode)
                $display("HIT/MISS: CACHE MISS");
            WayToEvict=victim_cache(PLRU[input_index]);
            MessageToCache(EVICTLINE,Address);
            BusOperation(RWIM,Address,SnoopResult);
            cache [input_index][WayToEvict].MESI=M;
            cache [input_index][WayToEvict].tag=input_tag;
            if(mode==NormalMode)
                $display("MESI State:%b, TAG:%h",MESI_to_string(cache[input_index][WayToEvict].MESI),cache[input_index][WayToEvict].tag);

            MessageToCache(SENDLINE,Address);
        end  
        if(mode==NormalMode)  begin      
            $display("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
            $display(" ");
        end
    endfunction

    endpackage