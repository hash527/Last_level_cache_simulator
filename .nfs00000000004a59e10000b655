class Node;
  int value;
  Node left, right;

  function new(int value = 0);
    this.value = value;
    this.left = null;
    this.right = null;
  endfunction
endclass

class BT;
  function automatic Node traverse_and_evict(Node root, ref bit [3:0]array, ref int count);
    if (root != null && count < $size(array)) begin
      if (root.value == 0) begin
        array[count] = 1;
        count += 1;
        root.right = traverse_and_evict(root.right, array, count);
      end else begin
        array[count] = 0;
        count += 1;
        root.left = traverse_and_evict(root.left, array, count);
      end
    end
    return root; 
  endfunction

  function automatic Node inorder_manipulate(bit[14:0]x, ref int i, Node root);
    if (root != null) begin
      root.left = inorder_manipulate(x, i, root.left);
      root.value = x[i];  
      i += 1;
      root.right = inorder_manipulate(x, i, root.right);
    end
    return root;
  endfunction

  function automatic Node manipulate(bit [3:0]A, int k, Node root);
    if (root == null) begin
      return root;
    end else begin
      root.value = A[k];
      if (A[k] == 0) begin
        root.left = manipulate(A, k + 1, root.left);
      end else begin
        root.right = manipulate(A, k + 1, root.right);
      end
    end
    return root;
  endfunction

  function void inorder(Node root);
    if (root != null) begin  
      inorder(root.left);         
      $display(" %0d", root.value);  
      inorder(root.right);  
    end 
  endfunction
endclass


module cache_design;
  
    `define INIT_STATE
    localparam int SETS = 2**14;          
    localparam int WAYS = 16;          
    localparam int INDEX_BITS = 14;
    localparam int PLRU_BITS = 15;
 
    typedef struct packed {
        bit valid;  
        bit dirty;              
        bit [INDEX_BITS-1:0] tag;
    } cache_entry_t;
  
  cache_entry_t cache [SETS][WAYS];
  
  bit [3:0] ways_seq [PLRU_BITS:0];
  
  bit [14:0] num_lrusets [SETS-1:0];
  
  bit evicted_way [3:0];
  
  initial begin
    Node root;
    BT bt = new();

    ways_seq[0]=4'b0000;
    for(int i=1;i<WAYS;i++)begin
      ways_seq[i]=ways_seq[i-1]+1;
    end

    root = new(0);
    root.left = new(0);
    root.right = new(0);
    root.left.left = new(0);
    root.left.right = new(0);
    root.right.left = new(0);
    root.right.right = new(0);
    root.left.left.left = new(0);
    root.left.left.right = new(0);
    root.left.right.left = new(0);
    root.left.right.right = new(0);
    root.right.left.left = new(0);
    root.right.left.right = new(0);
    root.right.right.left = new(0);
    root.right.right.right = new(0);
  
  end
endmodule
