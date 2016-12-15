#include <stdio.h>
#include <string.h>


/* Some helper definitions */
#define FALSE 0
#define TRUE 1

/* Data structures and other data definitions */
typedef unsigned int uint;
typedef unsigned char bool;

typedef struct disc_data_t {
    uint cur;
    uint max;
} disc_data_s;


// Function Declarations
uint check_discs(uint disc_count);
void reset_discs(uint disc_count);
void rotate_discs(uint disc_count, uint steps);


#define DISC_NUM 7

disc_data_s discs_original[DISC_NUM] = {
    {.max = 7,  .cur = 0},
    {.max = 13, .cur = 0},
    {.max = 3,  .cur = 2},
    {.max = 5,  .cur = 2},
    {.max = 17, .cur = 0},
    {.max = 19, .cur = 7},
    {.max = 11, .cur = 0}   // Part 2 just added this disc
};
disc_data_s discs[DISC_NUM];


int main(int argc, char **argv) {
    printf("Part 1: %d (corr: 121834)\n", check_discs(6));
    printf("Part 2: %d (corr: 3208099)\n", check_discs(7));
}

uint check_discs(uint disc_count) {
    uint timer_init = 0;

    while (TRUE) {
        // Reset disks and bring them to drop position (== timer_init)
        // We drop and rotate the discs by 1 -> timer_init + 1 so we spare a function call
        reset_discs(disc_count);
        rotate_discs(disc_count, timer_init + 1);

        for (uint i = 0; i < disc_count; i++) {
            if (discs[i].cur > 0) {
                break;
            }
            else if (i == (disc_count - 1) && discs[disc_count - 1].cur == 0) {
                return timer_init;
            }
            rotate_discs(disc_count, 1);
        }
        timer_init++;
    }

}

void reset_discs(uint disc_count) {
    memcpy(discs, discs_original, DISC_NUM * sizeof(disc_data_s));
}

void rotate_discs(uint disc_count, uint steps) {
    for (uint i = 0; i < DISC_NUM; i++) {
        discs[i].cur += steps;
        discs[i].cur %= discs[i].max;
    }
}