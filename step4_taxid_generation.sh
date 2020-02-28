cat notaxid_forgeneration.csv | \
awk '{ print "perl ./taxdump_edit.pl -names names.dmp -nodes nodes.dmp -taxa "$1" -parent "$2" -rank genus -division 1" }' | \
while read cmd; do $cmd >> file.txt; done
