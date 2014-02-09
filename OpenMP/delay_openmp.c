#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "readRecords.h"
#include <omp.h>



/* Initialize a Table object, allocating it if necessary or filling in an existing instance.  */
Table *
makeTable(Table *tt)
{
    if(!tt)
	tt = (Table *) malloc(sizeof(Table));

    tt->min = - MAX_NUM_VALUES/2;
    tt->max = MAX_NUM_VALUES/2;
    tt->numValues = MAX_NUM_VALUES + 1;

    memset(tt->values, 0, sizeof(int) * (MAX_NUM_VALUES + 1));
    return(tt);
}

/* Increment the count for the specified value in the given table */
void 
insertValue(int value, Table *t)
{
    if(value < t->min || value > t->max) {
	fprintf(stderr, "%d is outside of the range of the table\n", value);
    } else {
	int i;
	i = value - t->min;
	t->values[i] ++;
    }
}


/* Display a table on the console/terminal. 
   This is used in the standalone version. 
   So it doesn't use's R's print routines.
  */
void 
showTable(Table *t)
{
    int i;
    for(i = 0; i < MAX_NUM_VALUES; i++) {
	if(t->values[i] > 0)
	    fprintf(stderr, "%d: %ld\n", t->min + i, t->values[i]);
    }
}

/* process a file, line by line.  */
double
readDelays(const char *filename, Table *data, int fieldNum)
{
    FILE *f;
    char line[MAX_NUM_CHARS];

    f = fopen(filename, "r");
    if(!f) 
	exit(1);  // if we run this in R, don't use exit(), but PROBLEM-ERROR.

    // header line
    fgets(line, MAX_NUM_CHARS, f);

    int val;
    while(fgets(line, MAX_NUM_CHARS, f)) {
	val = readRecord(line, fieldNum);
	insertValue(val, data);
    }

    return((double) val);
}


/* Read an individual record in a file, returning the value of the ARR_DELAY variable. */
int
readRecord(char *line, int fieldNum)
{
    int i = 0, field;
    char *val;

#if 0
    char *tmp;
    for(i = 0; i < 43; i++)
	val = strtok_r(val, ",", &tmp);

#else

    for(i = 0, field = 0; i < MAX_NUM_CHARS; i++) {
	if(line[i] == ',') { // used = rather than ==
	    field++;
	    if(field == fieldNum) {
		val = line + i + 1;
	    } else if(field == fieldNum + 1) {
		line[i] = '\0';
		break;
	    }
	}
    }

#endif

    return(atoi(val));
}

/*
  Merge several tables into a single table. This sums counts from the different tables
  for the same value.
  Could do this with threads, but probably not worth the overhead. */
Table*
combineTables(Table *table, Table *out)
{
    int i;

	for(i = 0; i < out->numValues; i++) 
	    out->values[i] += table->values[i];
    

    return(out);
}


Table *tables[30];
int 
main(int nargs, char *argv[])
{
    Table * out = makeTable(NULL);
	Table tables[0] = makeTable(NULL);
    int t;
	#pragma omp parallel
	#pragma omp for shedule(static)
    for(t = 1 ; t < nargs; t++) {
	tables[t] = makeTable(NULL);
	readDelays(argv[t],tables[t],FIELD_NUM);
		}
	
     for(t = 0; t < nargs - 1; t++)
	  out = combineTables(tables[t], out);
	showTable(out);
    return(0);
}

