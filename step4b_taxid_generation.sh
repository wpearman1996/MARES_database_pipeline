#!/bin/bash
echo '#!/bin/bash' | cat - ./taxid_commands_addition.txt > perl_taxid_additioncommands.sh
chmod +x perl_taxid_additioncommands.sh
./perl_taxid_additioncommands.sh 
OUTPUT="$(wc -l taxid_commands_addition.txt | awk '{print $1}')"
tail -n ${OUTPUT} ./taxdump/names.dmp | awk '{print $1}'> newtaxids.txt
