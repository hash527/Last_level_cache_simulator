vlib work
vlog -lint cache_define.sv PrRd.sv PrWr.sv SnoopRd.sv SnoopRdx.sv SnoopInvalidate.sv cache_design.sv SnoopWrite.sv ResetCache.sv PrintContents.sv UpdatePlru.sv EvictPlru.sv UtilFunctions.sv +define+DEBUG
vsim cache_design +MODE=0 +file_name=cc1.din
run -all
