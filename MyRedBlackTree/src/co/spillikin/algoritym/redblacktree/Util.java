package co.spillikin.algoritym.redblacktree;

import java.util.ArrayList;
import java.util.List;

/**
 * Static utility package to build our red black tree.
 * 
 * @author chris
 *
 */
public class Util {

    /**
     *        parent
     *       /    \
     *     node
     * NULL if parent is NULL.
     */
    public static Node parent(Node n) {
        return n.parent;
    }

    /**
     *        grandparent
     *          /
     *        parent
     *       /    \
     *     node
     * or NULL if parent or grandparent is NULL.
     */

    public static Node grandparent(Node n) {
        Node parent = parent(n);
        // If no parent, then no grandparent
        if (parent == null) {
            return null;
        }
        return parent.parent;
    }

    /**
     *        parent                  parent
     *       /    \         or        /    \
     *     node  sibling         sibling   node
     * or NULL if no parent or sibling is NULL.
     */
    public static Node sibling(Node n) {
        Node parent = parent(n);
        // If no parent, then no sbling
        if (parent == null) {
            return null;
        }
        if (n == parent.left) {
            return parent.right;
        }
        return parent.left;
    }

    /**
     *        grand                  grand
     *       /    \         or        /    \
     *     parent  uncle         uncle   parent
     *      /                                   \
     *    node                                 node
     * or NULL if no parent or sibling is NULL.
     */

    public static Node uncle(Node n) {
        Node parent = parent(n);
        // If no parent, then no grandparent
        if (parent == null) {
            return null;
        }
        Node grand = grandparent(n);
        // If no no grandparent then no sibling of parent
        if (grand == null) {
            return null;
        }
        // The sibling of your parent is your uncle.
        return sibling(parent);
    }

    /**
     * n and nr swap places if n.right is not a leaf.
     *       p          p                 p
     *       |          |                 |
     *       n          n        nr       nr
     *     /  \       /   \      /       /
     *        nr          nrl    n      n
     *       /                   \       \
     *     nrl                    nrl    nrl
     *            
     */
    public static void rotateLeft(Node n) {
        // We are a leaf, exit
        if (n == null) {
            return;
        }
        Node nr = n.right;
        // If null, then a leaf.  A leaf can not become an internal node.
        if (nr == null) {
            return;
        }
        n.right = nr.left; // nrl
        nr.left = n;
        nr.parent = n.parent;
        n.parent = nr;

    }

    /**
     * n and nl swap places if n.left is not a leaf.
     * 
     *       p          p                 p
     *       |          |                 |
     *       n          n        nl       nl
     *     /  \       /   \       \        \
     *   nl          nlr           n        n
     *     \                      /        /
     *      nlr                  nlr      nlr
     *            
     */

    public static void rotateRight(Node n) {
        // We are a leaf, exit.
        if (n == null) {
            return;
        }
        Node nl = n.left;
        // If null, then a leaf.  A leaf can not become an internal node.
        if (nl == null) {
            return;
        }
        n.left = nl.right; // nlr
        nl.right = n;
        nl.parent = n.parent;
        n.parent = nl;
    }

    /**
     * Insertion begins by adding the node in a very similar manner 
     * as a standard binary search tree insertion and by coloring it red. 
     * 
     * The big difference is that in the binary search tree a new node is 
     * added as a leaf, whereas leaves contain no information in the red–black 
     * tree, so instead the new node replaces an existing leaf and then has 
     * two black leaves of its own added.
     * 
     * We're just going to assume that NULL is a black leaf.
     * 
     * @param root
     * @param n
     */
    public static Node insert(Node root, Node n) {

        // First, do an old fashioned insert 
        insert_recurse(root, n);
        // We may rotate in a new root during rebalancing
        return insert_repair_tree(root, n);
    }

    /**
     * Straightforward recursive insert. New nodes leaves should be
     * set to NULL.  and some value should be set.  
     * The new node must be RED.
     * 
     * We only replace a leaf with the new node and thus 
     * we possibly break the tree rules.
     * 
     * @param root
     * @param n
     */
    public static void insert_recurse(Node root, Node n) {
        print("insert_recurse", "root " + root + " node " + n);
        if (root != null && n.data < root.data) {
            if (root.left != null) {
                insert_recurse(root.left, n);
                return;
            } else {
                root.left = n;
                n.parent = root;
            }
        } else if (root != null) {
            if (root.right != null) {
                insert_recurse(root.right, n);
                return;
            } else {
                root.right = n;
                n.parent = root;
            }
        }
    }

