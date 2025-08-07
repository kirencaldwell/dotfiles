#!/bin/bash
# Generate doxygen documentation and serve it

CMD="./doc/doxygen/generate_doxygen.sh local_docs"
$CMD $1
s=$1
d=${s%%:*}
my_ip=$(ip route get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}')
echo $my_ip":8000/"$d
(cd local_docs; python3 -m http.server 8000)
