import cache_define::*;
import PrRd::*;
import PrWr::*;
import SnoopRd::*;
import SnoopRdx::*;
import SnoopInvalidate::*;
import SnoopWrite::*;
import ResetCache::*;
import PrintContents::*;
import UtilFunctions::*;
module cache_design;

initial begin

    if ($value$plusargs ("MODE=%d", mode)) begin
        if (mode == 1)
             $display("RUNNING IN NORMAL MODE");
        else
           $display("RUNNING IN SILENT MODE");
    end else begin
       $display("No Mode Specified. Using Default Mode as SILENT MODE");
       mode = 0;
    end

    if ($value$plusargs("file_name=%s", file_name)) begin
      `ifdef DEBUG
      $display("Using specified file: %s", file_name);
      `endif
    end else begin
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
      status = $fscanf(file, "%d %h", id, Address);
      case (id)
        0, 2    : ProcessorRead(input_index,input_tag);
        1       : ProcessorWrite(input_index,input_tag);        
        3       : SnoopedRead(input_index,input_tag);
        4       : SnoopedWrite(input_index,input_tag);
        5       : SnoopedRdx(input_index,input_tag);
        6       : Snooped_Invalidate(input_index,input_tag);
        8       : ResetCache();
        9       : PrintValidCacheLines();
        default : $display("Not valid operation");
      endcase
    end

    $display("CacheReads = %0d",cache_reads);

    $display("CacheWrites = %0d", cache_writes);
   
    $display("CacheHits = %0d",cache_hits);
   
    $display("CacheMisses = %0d",cache_misses);
   
    $display("Hit Ratio: %.32f", real'(cache_hits) / (real'(cache_reads) + real'(cache_writes)));
    $fclose(file);
end
 
endmodule