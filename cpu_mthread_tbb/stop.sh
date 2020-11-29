#!/bin/bash
for n in {28998..29055}
do
	echo "kill ${n}"
	sudo kill ${n}
done

