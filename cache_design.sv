`define NOHIT 0
`define HIT 1
`define HITM 2


`define READ 1
`define WRITE 2
`define INVALIDATE 3
`define RWIM 4 


`define GETLINE 1 
`define SENDLINE 2 
`define INVALIDATELINE 3 
`define EVICTLINE 4 

`define I 2'b00
`define E 2'b01
`define M 2'b10
`define S 2'b11


module cache_design;
  
`define INIT_STATE
localparam int SETS = 2**14;          
localparam int WAYS = 16;          
localparam int INDEX_BITS = 14;
localparam int PLRU_BITS = 15;

typedef struct packed {
  bit [1:0]MESI;           
  bit [INDEX_BITS-3:0] tag;
} cache_entry_t;


cache_entry_t cache [SETS][WAYS];

bit [$clog2(WAYS)-1:0] ways_seq[WAYS-1:0];
initial begin
    ways_seq[0] = 0000;
    ways_seq[1] = 0001;
    ways_seq[2] = 0010;
    ways_seq[3] = 0011;
    ways_seq[4] = 0100;
    ways_seq[5] = 0101;
    ways_seq[6] = 0110;
    ways_seq[7] = 0111;
    ways_seq[8] = 1000;
    ways_seq[9] = 1001;
    ways_seq[10] = 1010;
    ways_seq[11] = 1011;
    ways_seq[12] = 1100;
    ways_seq[13] = 1101;
    ways_seq[14] = 1110;
    ways_seq[15] = 1111;
end

bit [PLRU_BITS-1:0] PLRU [SETS-1:0];
string file_name;
int file;
int id;
bit [31:0] Address;
int status; 
string default_file_name = "rims.din"; 
string line;
bit [11:0]input_tag;
bit [13:0] input_index;
int cache_reads;
int cache_writes;
int cache_hits;
int cache_misses;
int cache_hit_ratio;
int SnoopResult;
  
initial begin

    if ($value$plusargs("file_name=%s", file_name)) begin
      `ifdef DEBUG
      $display("Using specified file: %s", file_name);
      `endif
    end 
    else begin
      file_name = default_file_name;
      `ifdef DEBUG
      $display("No file name specified, using default file: %s", default_file_name);
      `endif
    end


    file = $fopen(file_name, "r");
    if (file == 0) begin
      $fatal("Error: Could not open file '%s'", file_name);
    end


    while (!$feof(file)) begin
      status = $fscanf(file, "%d %h\n", id, Address); 
      if (status == 2) begin
        `ifdef DEBUG
        sample(id,Address);
        `endif
      end
end
    $display("cache_reads = %0d cache_writes =%0d cache_hits = %0d cache_misses = %0d",cache_reads,cache_writes,cache_hits,cache_misses);
    $fclose(file);
  end
  
  

function automatic void Update_PLRU(ref bit [14:0]PLRU, bit [3:0]way);
    int index=0;
    for (int i = 3; i >=0; i--) begin
      if (way[i] == 0) begin
        PLRU[index] = way[i];
        index = 2 * index + 1;        
      end 
      else begin
        PLRU[index] = way[i];                 
        index = 2 * index + 2;        
      end
    end
endfunction
  
 
  
function automatic bit [3:0] victim_cache(ref bit[14:0]PLRU);
    int index=0;
    bit [3:0]victim;
    for (int i = 3; i >=0; i--) begin
      if (PLRU[index] == 0) begin
        PLRU[index] = 1;
        victim[i]=1;
        index = 2 * index + 2;        
      end 
      else begin
        PLRU[index] = 0; 
        victim[i]=0;
        index = 2 * index + 1;        
      end
    end
    return victim;
endfunction
 
  
function automatic void BusOperation(int BusOp, bit[31:0] Address, int SnoopResult);
    
    SnoopResult=GetSnoopResult(Address);
    $display("BusOp: %0d, Address: %h, Snoop Result: %0d\n",BusOp,Address, SnoopResult);
    
endfunction
  
  
  
function automatic void PutSnoopResult(bit [31:0] Address, int SnoopResult);
    
      $display("SnoopResult: Address %h, SnoopResult: %d\n", Address, SnoopResult);
endfunction
  

  
function automatic void MessageToCache(int Message, bit [31:0] Address);
    $display("L2: %0d %0h\n", Message, Address);
