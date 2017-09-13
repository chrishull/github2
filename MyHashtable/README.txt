Hashtable

Here I will demo a frequently asked interview question.  I use Java, but only primative structs.

About Hashtables
-----------------------------------

In computing, a hash table (hash map) is a data structure which implements an associative array abstract data type, a structure that can map keys to values. A hash table uses a hash function to compute an index into an array of buckets or slots, from which the desired value can be found.
Ideally, the hash function will assign each key to a unique bucket, but most hash table designs employ an imperfect hash function, which might cause hash collisions where the hash function generates the same index for more than one key. Such collisions must be accommodated in some way.
In a well-dimensioned hash table, the average cost (number of instructions) for each lookup is independent of the number of elements stored in the table. Many hash table designs also allow arbitrary insertions and deletions of key-value pairs, at (amortized[2]) constant average cost per operation.[3][4]


See Wikipedia
https://en.wikipedia.org/wiki/Hash_table

Demo Run, (see Main)
-----------------------------------

MAIN: Running hanstable
MAIN: 
MAIN: Trying simple add ---------------------------------------------
SET: [key]: kitty [hashcode]: 70 [value]: ada
SET: Adding [key]: kitty [value]: ada at position: 70
SET: Set complete. Bucket at position: 70
SET: Showing bucket linked list...
  [bucket part#] 0 [key]: kitty [value]: ada [next]: -> NULL end of list
SET: [key]: doggy [hashcode]: 43 [value]: max
SET: Adding [key]: doggy [value]: max at position: 43
SET: Set complete. Bucket at position: 43
SET: Showing bucket linked list...
  [bucket part#] 0 [key]: doggy [value]: max [next]: -> NULL end of list
PRINT TABLE: Showing hashtable: total array size: 100
PRINT TABLE: Empty buckets: 43
PRINT TABLE: Bucket position: 43
PRINT TABLE: Showing bucket linked list...
  [bucket part#] 0 [key]: doggy [value]: max [next]: -> NULL end of list
PRINT TABLE: Empty buckets: 26
PRINT TABLE: Bucket position: 70
PRINT TABLE: Showing bucket linked list...
  [bucket part#] 0 [key]: kitty [value]: ada [next]: -> NULL end of list
PRINT TABLE: Empty buckets: 29
MAIN: 
MAIN: Trying collision resulution ---------------------------------------------
SET: [key]: yittk [hashcode]: 70 [value]: collision with kitty
SET: collision detected at position: 70
SET: Showing bucket linked list...
  [bucket part#] 0 [key]: kitty [value]: ada [next]: -> NULL end of list
SET: Adding to end of linked list, [key]: yittk [value]: collision with kitty
SET: Set complete. Bucket at position: 70
SET: Showing bucket linked list...
  [bucket part#] 0 [key]: kitty [value]: ada [next]: -> ...
  [bucket part#] 1 [key]: yittk [value]: collision with kitty [next]: -> NULL end of list
PRINT TABLE: Showing hashtable: total array size: 100
PRINT TABLE: Empty buckets: 43
PRINT TABLE: Bucket position: 43
PRINT TABLE: Showing bucket linked list...
  [bucket part#] 0 [key]: doggy [value]: max [next]: -> NULL end of list
PRINT TABLE: Empty buckets: 26
PRINT TABLE: Bucket position: 70
PRINT TABLE: Showing bucket linked list...
  [bucket part#] 0 [key]: kitty [value]: ada [next]: -> ...
  [bucket part#] 1 [key]: yittk [value]: collision with kitty [next]: -> NULL end of list
PRINT TABLE: Empty buckets: 29
MAIN: 
MAIN: Trying replace ---------------------------------------------
SET: [key]: kitty [hashcode]: 70 [value]: replaces ada
SET: collision detected at position: 70
SET: Showing bucket linked list...
  [bucket part#] 0 [key]: kitty [value]: ada [next]: -> ...
  [bucket part#] 1 [key]: yittk [value]: collision with kitty [next]: -> NULL end of list
SET: key found, checking value.
SET: value for key is different, replacing ada with replaces ada
SET: Set complete. Bucket at position: 70
SET: Showing bucket linked list...
  [bucket part#] 0 [key]: kitty [value]: replaces ada [next]: -> ...
  [bucket part#] 1 [key]: yittk [value]: collision with kitty [next]: -> NULL end of list
PRINT TABLE: Showing hashtable: total array size: 100
PRINT TABLE: Empty buckets: 43
PRINT TABLE: Bucket position: 43
PRINT TABLE: Showing bucket linked list...
  [bucket part#] 0 [key]: doggy [value]: max [next]: -> NULL end of list
PRINT TABLE: Empty buckets: 26
PRINT TABLE: Bucket position: 70
PRINT TABLE: Showing bucket linked list...
  [bucket part#] 0 [key]: kitty [value]: replaces ada [next]: -> ...
  [bucket part#] 1 [key]: yittk [value]: collision with kitty [next]: -> NULL end of list
PRINT TABLE: Empty buckets: 29
MAIN: 
MAIN: Trying get ---------------------------------------------
GET: [key]: kitty [hashcode]: 70
GET: bucket found...
GET: Showing bucket linked list...
  [bucket part#] 0 [key]: kitty [value]: replaces ada [next]: -> ...
  [bucket part#] 1 [key]: yittk [value]: collision with kitty [next]: -> NULL end of list
GET: key found in bucket, returning [value]: replaces ada
GET: [key]: yittk [hashcode]: 70
GET: bucket found...
GET: Showing bucket linked list...
  [bucket part#] 0 [key]: kitty [value]: replaces ada [next]: -> ...
  [bucket part#] 1 [key]: yittk [value]: collision with kitty [next]: -> NULL end of list
GET: key found in bucket, returning [value]: collision with kitty
GET: [key]: doggy [hashcode]: 43
GET: bucket found...
GET: Showing bucket linked list...
  [bucket part#] 0 [key]: doggy [value]: max [next]: -> NULL end of list
GET: key found in bucket, returning [value]: max
MAIN: 
MAIN: Trying get invalid values ---------------------------------------------
MAIN: lizard key should not be found unless we had an unexpected hash collision...
GET: [key]: lizard [hashcode]: 52
GET: No bucket at hash position, returning NOT_FOUND_EMPTY_BUCKET
MAIN: ytitk key should collide with kitty and not be found...
GET: [key]: ytitk [hashcode]: 70
GET: bucket found...
GET: Showing bucket linked list...
  [bucket part#] 0 [key]: kitty [value]: replaces ada [next]: -> ...
  [bucket part#] 1 [key]: yittk [value]: collision with kitty [next]: -> NULL end of list
GET: key not found in bucket, returning NOT_FOUND_IN_BUCKET
PRINT TABLE: Showing hashtable: total array size: 100
PRINT TABLE: Empty buckets: 43
PRINT TABLE: Bucket position: 43
PRINT TABLE: Showing bucket linked list...
  [bucket part#] 0 [key]: doggy [value]: max [next]: -> NULL end of list
PRINT TABLE: Empty buckets: 26
PRINT TABLE: Bucket position: 70
PRINT TABLE: Showing bucket linked list...
  [bucket part#] 0 [key]: kitty [value]: replaces ada [next]: -> ...
  [bucket part#] 1 [key]: yittk [value]: collision with kitty [next]: -> NULL end of list
PRINT TABLE: Empty buckets: 29
MAIN: 
MAIN: Trying remove followed by get ---------------------------------------------
REMOVE: [key]: yittk [hashcode]: 70
REMOVE: bucket found...
REMOVE: Showing bucket linked list...
  [bucket part#] 0 [key]: kitty [value]: replaces ada [next]: -> ...
  [bucket part#] 1 [key]: yittk [value]: collision with kitty [next]: -> NULL end of list
REMOVE: key found in bucket, removing item from list, value is: collision with kitty
REMOVE: there are two or more entries, removing this one from the list...
REMOVE: k,v found is not first element. Pointing previous to element.next
REMOVE: Remove complete. Bucket at position: 70
REMOVE: Showing bucket linked list...
  [bucket part#] 0 [key]: kitty [value]: replaces ada [next]: -> NULL end of list
MAIN: kitty should still be there...
GET: [key]: kitty [hashcode]: 70
GET: bucket found...
GET: Showing bucket linked list...
  [bucket part#] 0 [key]: kitty [value]: replaces ada [next]: -> NULL end of list
GET: key found in bucket, returning [value]: replaces ada
MAIN: yittk should be gone...
GET: [key]: yittk [hashcode]: 70
GET: bucket found...
GET: Showing bucket linked list...
  [bucket part#] 0 [key]: kitty [value]: replaces ada [next]: -> NULL end of list
GET: key not found in bucket, returning NOT_FOUND_IN_BUCKET
PRINT TABLE: Showing hashtable: total array size: 100
PRINT TABLE: Empty buckets: 43
PRINT TABLE: Bucket position: 43
PRINT TABLE: Showing bucket linked list...
  [bucket part#] 0 [key]: doggy [value]: max [next]: -> NULL end of list
PRINT TABLE: Empty buckets: 26
PRINT TABLE: Bucket position: 70
PRINT TABLE: Showing bucket linked list...
  [bucket part#] 0 [key]: kitty [value]: replaces ada [next]: -> NULL end of list
PRINT TABLE: Empty buckets: 29
MAIN: 
MAIN: Run complete





