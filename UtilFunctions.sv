package UtilFunctions;
    import cache_define::*;
    function automatic void BusOperation(int BusOp, bit[ADDRESS_WIDTH-1:0] Address, int SnoopResult);
    if(mode==NormalMode)
    $display("BusOp: %s, Address: %h, Snoop Result: %s\n",BusOP_to_string(BusOp),Address,Snoop_to_string(SnoopResult));
    endfunction

    function automatic void PutSnoopResult(bit [ADDRESS_WIDTH-1:0] Address, int SnoopResult);
    if(mode==NormalMode)
        $display("SnoopResult: Address %h, SnoopResult: %0d\n", Address, Snoop_to_string(SnoopResult));
    endfunction

    function automatic void MessageToCache(int Message, bit [ADDRESS_WIDTH-1:0] Address);
    if(mode==NormalMode)
    $display("Message to Higher Level Cache: %s %h\n", CacheMessage_to_string(Message),Address);
    endfunction

    function automatic int GetSnoopResult(bit[ADDRESS_WIDTH-1:0] Address);
    if(Address[MESIBITS-1:0]==2'b00)
        return HIT;
    else if(Address[MESIBITS-1:0]==2'b01)
        return HITM;
    else
        return NOHIT;
    endfunction
endpackage