package co.spillikin.rackspace.test;

import java.util.ArrayList;
import java.util.List;

import org.junit.Assert;
import org.junit.Test;

import co.spillikin.rackspace.main.Collator;
import co.spillikin.rackspace.worker.WordCounter;

/**
 * Non-file based unit tests to see if the basic underlying algorithms work.
 * Rerun these whenever you make changes to the logic of this code.
 * 
 * @author chris
 *
 */
public class TestWordCounter {

    /**
     * This tests both the regex I'm using and the low level per-file word counter.
     */
    @Test
    public void testWordCounter() {

        WordCounter wg = new WordCounter();
        wg.addWords("Not yet yet, +- implemented");

        // three total words
        Assert.assertEquals(3, wg.getNumberOfUniqueWords());
        Assert.assertEquals(1, wg.getNumOccurrences("Not"));
        Assert.assertEquals(1, wg.getNumOccurrences("not"));
        Assert.assertEquals(1, wg.getNumOccurrences("NOT"));
        Assert.assertEquals(2, wg.getNumOccurrences("yet"));
        // things you should never see.
        Assert.assertEquals(0, wg.getNumOccurrences("+"));
        Assert.assertEquals(0, wg.getNumOccurrences("fnord"));
        Assert.assertEquals(0, wg.getNumOccurrences(" "));
    }

    @Test
    public void testWordCounterNumbers() {

        WordCounter wg = new WordCounter();
        wg.addWords("111 4-5 222, +- 333");

        Assert.assertEquals(1, wg.getNumOccurrences("111"));
        Assert.assertEquals(1, wg.getNumOccurrences("222"));
        Assert.assertEquals(1, wg.getNumOccurrences("333"));
        Assert.assertEquals(1, wg.getNumOccurrences("4"));
        Assert.assertEquals(1, wg.getNumOccurrences("5"));
        Assert.assertEquals(5, wg.getNumberOfUniqueWords());

    }

 

}
