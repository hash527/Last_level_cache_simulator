module cache_mem;

    `define INIT_STATE
    localparam int ROWS = 2**14;          
    localparam int COLS = 16;          
    localparam int INDEX_BITS = 14;
    localparam int PLRU_BITS = 15;

    // Define the struct for cache entries
    typedef struct packed {
        bit valid;  
        bit dirty;              
        bit [INDEX_BITS-1:0] tag;
        bit [PLRU_BITS-1:0] plru;
    } cache_entry_t;

    // Define a 2D static array for the structured cache
    cache_entry_t cache[ROWS][COLS];

    // Define an associative array for dynamic mapping (e.g., key-based cache)
    cache_entry_t assoc_cache[string];

    // Utility function to generate a unique key for the associative array
    function string generate_key(int row, int col);
        return $sformatf("row%0d_col%0d", row, col);
    endfunction

    // Initialize both the static array and associative array
    initial begin
        for (int i = 0; i < ROWS; i++) begin
            for (int j = 0; j < COLS; j++) begin
                // Initialize static array
                cache[i][j].valid = '0;
                cache[i][j].dirty = '0;
                cache[i][j].tag   = '0;
                cache[i][j].plru  = '0;

                // Initialize associative array with the same entries
                string key = generate_key(i, j);
                assoc_cache[key] = '{valid: '0, dirty: '0, tag: '0, plru: '0};
            end
        end
    end

    // Display entries from both static and associative arrays during simulation
    initial begin
        `ifdef INIT_STATE
        // Display static array entries
        for (int i = 0; i < ROWS; i++) begin
            for (int j = 0; j < COLS; j++) begin
                $display("Static Cache: cache[%0d][%0d]: valid=%b, dirty=%b, tag=%b, plru=%b",
                         i, j, cache[i][j].valid, cache[i][j].dirty, cache[i][j].tag, cache[i][j].plru);
            end
        end

        // Display associative array entries
        foreach (assoc_cache[key]) begin
            $display("Assoc Cache: %s: valid=%b, dirty=%b, tag=%b, plru=%b",
                     key, assoc_cache[key].valid, assoc_cache[key].dirty, assoc_cache[key].tag, assoc_cache[key].plru);
        end
        `endif
    end
endmodule
