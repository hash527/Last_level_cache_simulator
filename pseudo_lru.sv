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
  function automatic Node traverse_and_evict(Node root, ref int array[4], ref int count);
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

  function automatic Node inorder_manipulate(int x[], ref int i, Node root);
    if (root != null) begin
      root.left = inorder_manipulate(x, i, root.left);
      root.value = x[i];
      i += 1;
      root.right = inorder_manipulate(x, i, root.right);
    end
    return root;
  endfunction

  function automatic Node manipulate(int A[], int k, Node root);
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
[No Name][+] [unix] (15:59 31/12/1969)                                                                                                                                                                     1,1 Top
-- INSERT --