    /**
     * This is a recursive call.
     * Repair the tree until the following properties are again true...
     * 
     * Property 1 (every node is either red or black) and Property 3 
     *   (all leaves are black) always holds.
     * Property 2 (the root is black) is checked and corrected with case 1.
     * Property 4 (red nodes have only black children) is threatened only by adding 
     *   a red node, repainting a node from black to red, or a rotation.
     * Property 5 (all paths from any given node to its leaves have the same number 
     *   of black nodes) is threatened only by adding a black node, repainting a 
     *   node, or a rotation.
     *   
     *   In the event root changes, we pass it in and back out again.
     */
    public static Node insert_repair_tree(Node root, Node n) {

        // Case 1:
        // N is the root node, i.e., first node of red–black tree
        // indicated by N.parent being NULL.
        if (parent(n) == null) {
            // Turn root BLACK and do nothing else. Simply changing the color 
            // will violate no other rules.
            insert_case1(n);
            // root may have changed, pass back out n as we know it it root.
            return n;

            // Case 2: N's parent (P) is black
        } else if (parent(n).color == Node.NodeColor.BLACK) {
            // As N can have a black parent, we do nothing.
            insert_case2(n);

            // Case 3: P is red (so it can't be the root of the tree) 
            // and N's uncle (U) is red
            // This is the only case that recurses.
        } else if (uncle(n) != null && (uncle(n).color == Node.NodeColor.RED)) {
            // Change colors 
            insert_case3(n);
            //  the grandparent G may now violate Property 2 (The root is black) 
            // if it is the root or Property 4 (Both children of every red node are black) 
            // if it has a red parent. 
            // To fix this, the tree's red-black repair procedure is rerun on G.

            return insert_repair_tree(root, grandparent(n));

            // Case 4: P is red and U is black
            // This is the only case that moves the nodes in the tree.
        } else {
            insert_case4(n);
        }
        // Unless case 1 took place, the root hasn't changed.
        return root;
    }

    /**
     * Case 1: The current node N is at the root of the tree. In this case, 
     * it is repainted black to satisfy property 2 (the root is black). Since 
     * this adds one black node to every path at once, property 5 (all paths 
     * from any given node to its leaf nodes contain the same number of black 
     * nodes) is not violated.
     * 
     */
    public static void insert_case1(Node n) {
        print("insert_case1", "We have a new root, set to BLACK.");
        n.color = Node.NodeColor.BLACK;
    }

    /**
      * Case 2: The current node's parent P is black, so property 4 
      * (both children of every red node are black) is not invalidated. 
      * In this case, the tree is still valid. Property 5 (all paths 
      * from any given node to its leaf nodes contain the same number 
      * of black nodes) is not threatened, because the current node N has 
      * two black leaf children, but because N is red, the paths through 
      * each of its children have the same number of black nodes as the 
      * path through the leaf it replaced, which was black, and so this 
      * property remains satisfied.
    */
    public static void insert_case2(Node n) {
        print("insert_case2", "Does nothing, exit.");
        return;
    }

    /**
     * Case 3:
     * If both the parent P and the uncle U are red, then both of them can be 
     * repainted black and the grandparent G becomes red to maintain property 
     * 5 (all paths from any given node to its leaf nodes contain the same number 
     * of black nodes). Since any path through the parent or uncle must pass 
     * through the grandparent, the number of black nodes on these paths has not 
     * changed. However, the grandparent G may now violate Property 2 
     * (The root is black) if it is the root or Property 4 (Both children of every 
     * red node are black) if it has a red parent. To fix this, the tree's 
     * red-black repair procedure is rerun on G.
    
     * @param n
     */
    public static void insert_case3(Node n) {
        print("insert_case3", "parent(n) = BLACK, uncle(n) = BLACK, grand(n) = RED");
        print("insert_case3", "calling insert_repari_tree(grandparent(n) )");
        parent(n).color = Node.NodeColor.BLACK;
        uncle(n).color = Node.NodeColor.BLACK;
        grandparent(n).color = Node.NodeColor.RED;
        // then insert_repari_tree(grandparent of n)
        // We do this outside to pass thru root. Just makes it a little neater.
    }

