package co.spillikin.algorithm.hashtable;

import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.IOException;

/**
 * An instance of this class contains the array with the hashtable itself.
 * We will create this to be a fixed size.  The hashing algorithm will 
 * account for the size when generating a hashcoee.
 * 
 * @author chris
 *
 */
public class Map {

    // Fixed size of array of buckets
    public static final Integer HASHTABLE_ARRAY_SIZE = 100;

    // Array of buckets.
    Bucket[] bucketArray = new Bucket[HASHTABLE_ARRAY_SIZE];

    /**
     * A quick and dirty hashcode generator.  Will generate an 
     * index into array that does not go beyond HASHTABLE_ARRAY_SIZE.
     * We make no attempt to be collisionproof. In fact, I want to
     * easily demonstrate collisions.  I simply add ascii values, so 
     * letter rearrangements will collide...  kitty and yittk
     * 
     * Remember, hash is one way. That's the difference between hasing and
     * encrypting.
     * 
     * @param key
     * @return crummy hashcode
     */
    public Integer hashcode(String key) {
        // First convert our Java String into bytes.
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        DataOutputStream out = new DataOutputStream(baos);
        try {
            out.writeUTF(key);
        } catch (IOException e) {
            Main.print("HASHCODE", "Somehow we got an exception turning our key into bytes.");
            e.printStackTrace();
        }
        byte[] bytes = baos.toByteArray();
        // Just add the bytes. Perhaps we'll do something more clever later.
        int code = 0;
        for (byte b : bytes) {
            code = code + b;
        }
        // wrap to length of array.
        return code % bucketArray.length;
    }

    /**
     * Given a key , value pair perform the following...
     * 1: Hash the key.
     * 2: See if there is a bucket present at index hashedKey.
     * 2.1: If so, see if the n,v pair exists.
     * 2.1.1: If so, replace if values are different.
     * 2.1.2: If not, create a new Bucket and add it to the end of the chain.
     * 2.2: If not, create the first bucket and insert at that location.
     * 
     * @param key
     * @param value
     */
    public void set(String key, String value) {
        Integer hashedKey = hashcode(key);
        Main.print("SET", "[key]: " + key + " [hashcode]: " + hashedKey + " [value]: " + value);
        // 2: See if there is a bucket present at index hashedKey.
        // 2.1: If so, see if the n,v pair exists.
        if (bucketArray[hashedKey] != null) {
            Main.print("SET", "collision detected at position: " + hashedKey);
            Bucket b = bucketArray[hashedKey];
            Bucket bTail = b;
            Main.printBucketChain("SET", b);
            // Run the list and see if our key is already there
            while (b != null) {
                // 2.1.1: If so, exit.
                if (key.equals(b.key)) {
                    Main.print("SET", "key found, checking value.");
                    if (!value.equals(b.value)) {
                        Main.print("SET", 
                            "value for key is different, replacing " + b.value + " with " + value);
                        b.value = value;
                    } else {
                        Main.print("SET", "Both key and value are the same, exiting.");
                    }
                    Main.print("SET", "Set complete. Bucket at position: " + hashedKey);
                    Main.printBucketChain("SET", bucketArray[hashedKey]);
                    return;
                }
                bTail = b;
                b = b.next;
            }
            // 2.1.2: If not, create a new Bucket and add it to the end of the chain.
            Main.print("SET", "Adding to end of linked list, [key]: " + key + " [value]: " + value);
            Bucket newBucket = new Bucket();
            newBucket.key = key;
            newBucket.value = value;
            bTail.next = newBucket;

            // 2.2: If no bucket at all, create the first bucket and insert at that location.
        } else {
            Bucket newBucket = new Bucket();
            Main.print("SET", "Adding [key]: " + key + " [value]: " + value + " at position: " + hashedKey);
            newBucket.key = key;
            newBucket.value = value;
            bucketArray[hashedKey] = newBucket;
        }
        // Show final insert at hash position.
        Main.print("SET", "Set complete. Bucket at position: " + hashedKey);
        Main.printBucketChain("SET", bucketArray[hashedKey]);

    }

