package cache_define;
parameter SilentMode = 0 , NormalMode = 1;

//Snoop Results of other caches
parameter NOHIT = 2'b11;
parameter HIT = 2'b00;
parameter HITM = 2'b01;

//"---00= HIT,   ---01 = HitM        ---10   or  ---11 = NoHit"

parameter READ = 1;
parameter WRITE = 2;
parameter INVALIDATE = 3;
parameter RWIM = 4; 

 //L2 to L1 Messages
parameter GETLINE = 1;
parameter SENDLINE = 2; 
parameter INVALIDATELINE = 3;
parameter EVICTLINE = 4; 

//MESI bits
parameter I = 2'b00;
parameter E = 2'b01;
parameter M = 2'b10;
parameter S = 2'b11;


parameter CACHE_SIZE = 2**24;
parameter WAYS = 16;          
parameter ADDRESS_WIDTH = 32;
parameter CACHE_LINE_SIZE = 2**6;
parameter OFFSET_BITS =  $clog2(CACHE_LINE_SIZE);
parameter SETS = CACHE_SIZE /(CACHE_LINE_SIZE*WAYS);          
parameter INDEX_BITS = $clog2(SETS);
parameter PLRU_BITS = WAYS-1;
parameter MESIBITS = 2;

typedef struct packed {
  bit [MESIBITS-1:0]MESI;          
  bit [INDEX_BITS-3:0] tag;
} cache_entry_t;

  cache_entry_t cache [SETS][WAYS];
  bit [PLRU_BITS-1:0] PLRU [SETS-1:0];
  string file_name;
  int file;
  int id;
  bit [ADDRESS_WIDTH-1:0] Address;
  bit [INDEX_BITS+OFFSET_BITS-1:OFFSET_BITS] input_index;
  bit [ADDRESS_WIDTH-1:INDEX_BITS+OFFSET_BITS] input_tag;
  int status;
  string default_file_name = "rims.din";
  string line;
  int cache_reads;
  int cache_writes;
  int cache_hits;
  int cache_misses;
  int cache_hit_ratio;
  int SnoopResult;
  int mode;

  function string MESI_to_string(bit [1:0] MESI);
    case (MESI)
        I: return "I";  
        E: return "E";
        M: return "M";  
        S: return "S";
        default: return "Unknown";
    endcase
   endfunction

    function string BusOP_to_string(int BusOperation);
    case (BusOperation)
        READ      : return "READ";  
        WRITE     : return "WRITE";
        RWIM      : return "RWIM";  
        INVALIDATE: return "INVALIDATE";
        default    : return "Unknown";
    endcase
   endfunction

 
    function string Snoop_to_string(int SnoopResult);
    case (SnoopResult)
        HIT       : return "HIT";  
        NOHIT     : return "NOHIT";
        HITM      : return "HITM";  
        default    : return "Unknown";
    endcase
   endfunction

    function string CacheMessage_to_string(int Message);
    case (Message)
        GETLINE            : return "GETLINE";  
        INVALIDATELINE     : return "INVALIDATELINE";
        SENDLINE           : return "SENDLINE";
        EVICTLINE          : return "EVICTLINE";
         default            : return "Unknown";
    endcase
   endfunction  

// // typedef enum [1:0]{READ, WRITE, INVALIDATE, RWIM} Bus_Ops;
// // typedef enum [1:0]{NOHIT, HIT, HITM} Snoop_Results;
// // typedef enum [1:0]{GETLINE, SENDLINE, INVALIDATELINE, EVICTLINE} L2_to_L1;

endpackage