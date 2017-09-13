package co.spillikin.algorithm.hashtable;

/**
 * 
 * In computing, a hash table (hash map) is a data structure which implements an associative 
 * array abstract data type, a structure that can map keys to values. A hash table 
 * uses a hash function to compute an index into an array of buckets or slots, from 
 * which the desired value can be found.
 * 
 * Rather than using properly formed Java (beans, correct scoping, etc), I'm going to 
 * write this code and make it as primatinve and C-like as possible in order to 
 * demonstrate the hashtable.
 * 
 * @author chris
 *
 */
public class Main {

    public static void main(String[] args) {
        print("MAIN", "Running hanstable");

        print("MAIN", "");
        print("MAIN", "Trying simple add ---------------------------------------------");
        Map myHashtable = new Map();
        myHashtable.set("kitty", "ada");
        myHashtable.set("doggy", "max");
        myHashtable.printTable();
        
        print("MAIN", "");
        print("MAIN", "Trying collision resulution ---------------------------------------------");
        myHashtable.set("yittk", "collision with kitty");
        myHashtable.printTable();
        
        print("MAIN", "");
        print("MAIN", "Trying replace ---------------------------------------------");
        myHashtable.set("kitty", "replaces ada");
        myHashtable.printTable();
        
        print("MAIN", "");
        print("MAIN", "Trying get ---------------------------------------------");
        myHashtable.get("kitty");
        myHashtable.get("yittk");
        myHashtable.get("doggy");
        
        print("MAIN", "");
        print("MAIN", "Trying get invalid values ---------------------------------------------");    
        print("MAIN", "lizard key should not be found unless we had an unexpected hash collision...");
        myHashtable.get("lizard");
        print("MAIN", "ytitk key should collide with kitty and not be found...");
        myHashtable.get("ytitk");
        myHashtable.printTable();
        
        print("MAIN", "");
        print("MAIN", "Trying remove followed by get ---------------------------------------------");
        myHashtable.remove("yittk");
        print("MAIN", "kitty should still be there...");
        myHashtable.get("kitty");
        print("MAIN", "yittk should be gone...");
        myHashtable.get("yittk");
        myHashtable.printTable();
        
        print("MAIN", "");
        print("MAIN", "Run complete");
        
    }

    /**
     * Send to std out, or change this if I like later to somethign else.
     * @param s
     */
    public static void print(String part, String s) {
        System.out.println(part + ": " + s);
    }

    /**
     * Display a chain of buckets
     * A chain of buckets is technically one bucket in the Hashtable, but 
     * I'm short circuiting a bit here.
     * 
     * @param b Start of chain of collided buckets.
     */
    public static void printBucketChain(String part, Bucket b) {
        StringBuffer sb = new StringBuffer("Showing bucket linked list...\n");
        int bucketIndex = 0;
        while (b != null) {
            sb.append("  [bucket part#] ");
            sb.append(bucketIndex);
            sb.append(" [key]: ");
            sb.append(b.key);
            sb.append(" [value]: ");
            sb.append(b.value);
            if (b.next == null) {
                sb.append(" [next]: -> NULL end of list");
            } else {
                sb.append(" [next]: -> ...\n");
            }
            b = b.next;
            bucketIndex++;
        }
        print(part, sb.toString());
    }
}
