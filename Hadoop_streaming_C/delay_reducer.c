//reducer
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define BUFFER_SIZE 50
#define DELIM   "\t"
 
int main(int argc, char *argv[]){
    int count =0,delaytime,currentdelay=10000;//since there must have delay time less than 100, you could also set it to a bigger number
	char line[BUFFER_SIZE];
	while( fgets(line,BUFFER_SIZE -1, stdin)){
	    delaytime = atoi(strtok(line, DELIM));
		if(delaytime == currentdelay){
		    count += 1;
		}else {
		    if(currentdelay != 10000){
		        fprintf(stdout,"%d\t%d\n",currentdelay,count);
			}
	        currentdelay = delaytime;
			count = 1;
        }	
	
	} 	
    fprintf(stdout,"%d\t%d\n",currentdelay,count);
return(0);
}
