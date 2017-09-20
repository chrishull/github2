Demo of Insertion and Quick sorts


[quicksort start] array:  [45] [12] [23] [10] [2] [5]  length: 6
[quicksort_recurse] array:  [45] [12] [23] [10] [2] [5]  length: 6
[partition] pivot: 5 at hiIndex 5
[partition] value at 4(2) < pivot, swap with 0(45) next pivot will be 0
[partition] all values lower than pivit are at : 0 new pivot:1
[quicksort_recurse] low half: 0 to 0
[quicksort_recurse] high half: 0 to 5
[quicksort_recurse] array:  [2] [5] [23] [10] [45] [12]  length: 6
[partition] pivot: 12 at hiIndex 5
[partition] value at 3(10) < pivot, swap with 2(23) next pivot will be 2
[partition] all values lower than pivit are at : 2 new pivot:3
[quicksort_recurse] low half: 2 to 2
[quicksort_recurse] high half: 2 to 5
[quicksort_recurse] array:  [2] [5] [10] [12] [45] [23]  length: 6
[partition] pivot: 23 at hiIndex 5
[partition] all values lower than pivit are at : 3 new pivot:4
[quicksort_recurse] low half: 4 to 3
[quicksort_recurse] high half: 3 to 5
[quicksort end] array:  [2] [5] [10] [12] [23] [45]  length: 6


[InsertionSort start] array:  [45] [12] [23] [10] [2] [5]  length: 6
[InsertionSort end] array:  [2] [5] [10] [12] [23] [45]  length: 6


