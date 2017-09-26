package co.spillikin.rackspace.main;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;
import java.util.Set;
import co.spillikin.rackspace.worker.WordCounter;

/**
 * Once all the file word counts have been completed, 
 * feed WordCounter object list here to get final results.
 * We first create a master map of words and the number of occurrences for each.
 * This represents totals from all WordCounters passed in.
 * Then we create a map of top occurrences and the word (or words) that occur
 * that many times across all documents.
 * 
 * 
 * @author chris
 *
 */
public class Collator extends AbstractWordCounter {

    // We could record the top N, given the below code.  Adding this limit as 
    // a const.
    public static Integer TOP_LIST_SIZE = 10;

    // Set of all words and their popularity across various documents.
    private List<WordCounter> wordCounterList;

    // Map of the top "10" words used by popularity.  If some words come in 
    // with the same popularity value, they are grouped together.
    Map<Integer, List<String>> topTenMap = new Hashtable<>();

    /**
     * Given a list of completed WordCounter objects, collate and 
     * compute top words by number of occurrences.
     * 
     * @param wordCounterList
     */
    public Collator(List<WordCounter> wordCounterList) {
        this.wordCounterList = wordCounterList;
        collate();
        computeTopWords();
    }

    /**
     * Build our wordPopularityMap based on all words and popularity 
     * found within wordCounterList
     */
    private void collate() {

        // Map all words and their counts into the master Popularity Map
        for (WordCounter wordCounter : wordCounterList) {
            String[] words = wordCounter.getWords();
            // Accumulate a total for each word
            for (String word : words) {
                Integer wordCount = wordPopularityMap.get(word);
                if (wordCount == null) {
                    wordCount = wordCounter.getNumOccurrences(word);
                } else {
                    wordCount = wordCount + wordCounter.getNumOccurrences(word);
                }
                wordPopularityMap.put(word, wordCount);
            }
        }

    }

    /**
     * Build the top ten list.  Remember, some of the top ten items may 
     * have the same popularity values, so allow for more than one word per
     * key.
     */
    private void computeTopWords() {

        // Loop thru all words and grab their number of occurrences.
        for (String word : getWords()) {
            Integer occurrences = getNumOccurrences(word);
            // Add this word to the top ten list, keyed by occurrences
            List<String> topTenWordList = topTenMap.get(occurrences);
            // If we have an empty list, create one, else add to list of words 
            // with the given number of occurrences
            if (topTenWordList == null) {
                topTenWordList = new ArrayList<>();
            }
            topTenWordList.add(word);
            topTenMap.put(occurrences, topTenWordList);
            // The map size watermark will stay at TOP_LIST_SIZE.  Remove the lowest
            // single value in the set once we pass TOP_LIST_SIZE
            if (topTenMap.size() > TOP_LIST_SIZE) {
                Set<Integer> ranks = topTenMap.keySet();
                Integer lowestValue = Integer.MAX_VALUE;
                // find the lowest value.
                for (Integer v : ranks) {
                    if (v < lowestValue) {
                        lowestValue = v;
                    }
                }
                // remove the lowest value
                topTenMap.remove(lowestValue);
            }
        }
    }

    /**
     * Return a list of the top occurrence values in order of most frequent.
     * @return Array of Integer representing rankings, highest to lowest, 
     * where highest is the most frequently used word(s).
     */
    public Integer[] getTopOccurrences() {
        Set<Integer> keys = topTenMap.keySet();
        List<Integer> sortedSet = new ArrayList<>();
        for (Integer k : keys) {
            sortedSet.add(k);
        }
        Collections.sort(sortedSet, Collections.reverseOrder());
        return sortedSet.toArray(new Integer[sortedSet.size()]);
    }

    /**
     * Get the top word or words for the given number of occurrences.
     * @param occurrence
     * @return Word or words used N times across all documents.
     */
    public String[] getTopWordsByOccurrence(Integer occurrence) {
        List<String> wordList = topTenMap.get(occurrence);
        return wordList.toArray(new String[wordList.size()]);
    }

    /**
     * Get a string rep.  Shows words and occurrences and other collated info.
     * Used for std output and debugging.
     */
    public String toString() {
        StringBuffer sb = new StringBuffer(mapAsString() + "\n");
        for (Integer top : getTopOccurrences()) {
            sb.append(" [TOP]: " + top + " ");
            for (String topString : getTopWordsByOccurrence(top)) {
                sb.append(topString + " ");
            }
            sb.append("\n");
        }
        return sb.toString();
    }
}
