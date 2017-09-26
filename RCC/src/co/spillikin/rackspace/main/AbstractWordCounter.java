package co.spillikin.rackspace.main;

import java.util.Hashtable;
import java.util.Map;
import java.util.Set;

/**
 * AbstractWordCounter represents functionality shared by both WordCounter (which operates 
 * on a per file basis) and Collator (which collects word counts across document searches).
 * 
 * @author chris
 *
 */

public abstract class AbstractWordCounter {

    // Map of words and their popularity.
    protected Map<String, Integer> wordPopularityMap = new Hashtable<>();

    /**
     * Get the number of occurrences of a word.
     * @param word
     * @return Number of times a word appeared.
     */
    public int getNumOccurrences(String word) {
        // Make this case insensitive.
        word = word.toLowerCase();
        Integer occurrences = wordPopularityMap.get(word);
        if (occurrences == null) {
            return 0;
        }
        return occurrences;
    }

    /**
     * Get the list of words found.
     * 
     * @return All the words found as a String array.
     */
    public String[] getWords() {
        Set<String> keys = wordPopularityMap.keySet();
        return keys.toArray(new String[keys.size()]);
    }

    /**
     * Get the number of different words in this WordCounter
     * (not to be confused with the total number of words processed).
     * 
     * @return The total number of words in the counter.
     */
    public int getNumberOfUniqueWords() {
        return wordPopularityMap.size();
    }

    /**
     * Get the wordPopularityMap as a String for debugging or command line output.
     * This is used by the toString() methods of the concrete classes.
     * 
     * @return String    someWord 1224   someOtherWord 5678  
     * separated by new line.
     */
    public String mapAsString() {
        StringBuffer sb = new StringBuffer();
        String[] words = getWords();
        for (String word : words) {
            sb.append("  " + word + " " + getNumOccurrences(word) + " \n");
        }
        return sb.toString();
    }
}
