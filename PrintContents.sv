package PrintContents;
    import cache_define::*;
    function automatic void PrintValidCacheLines();
        bit valid;
        bit [SETS] print_plru = 0;
        $display("Valid Lines in LLC:");
        $display("");
        $display("MESI   |    TAG    |            SET     |        WAY    |");
        for(int i=0;i<SETS;i++) begin
                print_plru [i] = 0;
                for(int j=0;j<WAYS;j++) begin          
                    if (cache[i][j].MESI!=I)
                    begin
                                print_plru[i] = 1;
                                valid=1;
                                $display("-------------------------------------------------------");
                                $display(" %s     |    %h    |    %d     |%d    |",MESI_to_string(cache[i][j].MESI), cache[i][j].tag,i,j);
                    end
            end
            if(print_plru[i]==1)
                begin
                    $display("*********************************************************");
                    $display("            PLRU of SET %0d is %b", i,PLRU[i]);
                    $display("*********************************************************");

                end

        end
        if(valid==0)
            $display("No Valid Lines in LLC\n");

    endfunction
endpackage