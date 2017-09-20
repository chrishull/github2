package co.spillikin.algorithm.sort;

import java.lang.reflect.Array;

/**
 * The simnplest of all the sorting algorithms.
 * 
 * i ← 1
while i < length(A)
    j ← i
    while j > 0 and A[j-1] > A[j]
        swap A[j] and A[j-1]
        j ← j - 1
    end while
    i ← i + 1
end while

 * @author chris
 *
 */
public class InsertionSort {

    public static void sort(int[] array) {

        Main.printArray("InsertionSort start", array);
        int i = 1;
        
        // Walk length of array from 2nd element to last.
        while (i < array.length) {
            // grab nth element (2nd element to last) as we loop.
            int value = array[i];
            int j = i - 1;
            // Walk backwards from i - 1 to first element in array
            // Clear a space for value to go.
            while (j >= 0 && ( array[j] > value ) ) {
                array[j + 1] = array[j];
                j = j - 1;
            }
            // Insert value at place where array[j] was less than
            array[j + 1] = value;
            i = i + 1;
        }
        Main.printArray("InsertionSort end", array);

    }
}
