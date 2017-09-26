package co.spillikin.rackspace.test;

import org.junit.runner.RunWith;
import org.junit.runners.Suite;
import org.junit.runners.Suite.SuiteClasses;

@RunWith(Suite.class)
@SuiteClasses({ TestCollator.class, TestTopWords.class, TestWordCounter.class })
public class AllTests {

}
