package co.spillikin.rackspace.test;

import static org.junit.Assert.*;

import java.util.ArrayList;
import java.util.List;

import org.junit.Assert;
import org.junit.Test;

import co.spillikin.rackspace.main.Collator;
import co.spillikin.rackspace.worker.WordCounter;

public class TestTopWords {

    /**
     * This tests the Collator to see if is properly computes the 
     * top ten words.
     */
    @Test
    public void testCollator() {

        // create string "1 2 2 3 3 3 4 4 4 4... 11 11 11 11 (elevin times)"
        StringBuffer sb1 = new StringBuffer();
        for (int i = 1; i < 12; i++) {
            for (int numChars = 0; numChars < i; numChars++) {
                sb1.append(Integer.toString(i) + " ");
            }
        }
        WordCounter wc1 = new WordCounter();
        wc1.addWords(sb1.toString());
        WordCounter wc2 = new WordCounter();
        wc2.addWords(sb1.toString());

        // Combine them into a list.
        // Once collated we should have
        // "1 1 2 2 2 2... twice as many all the way to 11
        List<WordCounter> wgList = new ArrayList<>();
        wgList.add(wc1);
        wgList.add(wc2);

        // Collate and test
        // We have 2 occurrences of 1, which should fall off the top 10 list.
        // This should leave us with
        // 22 occurrences of 11
        // 20 occurrences of 10
        // ...
        // 4 occurrences of 2
        Collator c = new Collator(wgList);

        // See if we have exactly 10 top ranked words
        Integer[] occurrences = c.getTopOccurrences();
        Assert.assertEquals(10, occurrences.length);

        // Check to see if the popularity is sorted and of the correct values.
        // index 0, value 22
        // index 1, value 20 
        // ...
        // index 9, value 4
        for (int index = 0; index < 10; index++) {
            int popularity = 22 - (index * 2);
            int indPopularity = occurrences[index];
            Assert.assertEquals(popularity, indPopularity);
        }
        // Check topMap itself.
        // 2 occurs 4 times, 3 occurs 6 times...  11 occurs 22 times.
        for (int i = 2; i < 12; i++) {
            String[] values = c.getTopWordsByOccurrence(i * 2);
            Assert.assertEquals(1, values.length);
            if (values.length == 1) {
                int intValue = Integer.parseInt(values[0]);
                Assert.assertEquals(i, intValue);
            }
        }

    }

}