endfunction
  
  

  
function automatic int GetSnoopResult(bit[31:0] Address);
    if(Address[1:0]==2'b00)
        return `HIT;
    else if(Address[1:0]==2'b01)
        return `HITM;
      else
        return `NOHIT;
endfunction
  
function automatic void sample(int id, bit [31:0] Address);
    case (id)
      0,2 : PrRd(Address);
      1 : Processor_Write(Address);
      3 : $display("snooped read request");
      4 : $display("snooped write request");
      5 : $display("snooped Read with Intent to Modify");
      6 : $display("snooped Invalidate");
      8 : $display("reset all the states");
      9 : $display("print all the cache values");
      default: $display("Not valid operation");
    endcase
endfunction
  
  

function automatic void PrRd(bit [31:0] Address);
    bit bool_a;
    bit [3:0]valid_count; 
    input_index = Address[19:6];
    input_tag = Address [31:20];
    cache_reads+=1;
    for(int j=0; j<16; j=j+1)
         begin
            if(cache[input_index][j].MESI==`S || cache[input_index][j].MESI==`E || cache[input_index][j].MESI==`M)
              begin
                 valid_count+=1;
                 if(cache[input_index][j].tag==input_tag)
                   begin
                    cache_hits+=1;
                    // MessageToCache(`SENDLINE,Address);
                    Update_PLRU(PLRU[input_index],ways_seq[j]);
                    bool_a=1;
                    break;
                   end
              end


         end
    if(bool_a==0 && valid_count!=16)
        begin
            cache_misses+=1;
            for(int i=0;i<16;i++) begin
                if(cache [input_index][i].MESI==`I)
                    begin
                        SnoopResult = GetSnoopResult(Address);
                        if(SnoopResult==`HIT)
                            cache [input_index][i].MESI=`S;
                        else
                            cache [input_index][i].MESI=`E;  
            Update_PLRU(PLRU[input_index],ways_seq[i]);
            cache [input_index][i].tag=input_tag;
            // MessageToCache(`SENDLINE,Address);
            break;
                end
            
            end
                
        end
    
        if(bool_a==0 && valid_count==16)
        begin
            bit [3:0]WayToEvict;
            WayToEvict=victim_cache(PLRU[input_index]);
            SnoopResult = GetSnoopResult(Address);
            if(SnoopResult==`HIT||SnoopResult==`HITM)
                    cache [input_index][WayToEvict].MESI=`S; 
            else
                    cache [input_index][WayToEvict].MESI=`E; 
            cache [input_index][WayToEvict].tag=input_tag;
            // MessageToCache(`SENDLINE,Address);
            cache_misses+=1;
        end

endfunction
  

function automatic void Processor_Write(bit [31:0] Address);
bit flag;
int valid_count; 
input_index = Address[19:6];
input_tag = Address [31:20];
cache_writes+=1;

for(int j=0; j<16; j=j+1)
    begin
  $display("MESI:%d tag = %d",cache[input_index][j].MESI,cache[input_index][j].MESI);

        if(cache[input_index][j].MESI==`S || cache[input_index][j].MESI==`E || cache[input_index][j].MESI==`M)
            begin
                valid_count+=1;
                if(cache[input_index][j].tag==input_tag)
                begin
                cache_hits+=1;
                // MessageToCache(`SENDLINE,Address);
                if(cache[input_index][j].MESI==`S)
                    begin
                    cache[input_index][j].MESI= `M;
                    BusOperation(`HIT,Address,`INVALIDATE);
                    end    
                if(cache[input_index][j].MESI==`E)
                    begin
                    cache[input_index][j].MESI= `M;
                    end                          
                Update_PLRU(PLRU[input_index],ways_seq[j]);
                flag=1;
                break;
                end
            end
    end

if(flag==0 && valid_count!=16)
    begin
        cache_misses+=1;
        for(int i=0;i<16;i++) begin
            if(cache [input_index][i].MESI==`I)
                begin
                    cache [input_index][i].MESI=`M;  
                    Update_PLRU(PLRU[input_index],ways_seq[i]);
                    cache [input_index][i].tag=input_tag;
                    // MessageToCache(`SENDLINE,Address);
                    break;
                end
        end
            
end

if(flag==0 && valid_count==16)
            begin
                bit [3:0]WayToEvict;
                WayToEvict=victim_cache(PLRU[input_index]);
                cache [input_index][WayToEvict].MESI=`M; 
                cache [input_index][WayToEvict].tag=input_tag;
                // MessageToCache(`SENDLINE,Address);
                cache_misses+=1;
            end            

endfunction
endmodule
