/**
 * @file
 * Contains an implementation of the countOnes function.
 */

unsigned countOnes(unsigned input) {
	// TODO: write your code here
	
	// Alternating Counters
	unsigned right1 = 0x55555555; // 1 bit right
	unsigned left1 = 0xAAAAAAAA; // 1 bit left
	unsigned right2 = 0x33333333; // 2 bit right
	unsigned left2 = 0xCCCCCCCC; // 2 bit left
	unsigned right3 = 0x0F0F0F0F; // 4 bit right
	unsigned left3 = 0xF0F0F0F0; // 4 bit left
	unsigned right4 = 0x00FF00FF; // 8 bit right
	unsigned left4 = 0xFF00FF00; // 8 bit left
	unsigned right5 = 0x0000FFFF; // 16 bit right
	unsigned left5 = 0xFFFF0000; // 16 bit left

	unsigned step1 = (input & right1) + ((input & left1) >> 1); // Step 1
	unsigned step2 = (step1 & right2) + ((step1 & left2) >> 2); // Step 2
	unsigned step3 = (step2 & right3) + ((step2 & left3) >> 4); // Step 3
	unsigned step4 = (step3 & right4) + ((step3 & left4) >> 8); // Step 4
	unsigned step5 = (step4 & right5) + ((step4 & left5) >> 16); // Step 5

	return step5;

}
