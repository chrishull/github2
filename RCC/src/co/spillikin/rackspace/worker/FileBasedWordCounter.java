package co.spillikin.rackspace.worker;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;

/**
 * FileBasedWordCounter contains all word count information associated with a given file.
 * WordCounter is split out separately to make unit testing possible.
 * @uses WordCounter
 * 
 * This is intended to work with plain text (.txt) documents only.
 * @author chris
 *
 */
public class FileBasedWordCounter {

    // Contains word calculations
    private WordCounter wordCounts = new WordCounter();
    // Path to this file.
    private String fullPath;

    /**
     * Initialize with a full path to a text file for words to be counted.
     * @param fullPath, such as /Users/chris/tests/isaacasimov.txt
     */
    public FileBasedWordCounter(String fullPath) {
        this.fullPath = fullPath;
    }
    /**
     * Read in a file given a full path and create our WordCounter object.
     * 
     * @throws FileNotFoundException
     * @throws IOException
     */
    public void count() throws FileNotFoundException, IOException {

        try (BufferedReader br = new BufferedReader(new FileReader(fullPath))) {
            String line = br.readLine();
            while (line != null) {
                wordCounts.addWords(line);
                line = br.readLine();
            }
        }
    }

    /**
     * Get the counting info for this file.  You should call count first.
     * @return The WordCounter for this file.
     */
    public WordCounter getWordCounter() {
        return wordCounts;
    }

    /**
     * Get the filename used.
     * @return Full path to text file.
     */
    public String getFilePath() {
        return fullPath;
    }
}
