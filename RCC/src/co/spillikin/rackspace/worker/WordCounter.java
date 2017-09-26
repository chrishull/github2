package co.spillikin.rackspace.worker;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import co.spillikin.rackspace.main.AbstractWordCounter;

/**
 * A WordCounter takes in a blob of text and keeps track of separated words and their counts.
 * Multiple blobs can be sent and occurrences will accumulate within.
 * Word separation defined by simple regex, \\w+
 * This is the engine used to digest text files and turn them into occurrence maps.
 * 
 * @author chris
 *
 */
public class WordCounter extends AbstractWordCounter {

    /**
     * Add sets of words to this object based on popularity given a blob.
     * @param blob A block of text containing complete words.  
     * 
     * When passing in this text, be sure to not split a word in two while reading in
     * a file (or whatever your source is).  Reading line by line 
     * should scale well and avoid word splitting issues.
     */
    public void addWords(String blob) {
        String[] words = splitWords(blob);
        for (String key : words) {
            // Make this case insensitive.
            key = key.toLowerCase();
            Integer popularity = wordPopularityMap.get(key);
            // If exists, add one to count
            if (popularity == null) {
                popularity = 1;
            } else {
                popularity++;
            }
            wordPopularityMap.put(key, popularity);
        }
    }

    /**
     * Convert a blob into a set of words.  Return a simple String array.
     * @param blob.  Any blob of text.
     * @return  Array of words.
     */
    private String[] splitWords(String blob) {

        // A regex can also be used to split words. \w 
        // can be used to match word characters ([A-Za-z0-9_]), 
        // so that punctuation is removed from the results:
        List<String> words = new ArrayList<>();
        Pattern pattern = Pattern.compile("\\w+");
        Matcher matcher = pattern.matcher(blob);
        while (matcher.find()) {
            words.add(matcher.group());
        }
        // Return as easy to use primative array.
        return words.toArray(new String[words.size()]);
    }

    /**
     * Get a string rep.  Shows words and occurrences. Used for stdout and debugging.
     */
    public String toString() {
        return mapAsString();

    }
}
