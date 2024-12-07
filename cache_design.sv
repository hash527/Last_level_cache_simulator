import cache_define ::*;

module cache_design;

cache_entry_t cache [SETS][WAYS];

bit [$clog2(WAYS)-1:0] ways_seq[WAYS-1:0];
initial begin
    ways_seq[0]  = 4'b0000;
    ways_seq[1]  = 4'b0001;
    ways_seq[2]  = 4'b0010;
    ways_seq[3]  = 4'b0011;
    ways_seq[4]  = 4'b0100;
    ways_seq[5]  = 4'b0101;
    ways_seq[6]  = 4'b0110;
    ways_seq[7]  = 4'b0111;
    ways_seq[8]  = 4'b1000;
    ways_seq[9]  = 4'b1001;
    ways_seq[10] = 4'b1010;
    ways_seq[11] = 4'b1011;
    ways_seq[12] = 4'b1100;
    ways_seq[13] = 4'b1101;
    ways_seq[14] = 4'b1110;
    ways_seq[15] = 4'b1111;
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
int total_commands;
int cache_reads;
int cache_writes;
int cache_hits;
int cache_misses;
int cache_hit_ratio;
int SnoopResult;
int mode;
 
 
initial begin

    if ( $value$plusargs ("MODE=%d", mode)) begin
        if(mode==1)
             $display("RUNNING IN NORMAL MODE");
        else
           $display("RUNNING IN SILENT MODE");
    end
    else begin
       $display("No Mode Specified. Using Default Mode as SILENT MODE");
       mode=0;
    end
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

    // Open the file
    file = $fopen(file_name, "r");
    if (file == 0) begin
      $fatal("Error: Could not open file '%s'", file_name);
    end

    // Read file line by line
    while (!$feof(file)) begin
      status = $fscanf(file, "%d", id);
      if (status != 1) begin
        break; // Exit if there's an error reading
      end
      if (id < 8) begin
        status = $fscanf(file, "%h", Address);
        if (status != 1) begin
          $display("Error reading address from file. Exiting loop.");
          break;
        end
      end
      total_commands+=1;
      case (id)
        0, 2    : ProcessorRead(Address);
        1       : ProcessorWrite(Address);        
        3       : SnoopedRead(Address);
        4       : SnoopedWrite(Address);
        5       : SnoopedRdx(Address);
        6       : Snooped_Invalidate(Address);
        8       : ResetCache();
        9       : PrintValidCacheLines();
        default : $display("Not valid operation");
      endcase
    end

    $display("Number of Commands = %0d",total_commands);

    $display("CacheReads = %0d",cache_reads);

    $display("CacheWrites = %0d", cache_writes);
   
    $display("CacheHits=%0d",cache_hits);
   
    $display("CacheMisses=%0d",cache_misses);
   
    $display("Hit Ratio:%.2f",real'(cache_hits)/(real'(cache_reads)+real'(cache_writes))); // handle 0/0 Nan condition
    $fclose(file);
end



////////UPDATING LRU//////////
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
 
 
  ///////EVICTION DUE TO COLLISION MISS///////  
function automatic bit [3:0] victim_cache(ref bit[14:0]PLRU);
  int index=0;
  bit [3:0]victim;
  for (int i = 3; i >=0; i--) begin
    if (PLRU[index] == 0)
      begin
      PLRU[index] = 1;
      victim[i]=1;
      index = 2 * index + 2;        
      end
    else
      begin
      PLRU[index] = 0;
      victim[i]=0;
      index = 2 * index + 1;        
      end
  end
  return victim;
endfunction
 



/************************************ BUS OPERATIONS *****************************************/

function automatic void BusOperation(int BusOp, bit[31:0] Address, int SnoopResult);
  if(mode==NORMAL_MODE)
  $display("BusOp: %s, Address: %h, Snoop Result: %s\n",BusOP_to_string(BusOp),Address,Snoop_to_string(SnoopResult));
endfunction
 

/************************************ PUT SNOOP RESULTS **************************************/

function automatic void PutSnoopResult(bit [31:0] Address, int SnoopResult);
  if(mode==NORMAL_MODE)
    $display("SnoopResult: Address %h, SnoopResult: %0d\n", Address, Snoop_to_string(SnoopResult));
endfunction
 

  /************************************ MESSAGE TO HIGHER LEVEL CACHE **************************/


  function automatic void MessageToCache(int Message, bit [31:0] Address);
   if(mode==NORMAL_MODE)
    $display("Message to Higher Level Cache: %s", CacheMessage_to_string(Message));
  endfunction
 
 
  /************************************ GET SNOOP RESULTS ***************************************/

  function automatic int GetSnoopResult(bit[31:0] Address);
    if(Address[1:0]==2'b00)
        return HIT;
    else if(Address[1:0]==2'b01)
        return HITM;
    else
        return NOHIT;
  endfunction
 


  /*********************************************************************************************/
  /************************************PROCESSOR READ OPERATION ********************************/
  /*********************************************************************************************/
 
 
  function automatic void ProcessorRead(bit [31:0] Address);
    bit bool_a;
    int valid_count;
    input_index = Address[19:6];
    input_tag = Address [31:20];
    cache_reads+=1;

    /////////CHECK FOR HIT/////////////

    if(mode==NORMAL_MODE)
       $display("OPERATION: PROCESSOR READ");
    for(int j=0; j<WAYS; j=j+1)
         begin
                 if(cache[input_index][j].MESI!=I)
                  begin
                      valid_count+=1;
                         if(cache[input_index][j].tag==input_tag)
                              begin
                                cache_hits+=1;
                                if(mode==NORMAL_MODE) begin
                                   $display("HIT/MISS: CACHE HIT");
                                   $display("MESI State:%b, TAG:%h",MESI_to_string(cache[input_index][j].MESI),cache[input_index][j].tag);
                                end
                                MessageToCache(SENDLINE,Address);
                                Update_PLRU(PLRU[input_index],ways_seq[j]);
                                bool_a=1;
                                break;
                              end
                  end
         end

      //////////CHECK FOR VACANCY//////////
      if(bool_a==0 && valid_count!=WAYS)
        begin
          cache_misses+=1;
          if(mode==NORMAL_MODE)
               $display("HIT/MISS: CACHE MISS");
          for(int i=0;i<WAYS;i++) begin

            if(cache [input_index][i].MESI==I)
              begin

                SnoopResult=GetSnoopResult(Address);
                BusOperation(READ,Address,SnoopResult);

                if(SnoopResult==NOHIT)
                  cache [input_index][i].MESI=E;
                else
                  cache [input_index][i].MESI=E;
                cache [input_index][i].tag=input_tag;
                if(mode==NORMAL_MODE)
                    $display("MESI State:%b, TAG:%h",MESI_to_string(cache[input_index][i].MESI),cache[input_index][i].tag);
                Update_PLRU(PLRU[input_index],ways_seq[i]);

                MessageToCache(SENDLINE,Address);
                break;
              end        
          end          
        end
   

      /////////COLLISION MISS//////////
      if(bool_a==0 && valid_count==WAYS)
        begin
          bit [3:0]WayToEvict;
          cache_misses+=1;
          if(mode==NORMAL_MODE)
              $display("HIT/MISS: CACHE MISS");
          WayToEvict=victim_cache(PLRU[input_index]);
          MessageToCache(EVICTLINE,Address);
          SnoopResult=GetSnoopResult(Address);
          BusOperation(READ,Address,SnoopResult);

          if(SnoopResult!=NOHIT)
            cache [input_index][WayToEvict].MESI=E;
          else
            cache [input_index][WayToEvict].MESI=E;
          cache [input_index][WayToEvict].tag=input_tag;
          if(mode==NORMAL_MODE)
             $display("MESI State:%b, TAG:%h",MESI_to_string(cache[input_index][WayToEvict].MESI),cache[input_index][WayToEvict].tag);

          MessageToCache(SENDLINE,Address);
        end
      if(mode==NORMAL_MODE) begin
         $display("++++++++++++++++++++++++++++++++++++++++++++++++++");
         $display(" ");
      end
    endfunction



  /*********************************************************************************************/
  /************************************PROCESSOR WRITE OPERATION *******************************/
  /*********************************************************************************************/


   function automatic void ProcessorWrite(bit [31:0] Address);
    bit flag;
    int valid_count;
    input_index = Address[19:6];
    input_tag = Address [31:20];
    cache_writes+=1;

      /////////CHECK FOR HIT///////////
      if(mode==NORMAL_MODE)
          $display("OPERATION: PROCESSOR WRITE");
      for(int j=0; j<WAYS; j=j+1)
          begin
              if(cache[input_index][j].MESI!=I)
                  begin
                      valid_count+=1;
                      if(cache[input_index][j].tag==input_tag)
                      begin

                      cache_hits+=1;
                      if(mode==NORMAL_MODE)
                         $display("HIT/MISS: CACHE HIT");
                      MessageToCache(SENDLINE,Address);

                      if(cache[input_index][j].MESI==E)
                          BusOperation(INVALIDATE,Address,SnoopResult);

                      cache[input_index][j].MESI= E;
                      if(mode==NORMAL_MODE)
                         $display("MESI State:%b, TAG:%h",MESI_to_string(cache[input_index][j].MESI),cache[input_index][j].tag);                        
                      Update_PLRU(PLRU[input_index],ways_seq[j]);
                      flag=1;
                      break;
                      end
                  end
          end
 

      //////////CHECK FOR VACANCY///////////

      if(flag==0 && valid_count!=WAYS)
          begin
              cache_misses+=1;
              if(mode==NORMAL_MODE)
                 $display("HIT/MISS: CACHE MISS");
              for(int i=0;i<WAYS;i++) begin
                  if(cache [input_index][i].MESI==I)
                      begin
                          BusOperation(RWIM,Address,SnoopResult);
                          cache [input_index][i].MESI=E;
                          cache [input_index][i].tag=input_tag;
                          if(mode==NORMAL_MODE)
                                 $display("MESI State:%b, TAG:%h",MESI_to_string(cache[input_index][i].MESI),cache[input_index][i].tag);
                          Update_PLRU(PLRU[input_index],ways_seq[i]);

                          MessageToCache(SENDLINE,Address);
                          break;
                      end
              end

      end


       /////////COLLISION MISS//////////

      if(flag==0 && valid_count==WAYS)
        begin
          bit [3:0]WayToEvict;
          cache_misses+=1;
          if(mode==NORMAL_MODE)
              $display("HIT/MISS: CACHE MISS");
          WayToEvict=victim_cache(PLRU[input_index]);
          MessageToCache(EVICTLINE,Address);
          BusOperation(RWIM,Address,SnoopResult);
          cache [input_index][WayToEvict].MESI=E;
          cache [input_index][WayToEvict].tag=input_tag;
          if(mode==NORMAL_MODE)
              $display("MESI State:%b, TAG:%h",MESI_to_string(cache[input_index][WayToEvict].MESI),cache[input_index][WayToEvict].tag);

          MessageToCache(SENDLINE,Address);
        end  
        if(mode==NORMAL_MODE)  begin      
          $display("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
          $display(" ");
        end
   endfunction


  /*********************************************************************************************/
  /************************************SNOOPED READ ********************************************/
  /*********************************************************************************************/

  function automatic void SnoopedRead(bit [31:0] Address);
     int valid_count=0;
     bit flag=0;
     input_index = Address[19:6];
     input_tag = Address [31:20];
     if (mode==NORMAL_MODE)
           $display("Operation: SNOOPED READ");
     for(int i=0;i<16;i++)
        begin

          valid_count+=1;
          if (cache[input_index][i].MESI!=I && cache[input_index][i].tag==input_tag)
             begin
               if (cache[input_index][i].MESI==E || cache[input_index][i].MESI==E)
                   PutSnoopResult(Address, HIT);
               else
                   PutSnoopResult(Address, HITM);
               cache[input_index][i].MESI=E;
               if(mode==NORMAL_MODE)
                      $display("MESI:%b", MESI_to_string(cache[input_index][i].MESI));
               flag=1;
               break;
             end
        end
     if(flag==0 && valid_count==16)
         PutSnoopResult(Address,NOHIT);
     if(mode==NORMAL_MODE)
        $display("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
  endfunction

   /**************************************SNOOPED WRITE****************************************/

   function automatic void SnoopedWrite(bit [31:0]Address);
 
   endfunction


  /*********************************************************************************************/
  /************************************SNOOPED READ WITH INTENT TO MODIFY***********************/
  /*********************************************************************************************/

  function automatic void SnoopedRdx(bit [31:0]Address);
      bit flag=0;
      int valid_count=0;
      input_index = Address[19:6];
      input_tag = Address [31:20];
      if (mode==NORMAL_MODE)
           $display("Operation: SNOOPED READ WITH INTENT TO MODIFY");
      for(int i=0;i<16;i++)
        begin
          if (cache[input_index][i].MESI!=I && cache[input_index][i].tag==input_tag)
           begin

             valid_count+=1;

             if (cache[input_index][i].MESI==E || cache[input_index][i].MESI==E)
                PutSnoopResult(Address, HIT);

             else

               begin
                PutSnoopResult(Address, HITM);
                MessageToCache(GETLINE, Address);
               end

             MessageToCache(INVALIDATELINE, Address);
             cache[input_index][i].MESI=I;
             if(mode==NORMAL_MODE)
                     $display("MESI:%b", MESI_to_string(cache[input_index][i].MESI));
             flag=1;
             break;

           end
         end
      if(flag==0 && valid_count==16)
        begin
         PutSnoopResult(Address,NOHIT);
        end
      if(mode==NORMAL_MODE)
         $display("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
  endfunction


  /*********************************************************************************************/
  /************************************SNOOPED INVALIDATE OPERATION*****************************/
  /*********************************************************************************************/
 
  function automatic void Snooped_Invalidate(bit [31:0]Address);
      int valid_count=0;
      bit flag=0;
      input_index = Address[19:6];
      input_tag = Address [31:20];
      if (mode==NORMAL_MODE)
          $display("Operation: SNOOPED INVALIDATE");
      for(int i=0;i<16;i++)
        begin
          valid_count+=1;
          if (cache[input_index][i].MESI==E && cache[input_index][i].tag==input_tag)
           begin
             PutSnoopResult(Address,HIT);
             MessageToCache(INVALIDATELINE, Address);
             cache[input_index][i].MESI=I;
             if(mode==NORMAL_MODE)
                    $display("MESI:%b", MESI_to_string(cache[input_index][i].MESI));
             break;
           end
        end
      if(flag==0 && valid_count==16)
        begin
         PutSnoopResult(Address,NOHIT);
        end
      if(mode==NORMAL_MODE)
          $display("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
  endfunction
   

     /*************************RESET CACHE**************************/
      function automatic void ResetCache();
          for(int i=0;i<SETS;i++) begin
                 for(int j=0;j<WAYS;j++) begin
                      cache[i][j].tag =12'b0;
                      cache[i][j].MESI= I;
                 end
          end

      endfunction


      function automatic void PrintValidCacheLines();
          bit valid;
          $display("Valid Lines in LLC:");
          $display("");
          $display("MESI   |    TAG    |            SET     |        WAY    |        PLRU      |");
          for(int i=0;i<SETS;i++) begin
                 for(int j=0;j<WAYS;j++) begin          
                       if (cache[i][j].MESI!=I)begin
                                 valid=1;
                                 $display("----------------------------------------------------------------------------");
                                 $display(" %s     |    %h    |    %d     |%d    |  %b |",MESI_to_string(cache[i][j].MESI), cache[i][j].tag,i,j,PLRU[i]);
                       end
                           
                 end
          end
          if(valid==0)
              $display("No Valid Lines in LLC");

      endfunction
       


    function string MESI_to_string(bit [1:0] MESI);
    case (MESI)
        I: return "I";  
        E: return "E";
        E: return "M";  
        E: return "S";
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

 
endmodule
