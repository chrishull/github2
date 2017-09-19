Red Black Tree

Based on documentation provided by Wikipedia.

A red–black tree is a kind of self-balancing binary search tree. Each node of the 
binary tree has an extra bit, and that bit is often interpreted as the color (red 
or black) of the node. These color bits are used to ensure the tree remains approximately 
balanced during insertions and deletions.
Balance is preserved by painting each node of the tree with one of two colors 
in a way that satisfies certain properties, which collectively constrain how 
unbalanced the tree can become in the worst case. When the tree is modified, 
the new tree is subsequently rearranged and repainted to restore the coloring 
properties. The properties are designed in such a way that this rearranging and 
recoloring can be performed efficiently.

The balancing of the tree is not perfect, but it is good enough to allow it to 
guarantee searching in O(log n) time, where n is the total number of elements in the tree. 
The insertion and deletion operations, along with the tree rearrangement and recoloring, 
are also performed in O(log n) time.

Tracking the color of each node requires only 1 bit of information per node because there 
are only two colors. The tree does not contain any other data specific to its being a 
red–black tree so its memory footprint is almost identical to a classic (uncolored) 
binary search tree. In many cases, the additional bit of information can be stored 
at no additional memory cost.

https://en.wikipedia.org/wiki/Red%E2%80%93black_tree

This doesn't quite work yet.
--------------------------------------


Asterist (*) indiecates node has no parent.

[main] start with three nodes
[insert_recurse] root  42r*  node  10r* 
[insert_recurse] root  42r*  node  80r* 
[main] show tree
                                                42r* 
                                              10r    80r  
[main] make it unbalanced, do not correct as we go.
[insert_recurse] root  42r*  node  85r* 
[insert_recurse] root   80r   node  85r* 
[insert_recurse] root  42r*  node  90r* 
[insert_recurse] root   80r   node  90r* 
[insert_recurse] root   85r   node  90r* 
[insert_recurse] root  42r*  node  89r* 
[insert_recurse] root   80r   node  89r* 
[insert_recurse] root   85r   node  89r* 
[insert_recurse] root   90r   node  89r* 
[insert_recurse] root  42r*  node  99r* 
[insert_recurse] root   80r   node  99r* 
[insert_recurse] root   85r   node  99r* 
[insert_recurse] root   90r   node  99r* 
[main] show unalanced tree
                                                42r* 
                                              10r    80r  
                                       null  null  null   85r  
                           null  null  null  null  null  null  null   90r  
   null  null  null  null  null  null  null  null  null  null  null  null  null  null   89r    99r  
[main] Now do the same with red black corrections. First three
[insert_recurse] root  42r*  node  10r* 
[insert_case4] g null  10r  
[insert_recurse] root  42r*  node  80r* 
[insert_case4] g null  80r  
[main] show tree
                                                42r* 
                                              10r    80r  
[main] make it unbalanced, but fix tree as we go.
[insert_recurse] root  42r*  node  85r* 
[insert_recurse] root   80r   node  85r* 
[insert_case3] parent(n) = BLACK, uncle(n) = BLACK, grand(n) = RED
[insert_case3] calling insert_repari_tree(grandparent(n) )
[insert_case1] We have a new root, set to BLACK.
                                                42b* 
                                              10b    80b  
                                       null  null  null   85r  
[insert_recurse] root  42b*  node  90r* 
[insert_recurse] root   80b   node  90r* 
[insert_recurse] root   85r   node  90r* 
[insert_case4] g null  90r  
[main] show balanced tree
                                                42b* 
                                              10b    80b  
                                       null  null  null   85r  
                           null  null  null  null  null  null  null   90r  
[insert_recurse] root  42b*  node  86r* 
[insert_recurse] root   80b   node  86r* 
[insert_recurse] root   85r   node  86r* 
[insert_recurse] root   90r   node  86r* 
[insert_case4] rotateRight(p) n = n.right;
[insert_case4step2] rotateLeft(g);
[insert_case4step2] set p.color = BLACK, g.color = RED
[main] show balanced tree
                                                42b* 
                                              10b    80b  
                                       null  null  null   85r  
We Lost a node.  I think Rotate doesn't work.

