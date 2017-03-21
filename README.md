# NAME

gffToHash

# SYNOPSIS

Converts a GFF file to a multi-dimensional hash.

**Usage**: `%gffHash = gffToHash(<gff_file>, '<gff_attribute>', <keep_entire_record_bool>, '<featureSelect>')`

## ARGUMENTS

- **arg1**: (&lt;gff\_file>) Path to GFF file.
- **arg2**: (&lt;gff\_attribute>) GFF attribute (9th field) to index the hash on.
- **arg3**: (&lt;keep\_entire\_record\_bool>). If set to 1, each GFF record will contain the entire corresponding (as input, chomp'ed) GFF line in the last element of its array.
- **arg4**: (&lt;featureSelect>, optional). If set, only &lt;featureSelect> features (_e.g._ 'exon') will be considered in the input.

## DESCRIPTION

This perl module takes a GFF file as input and returns a multidimensional hash indexed by **&lt;gff\_attribute**> identifier (_e.g._ the values of the "transcript\_id" attribute). For each given gff\_attribute identifier, all corresponding records (filtered using the optional **&lt;featureSelect**> argument) are listed within a features array. Each element of the features array contains the actual GFF fields sorted in GFF order. The 9th field is itself arranged as a hash.

# OUTPUT

The perl code (using a GENCODE GTF excerpt named "test.gtf" as input):

`use Data::Dumper;`

`my %gffHash=gffToHash("test.gtf", 'transcript_id', 0, 'exon');`

`print Dumper \%gffHash;`

will produce the following output:

        $VAR1 = {
          'ENSTR0000509780.2' => [
                                   [
                                     'chrY',
                                     'HAVANA',
                                     'exon',
                                     '1627746',
                                     '1628033',
                                     '.',
                                     '+',
                                     '.',
                                     {
                                       'gene_id' => 'ENSGR0000196433.8',
                                       'transcript_type' => 'processed_transcript',
                                       'transcript_name' => 'ASMT-005',
                                       'gene_status' => 'KNOWN',
                                       'gene_type' => 'protein_coding',
                                       'exon_number' => '1',
                                       'level' => '2',
                                       'havana_transcript' => 'OTTHUMT00000471622.1',
                                       'havana_gene' => 'OTTHUMG00000021065.2',
                                       'tag' => 'PAR',
                                       'exon_id' => 'ENSE00002031459.1',
                                       'transcript_status' => 'KNOWN',
                                       'transcript_id' => 'ENSTR0000509780.2',
                                       'gene_name' => 'ASMT'
                                     }
                                   ],
                                   [
                                     'chrY',
                                     'HAVANA',
                                     'exon',
                                     '1636242',
                                     '1636463',
                                     '.',
                                     '+',
                                     '.',
                                     {
                                       'gene_id' => 'ENSGR0000196433.8',
                                       'transcript_type' => 'processed_transcript',
                                       'transcript_name' => 'ASMT-005',
                                       'gene_status' => 'KNOWN',
                                       'gene_type' => 'protein_coding',
                                       'exon_number' => '2',
                                       'level' => '2',
                                       'havana_transcript' => 'OTTHUMT00000471622.1',
                                       'havana_gene' => 'OTTHUMG00000021065.2',
                                       'tag' => 'PAR',
                                       'exon_id' => 'ENSE00002022546.1',
                                       'transcript_status' => 'KNOWN',
                                       'transcript_id' => 'ENSTR0000509780.2',
                                       'gene_name' => 'ASMT'
                                     }
                                   ]
                                 ]
        };

# DEPENDENCIES

None

# AUTHOR

Julien Lagarde, CRG, Barcelona, contact julienlag@gmail.com
