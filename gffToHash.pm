
use strict;
use warnings;
use Pod::Usage;

my $message_text  = "Error\n";
my $exit_status   = 2;          ## The exit status to use
my $verbose_level = 99;          ## The verbose level to use
my $filehandle    = \*STDERR;   ## The filehandle to write to
my $sections = "NAME|SYNOPSIS|DESCRIPTION";


=head1 NAME

gffToHash

=head1 SYNOPSIS

Converts a GFF file to a multi-dimensional hash.

B<Usage>: C<< %gffHash = gffToHash(<gff_file>, '<gff_attribute>', <keep_entire_record_bool>, '<featureSelect>') >>


=head2 ARGUMENTS

=over

=item B<arg1>: (<gff_file>) Path to GFF file.

=item B<arg2>: (<gff_attribute>) GFF attribute (9th field) to index the hash on.

=item B<arg3>: (<keep_entire_record_bool>). If set to 1, each GFF record will contain the entire corresponding (as input, chomp'ed) GFF line in the last element of its array.

=item B<arg4>: (<featureSelect>, optional). If set, only <featureSelect> features (I<e.g.> 'exon') will be considered in the input.

=back


=head2 DESCRIPTION

This perl module takes a GFF file as input and returns a multidimensional hash indexed by B<<gff_attribute>> identifier (I<e.g.> the values of the "transcript_id" attribute). For each given gff_attribute identifier, all corresponding records (filtered using the optional B<<featureSelect>> argument) are listed within a features array. Each element of the features array contains the actual GFF fields sorted in GFF order. The 9th field is itself arranged as a hash.


=head1 OUTPUT

The perl code (using a GENCODE GTF excerpt named "test.gtf" as input):

C<< use Data::Dumper; >>

C<< my %gffHash=gffToHash("test.gtf", 'transcript_id', 0, 'exon'); >>

C<< print Dumper \%gffHash; >>

will produce the following output:

C<< $VAR1 = { >>
C<<           'ENSTR0000509780.2' => [ >>
C<<                                    [ >>
C<<                                      'chrY', >>
C<<                                      'HAVANA', >>
C<<                                      'exon', >>
C<<                                      '1627746', >>
C<<                                      '1628033', >>
C<<                                      '.', >>
C<<                                      '+', >>
C<<                                      '.', >>
C<<                                      { >>
C<<                                        'gene_id' => 'ENSGR0000196433.8', >>
C<<                                        'transcript_type' => 'processed_transcript', >>
C<<                                        'transcript_name' => 'ASMT-005', >>
C<<                                        'gene_status' => 'KNOWN', >>
C<<                                        'gene_type' => 'protein_coding', >>
C<<                                        'exon_number' => '1', >>
C<<                                        'level' => '2', >>
C<<                                        'havana_transcript' => 'OTTHUMT00000471622.1', >>
C<<                                        'havana_gene' => 'OTTHUMG00000021065.2', >>
C<<                                        'tag' => 'PAR', >>
C<<                                        'exon_id' => 'ENSE00002031459.1', >>
C<<                                        'transcript_status' => 'KNOWN', >>
C<<                                        'transcript_id' => 'ENSTR0000509780.2', >>
C<<                                        'gene_name' => 'ASMT' >>
C<<                                      } >>
C<<                                    ], >>
C<<                                    [ >>
C<<                                      'chrY', >>
C<<                                      'HAVANA', >>
C<<                                      'exon', >>
C<<                                      '1636242', >>
C<<                                      '1636463', >>
C<<                                      '.', >>
C<<                                      '+', >>
C<<                                      '.', >>
C<<                                      { >>
C<<                                        'gene_id' => 'ENSGR0000196433.8', >>
C<<                                        'transcript_type' => 'processed_transcript', >>
C<<                                        'transcript_name' => 'ASMT-005', >>
C<<                                        'gene_status' => 'KNOWN', >>
C<<                                        'gene_type' => 'protein_coding', >>
C<<                                        'exon_number' => '2', >>
C<<                                        'level' => '2', >>
C<<                                        'havana_transcript' => 'OTTHUMT00000471622.1', >>
C<<                                        'havana_gene' => 'OTTHUMG00000021065.2', >>
C<<                                        'tag' => 'PAR', >>
C<<                                        'exon_id' => 'ENSE00002022546.1', >>
C<<                                        'transcript_status' => 'KNOWN', >>
C<<                                        'transcript_id' => 'ENSTR0000509780.2', >>
C<<                                        'gene_name' => 'ASMT' >>
C<<                                      } >>
C<<                                    ] >>
C<<                                  ] >>
C<<         }; >>

=head1 DEPENDENCIES

None

=head1 AUTHOR

Julien Lagarde, CRG, Barcelona, contact julienlag@gmail.com

=cut


sub gffToHash{
	if ($#_<1 || $_[0] eq '' || $_[1] eq ''){
		die "gffToHash: Wrong number of arguments";
	}
	my $keepWholeRecordInLastArrayElement=0;
	if (exists $_[2]){
		$keepWholeRecordInLastArrayElement=$_[2];
	}
	my $onlyGffRecords=undef;
	if (exists $_[3]){
		$onlyGffRecords=$_[3];
	}
	open GFF, "$_[0]" or die $!;
	my %gff=();
#	my %existsElementId=(); #to check if ElementId is really unique within the file
	my $identifyingElementId=$_[1]; # key used to uniquely identify gff records (e.g. exon_id or transcript_id attribute).
	while (<GFF>){
		next if ($_=~/^#/);

		chomp;
		my $untouchedLine=$_;
		my $line=$untouchedLine;
		$line=~s/\"//g;
		$line=~s/;//g;
		my @line=split("\t", $line);
		die "Malformed line at line $. . This doesn't look like a proper 9-field GFF record, dying.\n" unless ($#line==8);
		if(defined $onlyGffRecords){
			next unless ($line[2] eq $onlyGffRecords)
		}
		my $elementId=undef;
		if($line=~/$identifyingElementId (\S+)/){
			$elementId=$1;
#			if(exists $existsElementId{$elementId}){
#				warn "$identifyingElementId '$elementId' is not unique within the file. Only its last occurrence will be returned.\n";
#			}
#			$existsElementId{$elementId}=1;
		}
		else{
			warn "Line $. skipped (contains no '$identifyingElementId' attribute.\n";
			next;
		}
		my @attrs=split(" ", pop(@line));
		die "Odd number of subfields in 9th field of line $.. Dying.\n" unless ($#attrs%2==1);
		push (@{$gff{$elementId}}, \@line);
		#@{$gff{$elementId}}=@line;
		for (my $i=0; $i<=$#attrs;$i=$i+2){
			${${$gff{$elementId}}[$#{$gff{$elementId}}]}[8]{$attrs[$i]}=$attrs[$i+1];
		}
		if($keepWholeRecordInLastArrayElement ==1){
			push (@{$gff{$elementId}[$#{$gff{$elementId}}]}, $untouchedLine);
		}
		#print Dumper \%gff;
	}
	close GFF;
	return %gff;
}

1;
