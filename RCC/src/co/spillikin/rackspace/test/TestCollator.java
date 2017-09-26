package co.spillikin.rackspace.test;

import static org.junit.Assert.*;

import java.util.ArrayList;
import java.util.List;

import org.junit.Assert;
import org.junit.Test;

import co.spillikin.rackspace.main.Collator;
import co.spillikin.rackspace.worker.WordCounter;

public class TestCollator {

    /**
     * This tests the Collator which works across sets of files.
     */
    @Test
    public void testCollator() {

        WordCounter wc1 = new WordCounter();
        wc1.addWords("one two two three three three + == 4 four four four four should");

        WordCounter wc2 = new WordCounter();
        wc2.addWords("one should appear twice");

        // Combine them into a list.
        List<WordCounter> wgList = new ArrayList<>();
        wgList.add(wc1);
        wgList.add(wc2);

        // Check the collator
        Collator c = new Collator(wgList);
        // one should appear twice, in both wc1 and wc2
        Assert.assertEquals(2, c.getNumOccurrences("one"));
        // should should appear twice, in both wc1 and wc2
        Assert.assertEquals(2, c.getNumOccurrences("should"));
        // Only in wc2
        Assert.assertEquals(1, c.getNumOccurrences("appear"));
        Assert.assertEquals(1, c.getNumOccurrences("twice"));
        // Only in wc1
        Assert.assertEquals(2, c.getNumOccurrences("two"));
        Assert.assertEquals(3, c.getNumOccurrences("three"));
        Assert.assertEquals(4, c.getNumOccurrences("four"));
        Assert.assertEquals(1, c.getNumOccurrences("4"));
        // non words
        Assert.assertEquals(0, c.getNumOccurrences("=="));
        Assert.assertEquals(0, c.getNumOccurrences("+"));
        // Total words in collator
        Assert.assertEquals(8, c.getNumberOfUniqueWords());

    }

}
