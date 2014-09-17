#!/bin/bash
#CREATE TABLE delays (arrdelay double precision);
for f in *.csv ; do
   echo $f |grep -o '_' >NAME
   if [ "$?" -eq 0 ];then
       cat $f |cut -f45 -d ,|~/postgres/bin/psql postgres -c "COPY delays FROM STDIN DELIMITER ',' CSV HEADER NULL AS '';"
   else
       cat $f |cut -f15 -d ,|~/postgres/bin/psql postgres -c "COPY delays FROM STDIN DELIMITER ',' CSV HEADER NULL AS 'NA';"
   fi
done