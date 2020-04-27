use strict;
use warnings;
use Bio::SeqIO;

my $file  = $ARGV[0];
my $seqio = Bio::SeqIO->new(-file => $file, -format => "genbank");
my $fasta = Bio::SeqIO->new(-file => ">$file.fa", -format => "fasta");
open TAXMAP, ">$file.map" || die "couldn't open mapping file: $!\n";

while(my $seq = $seqio->next_seq) {
    my $taxid = "";
    for my $feat($seq->get_SeqFeatures) {
    if($feat->has_tag("db_xref")) {
        for my $id($feat->get_tag_values("db_xref")) {
        if($id =~/taxon:(\d+)/) {
            $taxid = $1;
        }
        }
       }
    }
    my $id = "ref|".$seq->id;
    my $fa = Bio::Seq->new(-id => $id,
                           -desc => " taxon=$taxid, ".$seq->description,
                           -seq => $seq->seq);
    $fasta->write_seq($fa);
    print TAXMAP "$id $taxid\n" if $taxid;
}
