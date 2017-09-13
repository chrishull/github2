package co.spillikin.algorithm.hashtable;

/**
 * This represents a value in our hashtable.  Because collisions can and do take place, 
 * we account for that by using a method called Separate Chaining.
 * 
 * In the method known as separate chaining, each bucket is independent, 
 * and has some sort of list of entries with the same index. The time 
 * for hash table operations is the time to find the bucket (which is constant) 
 * plus the time for the list operation.
 * 
 * We will chain via linked list. In an effort to keep the code as small as possible
 * I will not create a bean.
 * 
 * @author chris
 *
 */
public class Bucket {

    // Preserve the original key.
    String key;
    String value;
    Bucket next = null;
}
