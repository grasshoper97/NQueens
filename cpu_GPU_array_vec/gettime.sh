cat all.txt |grep -v "file"| grep "000" |awk '{print $2 ,  $4}' 
