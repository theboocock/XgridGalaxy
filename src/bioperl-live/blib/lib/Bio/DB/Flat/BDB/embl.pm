#
# $Id: embl.pm,v 1.4 2002/10/22 07:38:31 lapp Exp $
#
# BioPerl module for Bio::DB::Flat::BDB
#
# Cared for by Lincoln Stein <lstein@cshl.org>
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::DB::Flat::BDB::embl - embl adaptor for Open-bio standard BDB-indexed flat file

=head1 SYNOPSIS

See Bio::DB::Flat.

=head1 DESCRIPTION

This module allows embl files to be stored in Berkeley DB flat files
using the Open-Bio standard BDB-indexed flat file scheme.  You should
not be using this directly, but instead use it via Bio::DB::Flat.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to one
of the Bioperl mailing lists.  Your participation is much appreciated.

  bioperl-l@bioperl.org             - General discussion
  http://bioperl.org/MailList.shtml - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
the bugs and their resolution.  Bug reports can be submitted via
email or the web:

  bioperl-bugs@bio.perl.org
  http://bugzilla.bioperl.org/

=head1 AUTHOR - Lincoln Stein

Email - lstein@cshl.org

=head1 SEE ALSO

L<Bio::DB::Flat>,

=cut

package Bio::DB::Flat::BDB::embl;

use strict;
use Bio::DB::Flat::BDB;
use vars '@ISA';

@ISA = qw(Bio::DB::Flat::BDB);

sub parse_one_record {
  my $self  = shift;
  my $fh    = shift;
  my $parser =
    $self->{embl_cached_parsers}{fileno($fh)} ||= Bio::SeqIO->new(-fh=>$fh,-format=>$self->default_file_format);
  my $seq = $parser->next_seq;
  my $ids = $self->seq_to_ids($seq);
  return $ids;
}

sub seq_to_ids {
  my $self = shift;
  my $seq  = shift;

  my $display_id = $seq->display_id;
  my $accession  = $seq->accession_number;
  my %ids;
  $ids{ID}       = $display_id;
  $ids{ACC}      = $accession   if defined $accession;
  return \%ids;
}

sub default_primary_namespace {
  return "ID";
}

sub default_secondary_namespaces {
  return qw(ACC);
}

sub default_file_format { "embl" }


1;
