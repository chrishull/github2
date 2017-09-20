package co.spillikin.algorithm.sort;

public class Main {

    public static void main(String[] args) {
        int[] myIntArray = { 45, 12, 23, 10, 2, 5 };
        Quicksort.quicksort(myIntArray);
        
        int[] myIntArray2 = { 45, 12, 23, 10, 2, 5 };
        InsertionSort.sort(myIntArray2);
        

    }

    public static void print(String part, String message) {
        System.out.println("[" + part + "] " + message);
    }

    public static void printArray(String part, int[] array) {
        System.out.print("[" + part + "] array: ");
        for (int i : array) {
            System.out.print(" [" + i + "]");
        }
        System.out.println("  length: " + array.length);
    }
}
