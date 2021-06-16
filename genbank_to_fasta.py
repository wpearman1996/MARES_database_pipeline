#!/usr/bin/env python
#This work is copyright Cedar McKay and Gabrielle Rocap, University of Washington.
#This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License. 
#To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ or send a 
#letter to Creative Commons, 171 Second Street, Suite 300, San Francisco, California, 94105, USA.


#To install, move this file to your bin directory, adjust the above path to python, and install
#Biopython.


import sys
import os.path
from optparse import OptionParser
from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord
from Bio.SeqIO import InsdcIO


#### Collect Input ####
#######################
usage="""Takes a GenBank or EMBL format file as input, and outputs a fasta file.
usage: %prog -i FILE [options]"""


parser = OptionParser(usage=usage, version="%prog 1.2")


parser.add_option("-i", "--in_file", metavar="FILE", dest="in_file", default=None,
                help="Specify the input FILE that you wish to convert")

parser.add_option("-m", "--file_format", metavar="FORMAT", dest="file_format", default='genbank',
                help="Specify the input file format. Specify 'genbank' or 'embl'. "
                "Default is genbank.")

parser.add_option("-o", "--out_file", metavar="FILE", dest="out_file", default=None,
                help="Specify the path and name of the output fasta file you wish to create. "
                "Default will be the same as the in_file, but with a 'fasta' suffix.")

parser.add_option("-s", "--sequence_type", dest="sequence_type", default="aa",
                help="Specify the kind of sequence you would like to extract. Options are 'aa' "
                "(feature amino acids), 'nt' (feature nucleotides), 'whole' (the entire "
                "sequence, not just sequence corresponding to features) and 'taa'    (amino acids "
                "translated on the fly, which generates amino acid sequence by translating the "
                "nucleotide sequence rather than extracting from the feature table)."
                "Default is 'aa'.") 

parser.add_option("-f", "--feature_type", dest="feature_type", default="CDS",
                help="Specify the type of feature that you would like to extract. This option "
                "accepts arbitrary text, and will fail if you input a non-existent feature name. "
                "Common options are 'CDS', 'rRNA', 'tRNA', or 'gene'. Default is 'CDS'.")

parser.add_option("-d", "--delimiter", dest="delimiter", default="spacepipe",
                help="Specify the character you wish to use to separate header elements. Options "
                "are 'tab', 'space', 'spacepipe', 'pipe', 'dash', or 'underscore'. "
                "Default is 'spacepipe'.")

parser.add_option("-q", "--qualifiers", dest="qualifiers", default="locus_tag,gene,product,location",
                help="Specify which qualifiers should make up the fasta header line. Takes comma "
                "separated list. Will accept any qualifier that appears in your genbank "
                "file, (e.g. 'note', 'protein_id', etc). Qualifiers appear in the header line in "
                "the order you list them. Use 'location_long' for the exact location information as it "
                "appears in the input file. Default is 'locus_tag,gene,product,location'.")

parser.add_option("-a", "--annotations", dest="annotations", default=None,
                help="Specify which record annotation should make up the header line. Takes "
                "comma separated list. Will accept any annotation that appears in your genbank "
                "file, (e.g. 'comment', 'taxonomy', accessions, etc). Only used with "
                "--sequence_type = whole. Default is 'organism'.")

parser.add_option("-u", "--user_header", dest="user_header", default=None,
                help="If you prefer to specify your own completely custom header line, you may "
                "specify it here. Should be speccified in single quotes. Only used with "
                "--sequence_type = whole.")

(options, args) = parser.parse_args()




#### Variables and Names ####
#############################
#Figure out some names and paths
if options.in_file:
    in_file = os.path.abspath(options.in_file)
else:   
    print("You must specify an in_file. Use '-h' for help.")
    sys.exit()

(in_filePath, in_fileWholeName) = os.path.split(in_file)
(in_fileBase, in_fileExt) = os.path.splitext(in_fileWholeName)

#Figure out what our out_file is.
if options.out_file:
    out_file = os.path.join(in_filePath, options.out_file)
else:
    out_file = os.path.join(in_filePath, in_fileBase + '.fasta')
out_file = os.path.abspath(out_file)    

#Figure out what the user really wanted from delimiter:
delimiter = options.delimiter
if delimiter == 'space':
    delimiter = ' '
elif delimiter == 'spacepipe':
    delimiter = ' | '   
elif delimiter == 'pipe':
    delimiter = '|'
elif delimiter == 'dash':
    delimiter = '-'
elif delimiter == 'underscore':
    delimiter = '_'
elif delimiter == 'tab':
    delimiter = '   '
else:
    delimiter = ' | '
    
#Get the header_line user input, split on commas and turn into a list.
qualifier_list = options.qualifiers.split(',')
if options.annotations:
    annotation_list = options.annotations.split(',')
else:
    annotation_list = ['organism']

#Gather Remaining options
sequence_type = options.sequence_type
feature_type = options.feature_type
user_header = options.user_header
file_format = options.file_format


