package SnoopRdx;
    import cache_define::*;
    import UtilFunctions::*;
    function automatic void SnoopedRdx(input_index,input_tag);
    bit flag=0;
    int valid_count=0;
    if (mode==NormalMode)
        $display("Operation: SNOOPED READ WITH INTENT TO MODIFY");
    for(int i=0;i<WAYS;i++)
    begin

        valid_count+=1;
        if (cache[input_index][i].MESI!=I && cache[input_index][i].tag==input_tag)
        begin

            if (cache[input_index][i].MESI==E || cache[input_index][i].MESI==S)
            PutSnoopResult(Address, HIT);

            else

            begin
            PutSnoopResult(Address, HITM);
            MessageToCache(GETLINE, Address);
            end

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
        $display("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
    endfunction
endpackage