    /**
     * 
     * Diagram of case 4
     * Case 4, step 1: The parent P is red but the uncle U is black. 
     * The ultimate goal will be to rotate the parent node into the grandparent 
     * position, but this will not work if the current node is on the "inside" of 
     * the subtree under G (i.e., if N is the left child of the right child of the 
     * grandparent or the right child of the left child of the grandparent). 
     * In this case, a left rotation on P that switches the roles of the current 
     * node N and its parent P can be performed. The rotation causes some paths 
     * (those in the sub-tree labelled "1") to pass through the node N where they 
     * did not before. It also causes some paths (those in the sub-tree labelled "3") 
     * not to pass through the node P where they did before. However, both of 
     * these nodes are red, so property 5 (all paths from any given node to its 
     * leaf nodes contain the same number of black nodes) is not violated by 
     * the rotation. After this step has been completed, property 4 (both children 
     * of every red node are black) is still violated, but now we can resolve this 
     * by continuing to step 2.
     * 
     */
    public static void insert_case4(Node n) {
        Node p = parent(n);
        Node g = grandparent(n);
        if (g != null && g.left != null && n == g.left.right) {
            print("insert_case4", "rotateLeft(p) n = n.left;");
            rotateLeft(p);
            n = n.left;
            insert_case4step2(n);
        } else if (g != null && g.right != null && n == g.right.left) {
            print("insert_case4", "rotateRight(p) n = n.right;");
            rotateRight(p);
            n = n.right;
            insert_case4step2(n);
        } else {
            print("insert_case4", "g null" + n);
        }
        
    }

    /**
     * Case 4, step 2: The current node N is now certain to be on the "outside" 
     * of the subtree under G (left of left child or right of right child). In this 
     * case, a right rotation on G is performed; the result is a tree where the former 
     * parent P is now the parent of both the current node N and the former grandparent 
     * G. G is known to be black, since its former child P could not have been red without 
     * violating property 4. Once the colors of P and G are switched, the resulting tree 
     * satisfies property 4 (both children of every red node are black). Property 5 (all 
     * paths from any given node to its leaf nodes contain the same number of black nodes) 
     * also remains satisfied, since all paths that went through any of these three nodes 
     * went through G before, and now they all go through P.
     * 
     */
    public static void insert_case4step2(Node n) {
        Node p = parent(n);
        // g may be null, p will not be.
        Node g = grandparent(n);
        if (n == p.left) {
            print("insert_case4step2", "rotateRight(g);");
            rotateRight(g);
        } else {
            print("insert_case4step2", "rotateLeft(g);");
            rotateLeft(g);
        }
        print("insert_case4step2", "set p.color = BLACK, g.color = RED");
        p.color = Node.NodeColor.BLACK;
        if (g != null) {
            g.color = Node.NodeColor.RED;
        }
    }

    public static void print(String place, String message) {
        System.out.println("[" + place + "] " + message);
    }

    /**
     * Traversals
     * 
     * Depth First Traversals: 
     * (a) Inorder (Left, Root, Right) : 4 2 5 1 3 
     * (b) Preorder (Root, Left, Right) : 1 2 4 5 3 
     * (c) Postorder (Left, Right, Root) : 4 5 2 3 1.
     * 
     */

    public static void printPreorder(Node n) {
        List<Node> s = new ArrayList<>();
        s.add(n);
        printPreorderRecurse(s);
    }

    public static void printPreorderRecurse(List<Node> nodeList) {
        List<Node> nextList = new ArrayList<>();

        int spaces = 50 - (nodeList.size() * Node.NODE_TEXT_SIZE) / 2;
        for (int i = 0; i < spaces; i++) {
            System.out.print(" ");
        }

        for (Node n : nodeList) {
            if (n == null) {
                System.out.print(Node.show(null));
                // Must fill out complete next level in order to preserve spaceing.
                nextList.add(null);
                nextList.add(null);
            } else {
                System.out.print(n);
                nextList.add(n.left);
                nextList.add(n.right);
            }
        }
        System.out.println();
        boolean nextLevelExists = false;
        for (Node n2 : nextList) {
            if (n2 != null) {
                nextLevelExists = true;
            }
        }
        if (nextLevelExists) {
            printPreorderRecurse(nextList);
        }
    }
}