#Make sure no specified options conflict, or don't make sense
if user_header and sequence_type != 'whole':
    print("It doesn't make sense to set the user_header unless you are using the 'whole' " \
    "sequence_type. Use '-h' for help.")
    sys.exit()

if file_format not in ['genbank', 'embl']:
    print("Must specify either 'genbank' or 'embl' format for the in_file. Use '-h' for help.")
    sys.exit()

if options.annotations  and sequence_type != 'whole':
    print("It doesn't make sense to set the annotations unless you are using the 'whole' " \
    "sequence_type. Use '-h' for help.")
    sys.exit()

    
#### Functions ####
###################
def build_header(feature, qualifier_list):
    header = []
    #First we have to handle the special case of location.
    if 'location' in qualifier_list:
        #Go through some pain to make location human readable by adding 1 to first position
        location = str(int(str(feature.location.nofuzzy_start))+1) + ":" + \
        str(feature.location.nofuzzy_end) 
        if feature.strand == 1:
            location = location + ' Forward'
        elif feature.strand == -1:
            location = location + ' Reverse'
        else:
            location = location + ' Could not determine strand'
    if 'location_long' in qualifier_list:
        location_long = InsdcIO._insdc_feature_location_string(feature, len(record.seq))
    #Now march through items in qualifier_list and get qualifiers, or special case each one.
    #Start with the special cases
    for item in qualifier_list:
        if item == 'location':
            header.append(location)
        elif item == 'location_long':
            header.append(location_long)
        else:
            if item not in feature.qualifiers and item == 'gene':
                if 'locus_tag' in feature.qualifiers:
                    item = 'locus_tag'
                else:
                    item = 'db_xref'
            elif item not in feature.qualifiers and item == "locus_tag":
                item == 'db_xref'
            #Finished with the special cases, now just getting plain old qualifiers
            if item in feature.qualifiers:
                header_part = feature.qualifiers[item][0]
                #Catch improper newline character in the middle of features.
                header_part = header_part.replace("\n"," ")
                #Catch inproper spaces in middle of feature and replace with single space.
                #No idea why this appears sometimes
                header_part = header_part.replace("                      ", " ") 
                if header_part == '':
                    header.append('None')
                else:
                    header.append(header_part)
            else:
                header_part = 'missing_%s_qualifer' % item
                header.append(header_part)
    return delimiter.join(header)


def genbank_to_fasta(record, sequence_type, qualifier_list):
    new_records = []
    for feature in record.features:
        if feature.type == feature_type: # What kind of feature to extract. Usually CDS or tRFLP
            if sequence_type == 'nt':
                temp_record = SeqRecord(feature.extract(record.seq), id = build_header(feature, qualifier_list),\
                description = '')
            elif sequence_type == 'taa':
                if "transl_table" in feature.qualifiers:
                    translation_table = feature.qualifiers["transl_table"][0]
                else:
                    translation_table = 11
                temp_record = SeqRecord(feature.extract(record.seq).translate(table = translation_table),\
                id = build_header(feature, qualifier_list), description = '')
            elif sequence_type == 'aa':
                if "translation" in feature.qualifiers:
                    temp_seq = Seq(feature.qualifiers["translation"][0])
                else:               
                    if "transl_table" in feature.qualifiers:
                        translation_table = feature.qualifiers["transl_table"][0]
                    else:
                        translation_table = 11
                    temp_seq = feature.extract(record.seq).translate(table = translation_table)
                temp_record = SeqRecord(temp_seq, id = build_header(feature, qualifier_list), \
                description = '')
            new_records.append(temp_record)
    return new_records


def genbank_to_fasta_whole(record, annotation_list, user_header, delimiter):
    if user_header:
        header = user_header
    else:
        header = []
        for item in annotation_list:
            if item in record.annotations:
                header_part = record.annotations[item]
                if type(header_part) == type([]): #Some attributes are lists. Must turn into string
                    header_part = ' : '.join(header_part)
                header_part = header_part.replace("\n"," ") #Catch improper newline character
                header_part = header_part.replace("                      ", " ")#Catch inproper spaces
                header.append(header_part)
            else:
                header_part = 'missing_%s_annotation' % item
                header.append(header_part)
        header = delimiter.join(header)
    temp_record = SeqRecord(record.seq, id = header, description = '')
    return [temp_record] #Return a list because will be used in a context requiring a list

#### Main ####
##############
in_file_handle = open (in_file, 'rU') #The 'U' option so we don't have to worry about line endings
out_file_handle = open (out_file, 'w')

record_iterator = SeqIO.parse(in_file_handle, file_format)

for record in record_iterator:
    print(("Converting '%s' to fasta ..." % record.description))
    if sequence_type in ['nt', 'aa', 'taa']:
        fasta_records = genbank_to_fasta(record, sequence_type, qualifier_list)
    elif sequence_type == 'whole': #whole records are handled specially
        fasta_records = genbank_to_fasta_whole(record, annotation_list, user_header, delimiter)
    else:
        print("Unrecognized sequence_type. Use '-h' for help.")
        sys.exit()
    SeqIO.write(fasta_records, out_file_handle, 'fasta')

in_file_handle.close()
out_file_handle.close()
