package SnoopInvalidate;
    import cache_define::*;
    import UtilFunctions::*;
    function automatic void Snooped_Invalidate(input_index,input_tag);
        int valid_count=0;
        bit flag=0;
        if (mode==NormalMode)
            $display("Operation: SNOOPED INVALIDATE");
        for(int i=0;i<16;i++)
            begin
            valid_count+=1;
            if (cache[input_index][i].MESI==S && cache[input_index][i].tag==input_tag)
            begin
                PutSnoopResult(Address,HIT);
                MessageToCache(INVALIDATELINE, Address);
                cache[input_index][i].MESI=I;
                if(mode==NormalMode)
                        $display("MESI:%b", MESI_to_string(cache[input_index][i].MESI));
                flag=1;
                break;
            end
            end
        if(flag==0 && valid_count==WAYS)
            begin
            PutSnoopResult(Address,NOHIT);
            end
        if(mode==NormalMode)
            //$display("No Cache Line Regarding that Memory Reference");
            $display("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
    endfunction
  endpackage
   