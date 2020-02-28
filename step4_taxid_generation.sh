cat ./taxid_process/notaxid_forgeneration.csv | \
awk -F "," '{ print "perl ./taxdump_edit.pl -names names.dmp -nodes nodes.dmp -taxa "$1" -parent "$3" -rank genus -division 1" }' | \
while read cmd; do $cmd >> details_newtaxids.txt; done
