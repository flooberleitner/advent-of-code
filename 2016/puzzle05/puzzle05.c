#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#if defined(__APPLE__)
#  define COMMON_DIGEST_FOR_OPENSSL
#  include <CommonCrypto/CommonDigest.h>
#  define SHA1 CC_SHA1
#else
#  include <openssl/md5.h>
#endif

// Puzzle Input
#define DOOR_ID "reyedfim"
#define DOOR_ID_SIZE (sizeof(DOOR_ID))
#define PASSWD_LENGTH 8

// Play it safe with the size of the buffer holding the md5 input string
#define INPUT_SIZE (DOOR_ID_SIZE + 20)
#define DIGEST_SIZE 16


/* Some helper definitions */
#define FALSE 0
#define TRUE 1

#define GET_LOW_NIBBLE(buf, pos) (buf[pos] & 0x0F)
#define GET_HI_NIBBLE(buf, pos) ((buf[pos] & 0xF0) >> 4)


/* Data structures and other data definitions */
typedef unsigned int uint;
typedef unsigned char bool;

typedef struct passwd_data_t {
    char password[PASSWD_LENGTH + 1];
    uint chars_added;
    bool finished;
} passwd_data_s;


// Function Declarations
void create_digest(char *out, size_t out_length, const char *input, size_t input_length);
void handle_step1(passwd_data_s *ctx, const char* digest, size_t digest_length);
void handle_step2(passwd_data_s *ctx, const char* digest, size_t digest_length);
bool digest_valid(const char* digest, size_t digest_length);



int main(int argc, char **argv) {
    uint round = 0;
    char digest[(2 * DIGEST_SIZE) + 1];
    char input[INPUT_SIZE + 1];
    passwd_data_s step1_data = {.finished = FALSE};
    passwd_data_s step2_data = {.finished = FALSE};
    size_t digest_len = 0;

    while (step1_data.finished == FALSE || step2_data.finished == FALSE) {
        snprintf(input, sizeof(input), "%s%i", DOOR_ID, round);
        create_digest(digest, sizeof(digest), input, strlen(input));
        digest_len = strlen(digest);

        if (digest_valid(digest, digest_len) == TRUE) {
            handle_step1(&step1_data, digest, digest_len);
            handle_step2(&step2_data, digest, digest_len);
        }

        if (round % 1000000 == 0) {
            printf("Round %d\n", round);
            printf("  Step1: pwd=%s, chars_added=%d\n", step1_data.password, step1_data.chars_added);
            printf("  Step2: pwd=%s, chars_added=%d\n", step2_data.password, step2_data.chars_added);
        }        
        round++;
    }

    printf("Puzzle05 Step1: %s\n", step1_data.password);
    printf("Puzzle05 Step2: %s\n", step2_data.password);
    return 0;
}

/*
 * Check if first 5 characters of digest are '0'.
 */
bool digest_valid(const char* digest, size_t digest_length) {
    bool valid = TRUE;

    for(int i = 0; i < 5; i++) {
        valid = valid && (digest[i] == '0');
        if (valid == FALSE) {
            break;
        }
    }

    return valid;
}

void create_digest(char *out, size_t out_length, const char *input, size_t input_length) {
    MD5_CTX ctx;
    unsigned char digest[DIGEST_SIZE];

    MD5_Init(&ctx);

    while (input_length > 0) {
        if (input_length > 512) {
            MD5_Update(&ctx, input, 512);
            input_length -= 512;
        } else {
            MD5_Update(&ctx, input, input_length);
            input_length -= input_length;
        }
        input += 512;
    }

    MD5_Update(&ctx, input, input_length);
    MD5_Final(digest, &ctx);

    for (int i = 0; i < DIGEST_SIZE; i++) {
        snprintf(out + (i * 2), 3, "%02x", digest[i]);
    }
}

/*
 * Add 5th character in digest.
 */
void handle_step1(passwd_data_s *ctx, const char* digest, size_t digest_length) {
    if (ctx -> finished == TRUE) return;

    ctx -> password[ctx -> chars_added] = digest[5];
    ctx -> chars_added++;
    if (ctx -> chars_added >= PASSWD_LENGTH) {
        ctx -> finished = TRUE;
    }
}

/*
 * Add 6th character in digest at position declared by 5th character if represents
 * a valid offset in the password string.
 * Only add the char if position is still empty.
 */
void handle_step2(passwd_data_s *ctx, const char* digest, size_t digest_length) {
    if (ctx -> finished == TRUE) return;

    int pos = digest[5] - 48;

    if (pos >= 0 && pos < PASSWD_LENGTH && ctx -> password[pos] == 0) {
        ctx -> password[pos] = digest[6];
        ctx -> chars_added++;
        if (ctx -> chars_added >= PASSWD_LENGTH) {
            ctx -> finished = TRUE;
        }
    }
}
