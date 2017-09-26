package co.spillikin.rackspace.main;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import co.spillikin.rackspace.worker.FileBasedWordCounter;
import co.spillikin.rackspace.worker.WordCounter;

/**
 * Commandline front end.  Enter no params for usage.
 * @author chris
 *
 */

public class Main {

    // result codes
    private static final int EXECUTED_OK = 0;
    private static final int USAGE_ERROR = -1;
    private static final int UNKNOWN_ERROR = -2;
    private static final int FILE_NOT_FOUND_ERROR = -3;
    private static final int HUNG_THREAD_ERROR = -4;
    private static final int INTERRUPTED_THREAD_ERROR = -5;

    // default thread (process someday) count
    private static final int DEFAULT_THREAD_COUNT = 10;
    private static final int THREAD_TIMEOUT_MINUTES = 5;

    // verbose mode
    private static boolean showVerbose = false;

    /**
     * Trivial command line interpreter. Batch.  See above for return types.
     * @param args
     */
    public static void main(String[] args) {

        // no args, show usage.
        if (args.length == 0) {
            printUsage();
            System.exit(EXECUTED_OK);
        }
        try {
            // Default thread count.
            Integer threads = DEFAULT_THREAD_COUNT;
            List<String> filePaths = new ArrayList<>();
            // ArrayList is faster but not thread safe. Create this list and then
            // read only while running from threads.
            List<FileBasedWordCounter> fileCounterList = new ArrayList<>();

            // Minimal non-robust command line interpreter.
            for (int i = 0; i < args.length; i++) {

                String s = args[i];
                // Look for threads count.  If found grab and skip next index.
                if (s.equalsIgnoreCase("-t")) {
                    threads = Integer.parseInt(args[i + 1]);
                    i++;
                    if (i >= args.length) {
                        break;
                    }
                    // verbose mode
                } else if (s.equalsIgnoreCase("-v")) {
                    showVerbose = true;
                    // Otherwise assume file path.
                } else {
                    filePaths.add(s);
                }
            }

            // Wind thru list of files and see if they exist.
            // Build our list of file count objects
            for (String path : filePaths) {
                File f = new File(path);
                if (!f.exists() || f.isDirectory()) {
                    printError("The file " + path + " does not exist or it is a directory. ");
                    System.exit(FILE_NOT_FOUND_ERROR);
                }
                fileCounterList.add(new FileBasedWordCounter(path));
            }

            // Now that we know all the paths are good, we're just giong to assume they 
            // are text files.

            // Java 8 makes multi-threading easy
            // Note, I'm using an ArrayList, so it's pre loaded.  Each thread is unaware of it.
            // First execute all our tasks in separate threads
            verbose("Creating a pool of " + threads + " threads");
            ExecutorService executor = Executors.newFixedThreadPool(threads);
            for (FileBasedWordCounter fileCounter : fileCounterList) {
                executor.submit(() -> {
                    String threadName = Thread.currentThread().getName();
                    verbose("Running thread " + threadName + " processing file "
                        + fileCounter.getFilePath());

                    try {
                        fileCounter.count();
                    } catch (IOException e) {
                        printError(
                            threadName + " Somehow an error took place while counting words.");
                        printError(threadName + " Did you not pass me a plain text file?");
                        printError(threadName + " Exiting");
                        printError(e.getMessage());
                        System.exit(USAGE_ERROR);
                    }

                });
            }
            // Wait for them to finish
            try {
                executor.shutdown();
                executor.awaitTermination(THREAD_TIMEOUT_MINUTES, TimeUnit.MINUTES);
            } catch (InterruptedException e) {
                printError("task interrupted.  Something stopped the workers.");
                System.exit(INTERRUPTED_THREAD_ERROR);
            } finally {
                // possible hung thread (or very long document)
                if (!executor.isShutdown()) {
                    printError("Waited " + THREAD_TIMEOUT_MINUTES
                        + " minutes. Tasks ran overtime.  Killing.");

                    // Do this when you want to continue running (correct way to handle executor);
                    // Forces shutdown for hung tasks.
                    executor.shutdownNow();
                    // But actually, we don't care.  Exit anyway.
                    System.exit(HUNG_THREAD_ERROR);
                }
            }

            // Per file results and build list for collator.
            verbose("Showing detailed file results.");
            List<WordCounter> wordCounterList = new ArrayList<>();
            for (FileBasedWordCounter countedFile : fileCounterList) {
                verbose(countedFile.getFilePath());
                WordCounter wc = countedFile.getWordCounter();
                verbose(wc.toString());
                wordCounterList.add(wc);
            }

            // Collate results
            Collator collator = new Collator(wordCounterList);
            verbose("Showing collated and top results.");
            verbose(collator.toString());

            // Formal display of top results
            System.out
                .println("Top " + Collator.TOP_LIST_SIZE + " words in order of occurrences... ");
            for (Integer top : collator.getTopOccurrences()) {
                System.out.print("Number of occurrences: " + top + ", word(s): ");
                for (String topString : collator.getTopWordsByOccurrence(top)) {
                    System.out.print(topString + " ");
                }
                System.out.println();
            }

            // If we got any kind of error at all, show usage and exit.
        } catch (Exception e) {
            printError(e.getMessage());
            System.exit(UNKNOWN_ERROR);
        }

        // No errors.
        verbose("Finished");
        System.exit(EXECUTED_OK);
    }

    /**
     * Print our usage to std out.
     */
    private static void printUsage() {
        System.out
            .println("Usage: [-t <thread count>] [-v verbose] file.txt [file2.txt file3.txt...]");
        System.out.println("Must provide full file paths.  Must be plain text files.");
    }

    /**
     * Show an error message plus usage.
     * @param errorMessage
     */
    private static void printError(String errorMessage) {
        System.err.println("An error occurred: " + errorMessage);
        printUsage();
        System.out.println("Exiting due to error.");

    }

    /**
     * Display only if verbose turned on.  See usage.
     * @param s
     */
    private static void verbose(String s) {
        if (showVerbose)
            System.out.println(s);
    }
}
