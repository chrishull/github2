package co.spillikin.algoritym.redblacktree;

/**
 * red-black tree is a binary search tree which has the following red-black 
 * properties:
 *
 * Every node is either red or black.
 * Every leaf (NULL) is black.
 * If a node is red, then both its children are black.
 * Every simple path from a node to a descendant leaf contains the same number 
 * of black nodes. 
 * 
 *                      11b
 *                      
 *             2r                     14b
 *             
 *       1b        7b             b        15r
 *       
 *      b   b    5r     8r                b   b
 *      
 *              b  b  b  b  
 * 
 * Basic red-black tree with the sentinel nodes added. 
 * Implementations of the red-black tree algorithms will 
 * usually include the sentinel nodes as a convenient means of flagging 
 * that you have reached a leaf node.
 * 
 * 
 * 
 * Each node is either red or black.
 * The root is black. This rule is sometimes omitted. Since the root can 
 * always be changed from red to black, but not necessarily vice versa, this 
 * rule has little effect on analysis.
 * All leaves (NIL) are black.
 * If a node is red, then both its children are black.
 * Every path from a given node to any of its descendant NIL nodes contains 
 * the same number of black nodes. 
 * 
 * Some definitions: the number of black nodes 
 * from the root to a node is the node's black depth; the uniform number of black 
 * nodes in all paths from root to the leaves is called the black-height of the 
 * red–black tree.
 * 
 * The goal 
 * These constraints enforce a critical property of red–black trees: 
 * the path from the root to the farthest leaf is no more than twice as 
 * long as the path from the root to the nearest leaf. 
 * 
 * 
 * 
 * @author chris
 *
 */

public class Main {

    public static void main(String[] args) {
        // TODO Auto-generated method stub

        Util.print("main", "start with three nodes");
        Node root = new Node(42);
        Util.insert_recurse(root, new Node(10));
        Util.insert_recurse(root, new Node(80));
        Util.print("main", "show tree");
        Util.printPreorder(root);

        Util.print("main", "make it unbalanced, do not correct as we go.");
        Util.insert_recurse(root, new Node(85));
        Util.insert_recurse(root, new Node(90));
        Util.insert_recurse(root, new Node(89));
        Util.insert_recurse(root, new Node(99));
        Util.print("main", "show unalanced tree");
        Util.printPreorder(root);

        Util.print("main", "Now do the same with red black corrections. First three");
        root = new Node(42);
        Util.insert(root, new Node(10));
        Util.insert(root, new Node(80));
        Util.print("main", "show tree");
        Util.printPreorder(root);
        Util.print("main", "make it unbalanced, but fix tree as we go.");
        Util.insert(root, new Node(85));
        Util.printPreorder(root);
        Util.insert(root, new Node(90));
        //Util.insert(root, new Node(89));
        //Util.insert(root, new Node(99));
        Util.print("main", "show balanced tree");
        Util.printPreorder(root);

        Util.insert(root, new Node(86 ));
        Util.print("main", "show balanced tree");
        Util.printPreorder(root);
        
        

    }

}
