/**
 * @file
 * Contains an implementation of the extractMessage function.
 */

#include <iostream> // might be useful for debugging
#include <assert.h>
#include "extractMessage.h"

using namespace std;

unsigned char *extractMessage(const unsigned char *message_in, int length) {
    // length must be a multiple of 8
    assert((length % 8) == 0);

    // allocate an array for the output
    unsigned char *message_out = new unsigned char[length];
    for (int i = 0; i < length; i++) {
        message_out[i] = 0;
    }

    // TODO: write your code here
    for (int i = 0; i < length; i+=8) {

        for (int j = 0; j < 8; j++) {
            int ascii = 0;
            int counter = 1;
            int temp = 1;

            counter = counter << j;
            // cout << counter << endl;

            for (int k = 0; k < 8; k++) {
                int bit = (message_in[k + i] & counter);
                // cout << temp << endl;

                if (bit) {
                    ascii = ascii + temp;
                    //cout << ascii << endl;
                }

                temp = temp * 2;
            }

            message_out[i + j] = ascii;
        }
    }

    return message_out;
}
