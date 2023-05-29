#include "stdio.h"
#include "stdint.h"
#include "stdlib.h"
#include "unistd.h"
#include "time.h"

struct Element{
    uint64_t key;
    uint64_t value;
};

extern void* copy(void* source, uint64_t length);
extern uint64_t compare(void* arr1, void* arr2, uint64_t length);

extern void bucket_sort(uint64_t a[], uint64_t length, uint64_t min_key, uint64_t max_key);
extern uint64_t bucket_sort_kvp(struct Element* a, uint64_t length, uint64_t min_key, uint64_t max_key, uint64_t allocListLength);
extern void selection_sort(uint64_t a[], uint64_t length);
extern void selection_sort_kvp(struct Element a[], uint64_t length);

void printEA(uint64_t a[], int length);
void* newEA(int length, uint64_t min_key, uint64_t max_key);
void printEA_kvp(struct Element a[], int length);
void* newEA_kvp(int length, uint64_t min_key, uint64_t max_key);
float GetTimeUs64();

#define NR_OF_ELEMENTS 2000
#define MIN_KEY 0
#define MAX_KEY 500000
#define MAX_LIST_LENGTH 256
#define PRINT_ARRAYS 0

void main(){

    uint64_t* a = (uint64_t*)newEA(NR_OF_ELEMENTS, MIN_KEY, MAX_KEY);
    uint64_t* b = copy(a, NR_OF_ELEMENTS * sizeof(uint64_t));
    uint64_t* c = copy(a, NR_OF_ELEMENTS * sizeof(uint64_t));

    struct Element* a_kvp = newEA_kvp(NR_OF_ELEMENTS, MIN_KEY, MAX_KEY);
    struct Element* b_kvp = copy(a_kvp, NR_OF_ELEMENTS * sizeof(struct Element));
    struct Element* c_kvp = copy(a_kvp, NR_OF_ELEMENTS * sizeof(struct Element));

    printf("\na = %p\nb = %p\nc = %p\na_kvp = %p\nb_kvp = %p\nc_kvp = %p\n", a, b, c, a_kvp, b_kvp, c_kvp);

    if(PRINT_ARRAYS) printf("\nUnsorted:");
    if(PRINT_ARRAYS) printEA(a, NR_OF_ELEMENTS);

    printf("\nBucket sort: ");
    float bucket_us_start = GetTimeUs64();
    bucket_sort(b, NR_OF_ELEMENTS, MIN_KEY, MAX_KEY);
    float bucket_us = GetTimeUs64() - bucket_us_start;
    if(PRINT_ARRAYS) printEA(b, NR_OF_ELEMENTS);
    printf("Took %1.0f µs\n", bucket_us);

    printf("\nSelection sort: ");
    float selection_us_start = GetTimeUs64();
    selection_sort(c, NR_OF_ELEMENTS);
    float seclection_us = GetTimeUs64() - selection_us_start;
    if(PRINT_ARRAYS) printEA(c, NR_OF_ELEMENTS);
    printf("Took %1.0f µs\n", seclection_us);

    printf("\nBucket != Selection:  %i bytes\n", compare(b, c, NR_OF_ELEMENTS * 8));

    if(PRINT_ARRAYS) printf("\n\nUnsorted (kvp):");
    if(PRINT_ARRAYS) printEA_kvp(a_kvp, NR_OF_ELEMENTS);
    
    printf("\nBucket sort (kvp): ");
    float bucket_kvp_us_start = GetTimeUs64();
    uint64_t b_kvp_success = bucket_sort_kvp(b_kvp, NR_OF_ELEMENTS, MIN_KEY, MAX_KEY, MAX_LIST_LENGTH);
    float bucket_kvp_us = GetTimeUs64() - bucket_kvp_us_start;
    if(PRINT_ARRAYS) printEA_kvp(b_kvp, NR_OF_ELEMENTS);
    printf("Took %1.0f µs\n", bucket_kvp_us);
    if(b_kvp_success != 0) printf("   Key appeared more than %i times!\n", MAX_LIST_LENGTH);

    printf("\nSelection sort (kvp): ");
    float selection_kvp_us_start = GetTimeUs64();
    selection_sort_kvp(c_kvp, NR_OF_ELEMENTS);
    float seclection_kvp_us = GetTimeUs64() - selection_kvp_us_start;
    if(PRINT_ARRAYS) printEA_kvp(c_kvp, NR_OF_ELEMENTS);
    printf("Took %1.0f µs\n", seclection_kvp_us);
    
    printf("\nBucket(kvp) != Selection(kvp):  %i bytes\n", compare(b_kvp, c_kvp, NR_OF_ELEMENTS * 16));

}
float GetTimeUs64()
{
    struct timespec *t = malloc(sizeof(struct timespec));
    clock_gettime(CLOCK_MONOTONIC, t);
    float us = (double)t->tv_nsec/1000.0;
    return us + (double)t->tv_sec*1000000.0;
}
void printEA(uint64_t a[], int length){
    for(int i=0; i<length; i++){
        if(i % 12 == 0) printf("\n");
        printf(" %6i", a[i]);
    }
    printf("\n");
}
void printEA_kvp(struct Element a[], int length){
    for(int i=0; i<length; i++){
        if(i % 8 == 0) printf("\n");
        printf(" { %6i, %6i } ", a[i].key, a[i].value);
    }
    printf("\n");
}
void* newEA(int length, uint64_t min_key, uint64_t max_key){
    uint64_t* a = malloc(length * 8);
    for(int i=0; i<length; i++){
        a[i] = rand() % (max_key - min_key) + min_key;
    }
    return a;
}
void* newEA_kvp(int length, uint64_t min_key, uint64_t max_key){
    struct Element* a = malloc(length * sizeof(struct Element));
    for(int i=0; i<length; i++){
        a[i].key = rand() % (max_key - min_key) + min_key;
        a[i].value = i;
    }
    return a;
}