    /**
     * Attempt to get a value.
     * 1. get hashcode.
     * 2. See if there is a bucket.
     * 2.1 If there is a bucket, see if you can find the key.
     * 2.1.1 If you find the key, return the value.
     * 2.1.2 Else return bucket found, key not found.
     * 2.2 Else return bucket not found.
     * 
     * @param key
     * @return
     */
    public String get(String key) {
        Integer hashedKey = hashcode(key);
        Main.print("GET", "[key]: " + key + " [hashcode]: " + hashedKey);
        if (bucketArray[hashedKey] != null) {
            Main.print("GET", "bucket found...");
            Bucket b = bucketArray[hashedKey];
            Main.printBucketChain("GET", b);
            while (b != null ) {
                if ( key.equals(b.key ) ) {
                    Main.print("GET", "key found in bucket, returning [value]: " + b.value);
                    return b.value;
                }
                b = b.next;
            }
            Main.print("GET", "key not found in bucket, returning NOT_FOUND_IN_BUCKET");
            return "NOT_FOUND_IN_BUCKET";
        }
        Main.print("GET", "No bucket at hash position, returning NOT_FOUND_EMPTY_BUCKET");
        return "NOT_FOUND_EMPTY_BUCKET";
    }

    /**
     * Attempt to remove a value.
     * 1. get hashcode.
     * 2. See if there is a bucket.
     * 2.1 If there is a bucket, see if you can find the key.
     * 2.1.1 If you find the key, remove it from the linked list.
     * 2.1.2 Else do nothing.
     * 2.2 Else do nothing.
     * @param key
     */
    public void remove(String key) {
        Integer hashedKey = hashcode(key);
        Main.print("REMOVE", "[key]: " + key + " [hashcode]: " + hashedKey);
        if (bucketArray[hashedKey] != null) {
            Main.print("REMOVE", "bucket found...");
            Bucket b = bucketArray[hashedKey];
            Bucket bTail = b;
            Main.printBucketChain("REMOVE", b);
            while (b != null ) {
                if ( key.equals(b.key ) ) {
                    Main.print("REMOVE", "key found in bucket, removing item from list, value is: " + b.value);
                    // If this is the only key value pair, clear this bucket.
                    if ( bucketArray.length == 1) {
                        Main.print("REMOVE", "there is only one entry in the list. Setting budket to NULL. Exiting.");
                        bucketArray[hashedKey] = null;
                        return;
                    }
                    Main.print("REMOVE", "there are two or more entries, removing this one from the list...");
                    // If first entry, do this
                    if ( b == bTail ) {
                        if ( b.next == null ) {
                            Main.print("REMOVE", "ERROR. Improperly formed linked list.");
                        } else {
                            Main.print("REMOVE", "k,v found is first element. Removing from list by setting next as first.");
                            bucketArray[hashedKey] = b.next;
                        }
                    } else {
                        Main.print("REMOVE", "k,v found is not first element. Pointing previous to element.next");
                        bTail.next = b.next;
                    }
                    Main.print("REMOVE", "Remove complete. Bucket at position: " + hashedKey);
                    Main.printBucketChain("REMOVE", bucketArray[hashedKey]);
                    return;
                }
                bTail = b;
                b = b.next;
            }
            Main.print("REMOVE", "key not found in bucket, exiting");
            return;
        }
        Main.print("REMOVE", "No bucket found at hash position, exiting");
    }
    
    
    /**
     * Display this hanstable
     */
    public void printTable() {
        Main.print("PRINT TABLE", "Showing hashtable: total array size: " + bucketArray.length );
        int emptySlots = 0;
        for (int i = 0; i < bucketArray.length; i++) {
            
            if (bucketArray[i] != null) {
                if ( emptySlots != 0 ) {
                    Main.print("PRINT TABLE", "Empty buckets: " + emptySlots );
                    emptySlots = 0;
                }
                Main.print("PRINT TABLE", "Bucket position: " + i);
                Main.printBucketChain("PRINT TABLE", bucketArray[i]);
            } else {
                emptySlots++;
            }
        }
        if ( emptySlots != 0 ) {
            Main.print("PRINT TABLE", "Empty buckets: " + emptySlots );
        }
    }
}
