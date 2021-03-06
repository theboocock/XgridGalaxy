package XrefParser::IKMCParser;

use strict;
use LWP::UserAgent;

use base qw( XrefParser::BaseParser );


sub new {
    my $proto = shift;

    my $class = ref $proto || $proto;
    my $self = bless {}, $class;

    return $self;
}

sub run_script {
  my $self = shift;
  my $file = shift;
  my $source_id = shift;
  my $species_id = shift;
  my $verbose = shift;

  my ($type, $my_args) = split(/:/,$file);

  my %type2id;

  foreach my $t ("No products available yet", "Vector available", "ES cells available", "Mice available"){
      my $ikmc = "IKMCs_".$t;
      $ikmc =~ s/ /_/g;
      $type2id{$t}  = XrefParser::BaseParser->get_source_id_for_source_name($ikmc);
#      print $ikmc."\t".$type2id{$t}."\n";
      if(!defined( $type2id{$t})){
	die  "Could not get source id for $ikmc\n";
      }
    }	

  my $xml = (<<XXML);
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Query>
<Query  virtualSchemaName = "default" formatter = "TSV" header = "0" uniqueRows = "1" count = "" datasetConfigVersion = "0.6" >
  
  <Dataset name = "dcc" interface = "default" >
    <Attribute name = "mgi_accession_id" />
    <Attribute name = "marker_symbol" />
    <Attribute name = "vector_available" />
    <Attribute name = "escell_available" />
    <Attribute name = "mouse_available" />
    <Attribute name = "ensembl_gene_id" />
    </Dataset>
</Query>
XXML


#  print $xml."\nYO\n";
    
  my %symbols;
  my %ensembl_ids;
  my %status;
    
  my $path="http://www.i-dcc.org/biomart/martservice?";
  my $request = HTTP::Request->new("POST",$path,HTTP::Headers->new(),'query='.$xml."\n");
  my $ua = LWP::UserAgent->new;
    
  my $response;
  

#  print "getting data from url\n";
  my $line_count=0;
  my $old_data="";
  my $chunks = 0;
  my $before;
  $ua->request($request,
	       sub{
		 my($data, $response) = @_;
		 if ($response->is_success) {
		   chomp $data;
		   if($data =~ /^MGI:/ and $chunks){
		     $old_data .= "\n";
		   }	
		   my $data_line= $old_data.$data;
		   my @lines = split(/\n/,$data_line);
		   if(length($lines[-1]) == 0){
		     pop @lines;
		   }	
		   $old_data = "";
		   my $count=0;
		   $chunks++;
		   my $max= scalar(@lines);
		   foreach my $entry (@lines){
		     $count++;
		     my @fields = split(/\t/,$entry);
		     next if (!length($entry));
		     if($count == $max){ # possible incomplete line
		       $old_data = $entry;
		       next;
		     }
		     elsif($count > $max){
		       die "What the celery is going on here";
		     }
		     else{
		       $line_count++;
		       my $mgi_id = $fields[0];
		       if(!($mgi_id =~ /MGI:/)){
			 print "PROB1:$data_line\n";
			 print "PROB2:".join(', ',@fields)."\n";
		       }
		       $symbols{$mgi_id}=$fields[1];
		       $ensembl_ids{$mgi_id}=$fields[5];
		       $status{$mgi_id} = 1 if ($status{$mgi_id} eq '');
		       
		       if ($status{$mgi_id} < 4 && $fields[4] == 1){
			 $status{$mgi_id} = 4;
		       }
		       elsif ($status{$mgi_id} < 3 && $fields[3] == 1){
			 $status{$mgi_id} = 3;
		       }
		       elsif ($status{$mgi_id} < 2 && $fields[2] == 1){
			 $status{$mgi_id} = 2;#		     print "$data";
		       }
		     }
		   }	
		 }
		 else {
		   warn ("Problems with the web server: ".$response->status_line);
		   return 1;
		 }
	       },1000);

#  print "Number of chunks is $chunks\n";
  if($old_data){
    my @fields = split(/\t/,$old_data);

    $line_count++;
    #		     chop $line[5];
    my $mgi_id = $fields[0];
    if(!($mgi_id =~ /MGI:/)){
      print "PROB3:$old_data\n";
      print "PROB4:".join(', ',@fields)."\n";
    }
    $symbols{$mgi_id}=$fields[1];
    $ensembl_ids{$mgi_id}=$fields[5];
    $status{$mgi_id} = 1 if ($status{$mgi_id} eq '');
    if ($status{$mgi_id} < 4 && $fields[4] == 1){
      $status{$mgi_id} = 4;
    }
    elsif ($status{$mgi_id} < 3 && $fields[3] == 1){
      $status{$mgi_id} = 3;
    }
    elsif ($status{$mgi_id} < 2 && $fields[2] == 1){
      $status{$mgi_id} = 2;#		     print "$data";
    }
  }
#  print "obtained $line_count lines\n";

  my $parsed_count = 0;
  my $direct_count = 0;
  foreach my $acc (keys %symbols){
    my $source_id;
    $source_id = $type2id{'No products available yet'} if $status{$acc} == 1;
    $source_id = $type2id{'Vector available'} if $status{$acc} == 2;
    $source_id = $type2id{'ES cells available'} if $status{$acc} == 3;
    $source_id = $type2id{'Mice available'} if $status{$acc} == 4;
    
    my $label = $symbols{$acc} || $acc;
    my $ensembl_id = $ensembl_ids{$acc};
    #    print OUT "$acc\t$symbols{$acc}\t$description\t$ensembl_ids{$acc}\n";
    my $type        = 'gene';

    
    ++$parsed_count;
    
    my $xref_id =
      XrefParser::BaseParser->get_xref( $acc, $source_id, $species_id );
      
    if ( !defined($xref_id) || $xref_id eq '' ) {
      $xref_id =
	XrefParser::BaseParser->add_xref(
					 $acc,   undef,   $label,
					 '', $source_id, $species_id, "DIRECT"
					);
    }
    next if(!defined($ensembl_ids{$acc}));
    $direct_count++;
    XrefParser::BaseParser->add_direct_xref( $xref_id, $ensembl_id,
					     $type, $acc );
  }
  printf( "%d  xrefs succesfully parsed and %d direct xrefs added\n", $parsed_count, $direct_count );
  
  return 0;
} ## end sub run

1;
