package co.spillikin.algorithm.sort;

/**
 * Quicksort implemented as static functions.
 * 
 * @author chris
 *
 */
public class Quicksort {

    
    public static void quicksort(int[] array) {
        Main.printArray( "quicksort start",  array);
        quicksort_recurse(array, 0, array.length - 1);
        Main.printArray( "quicksort end",  array);
    }
    
    public static void quicksort_recurse(int[] array, int loIndex, int hiIndex) {
        if (loIndex < hiIndex) {
            Main.printArray( "quicksort_recurse",  array);
            int pivot = partition(array, loIndex, hiIndex);
            Main.print("quicksort_recurse", "low half: " + loIndex + " to "  + (pivot - 1) );
            quicksort_recurse(array, loIndex, pivot - 1);
            Main.print("quicksort_recurse", "high half: " + (pivot - 1) + " to "  +  hiIndex);
            quicksort_recurse(array, pivot + 1, hiIndex);
            
        }
    }

    public static int partition(int[] array, int loIndex, int hiIndex) {
        int pivot = array[hiIndex];
        Main.print("partition", "pivot: " + pivot + " at hiIndex " + hiIndex);
        int i = loIndex - 1;

        for (int j = loIndex; j < hiIndex; j++) {
            if (array[j] < pivot) {
                i = i + 1;
                Main.print("partition", "value at " + j + "(" + array[j] + ") < pivot" + 
                ", swap with " + i + "(" + array[i] + ") next pivot will be " + i );
                // swap A[i] with A[j]
                int swap = array[i];
                array[i] = array[j];
                array[j] = swap;
            }
        }
        // Check the last value
        if (array[hiIndex] < array[i + 1]) {
            // swap A[i + 1] with A[hi]
            int swap = array[i + 1];
            array[i + 1] = array[hiIndex];
            array[hiIndex] = swap;
        }
        // all values lower than pivot are up to i
        Main.print("partition", "all values lower than pivit are at : " + i + " new pivot:" + 
        (i + 1) );
        return i + 1;
    }

}
