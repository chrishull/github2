package co.spillikin.algoritym.redblacktree;

/**
 * red-black tree is a binary search tree which has the following red-black 
 * properties:
 * 
 * To avoid wordyness I'm going to avoid the usual best pricsite of creating 
 * a bean and try to make this look a little more C like by simply having 
 * public class members.
 *
 * Every node is either red or black.
 * Every leaf (NULL) is black.
 * If a node is red, then both its children are black.
 * Every simple path from a node to a descendant leaf contains the same number 
 * of black nodes. 
 * 
 * @author chris
 *
 */
public class Node {

    public static final int NODE_TEXT_SIZE = 6;

    enum NodeColor {
        RED,
        BLACK
    }

    // We could use NULL to represent a Sentinel node, but will
    // explicitly create Sentinel nodes for purposes of clarity and documentation.
    public Node parent = null;
    public Node left = null;
    public Node right = null;
    // Sentinel nodes have NULL data and are black.
    public Integer data = null;
    // This could certainly be a single bit, but for purposes of 
    // explicit documentation, I'm going to use an enum here.
    public NodeColor color = NodeColor.RED;

    /**
     * Create a single node.  The only rule implemented here is if we
     * pass in NULL, the node color is set to Black.
     * else we default to RED.
     * 
     * All other operations are external and non-object oriented to 
     * show clarity.
     * 
     * @param data
     */
    public Node(Integer data) {
        this.data = data;
        // sentinel node.
        if (data == null) {
            color = NodeColor.BLACK;
        }
    }

    public static String show(Node n) {
        StringBuffer sb = new StringBuffer();
        if (n != null) {
            sb.append("" + n.data);
            if (n.color == NodeColor.RED) {
                sb.append("r");
            } else {
                sb.append("b");
            }
            if ( n.parent == null ) {
                sb.append("*");
            }
        } else {
            sb.append("null");
        }
        // pad out centered
        StringBuffer sb2 = new StringBuffer();
        for (int i = sb.length() / 2; i < NODE_TEXT_SIZE / 2; i++) {
            sb2.append(" ");
        }
        sb2.append(sb.toString());
        for (int i = sb.length() / 2; i < NODE_TEXT_SIZE / 2; i++) {
            sb2.append(" ");
        }
        return sb2.toString();
    }

    public String toString() {
        return show(this);
    }
}
