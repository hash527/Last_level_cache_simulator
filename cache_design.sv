   module cache_design;
  /*logic [31:0] memory_ref;     
  logic [5:0]  byte_select;     
  logic [13:0] index;          
  logic [11:0] input_tag;


  always_comb begin
    byte_select = memory_ref[5:0];    
    index = memory_ref[19:6];          
    input_tag = memory_ref[31:20];          
  end*/



    `define INIT_STATE
    localparam int SET = 2**14;          
    localparam int WAY = 16;          
    localparam int INDEX_BITS = 14;
    localparam int PLRU_BITS = 15;

   
    typedef struct packed {
        bit valid;  
        bit dirty;              
        bit [INDEX_BITS-1:0] tag;
        bit [PLRU_BITS-1:0] plru;
    } cache_entry_t;
 
  cache_entry_t cache [SET][WAY];
   initial begin
   `ifdef INIT_STATE
     begin
       for (int i = 0; i < SET; i++)
begin
  for (int j = 0; j < WAY; j++)
begin
$display("cache[%0d][%0d]: valid=%b, tag=%b, valid=%b dirty=%b",i, j, cache[i][j].valid, cache[i][j].tag,cache[i][j].valid,cache[i][j].dirty);
end
end
     end
   `endif
   end

    initial begin
      for (int i = 0; i < SET; i++)
begin
  for (int j = 0; j < WAY; j++)
begin
cache[i][j].valid = '0;
cache[i][j].dirty = '0;
cache[i][j].tag = '0;
cache[i][j].plru = '0;
             
            end
        end
    end
endmodule
