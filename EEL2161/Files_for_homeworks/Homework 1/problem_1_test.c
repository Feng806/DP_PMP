#include <stdio.h>

int main(void){
	
	// define exam score variables
	int exam1[2]; 
	float lval;
	//float exam2;
	//float exam3;
	
	// assign exam score variables input values
	exam1[0] = 75;
	exam1[1] = 80;
	exam1[2] = 85;
	//exam1 = 75;
	//exam2 = 80;
	//exam3 = 85;
	lval = sizeof(exam1)/sizeof(exam1[0]);
	// calculate average
	//avg 
	//lval = length(exam1);
	printf("%f\n",lval);
	getchar();
	return(0);
}
