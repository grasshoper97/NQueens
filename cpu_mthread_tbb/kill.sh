#!/bin/bash
for n in {15187..15258}
do
	echo "id  =${n}"
	sudo kill  $n
done

