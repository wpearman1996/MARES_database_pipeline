#!/bin/bash
echo '#!/bin/bash' | cat - ./taxid_commands_addition.txt > perl_taxid_additioncommands.sh
chmod +x perl_taxid_additioncommands.sh
./perl_taxid_additioncommands.sh > details_newtaxids.txt
grep "TaxID" details_newtaxids.txt > newtaxids.txt
