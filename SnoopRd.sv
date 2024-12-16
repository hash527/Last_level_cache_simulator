package SnoopRd;
    import cache_define::*;
    import UtilFunctions::*;
    function automatic void SnoopedRead(input_index,input_tag);
    int valid_count=0;
    bit flag=0;
    if (mode==NormalMode)
        $display("Operation: SNOOPED READ");
    for(int i=0;i<WAYS;i++)
    begin

        valid_count+=1;
        if (cache[input_index][i].MESI!=I && cache[input_index][i].tag==input_tag)
            begin
            if (cache[input_index][i].MESI==E || cache[input_index][i].MESI==S)
                PutSnoopResult(Address, HIT);
            else begin
                PutSnoopResult(Address, HITM);
                MessageToCache(GETLINE);
            end
            cache[input_index][i].MESI=S;
            if(mode==NormalMode)
                    $display("MESI:%b", MESI_to_string(cache[input_index][i].MESI));
            flag=1;
            break;
            end
    end
    if(flag==0 && valid_count==WAYS)
        PutSnoopResult(Address,NOHIT);
    if(mode==NormalMode)
    $display("No Cache Line Regarding that Memory Reference");
    $display("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
    endfunction
endpackage
