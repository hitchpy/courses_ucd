#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define FIELD_NUM 14
#define MAX_NUM_CHARS 2000




/* Read an individual record in a file, returning the value of the ARR_DELAY variable. */
int
readRecord(char *line, int fieldNum)
{
    int i = 0, field;
    char *val;


    for(i = 0, field = 0; i < MAX_NUM_CHARS; i++) {
	if(line[i] == ',') { // used = rather than == 
	    field++;
	    if(field == fieldNum) {
		val = line + i + 1;
	    } else if(field == fieldNum + 1) {
		line[i] = '\0';
		fprintf(stderr, "%s\t1\n", val);    //print out the key value pair
		break;
	    }
	}
    }


    return(0);
}



int 
main(int nargs, char *argv[])
{

	char line[MAX_NUM_CHARS];
	while(fgets(line, MAX_NUM_CHARS, stdin)) {
	readRecord(line, FIELD_NUM);
    }
    return(0);
}



