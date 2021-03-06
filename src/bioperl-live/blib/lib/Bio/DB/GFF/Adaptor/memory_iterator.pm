=head1 NAME

Bio::DB::GFF::Adaptor::memory_iterator - iterator for Bio::DB::GFF::Adaptor::memory

=head1 SYNOPSIS

For internal use only

=head1 DESCRIPTION

This is an internal module that is used by the Bio::DB::GFF in-memory
adaptor to return an iterator across a sequence feature query.  The
object has a single method, next_feature(), that returns the next
feature from the query.  The method next_seq() is an alias for
next_feature().

=head1 BUGS

None known yet.

=head1 SEE ALSO

L<Bio::DB::GFF>,

=head1 AUTHOR

Lincoln Stein E<lt>lstein@cshl.orgE<gt>.

Copyright (c) 2001 Cold Spring Harbor Laboratory.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

package Bio::DB::GFF::Adaptor::memory_iterator;
use strict;
# $Id: memory_iterator.pm,v 1.4.2.1 2003/07/05 00:52:31 lstein Exp $
# this module needs to be cleaned up and documented

#use constant STH         => 0;
#use constant CALLBACK    => 1;
#use constant CACHE       => 2;

*next_seq = \&next_feature;

sub new {
  my $class = shift;
  my ($data,$callback) = @_;
  my $pos = 0;
  return bless {data     => $data,
		pos      => $pos,
		callback => $callback,
                cache    => []},$class;
  #return bless [$sth,$callback,[]],$class;
}

sub next_feature {
  my $self = shift;
  return shift @{$self->{cache}} if @{$self->{cache}};

  my $data     = $self->{data} or return;
  my $callback = $self->{callback};

  my $features;
  while (1) {
    my $feature = $data->[$self->{pos}++];
    if ($feature) {
      $features   = $callback->(@{$feature});
      last if $features;
    } else {
      $features = $callback->();
      undef $self->{pos};
      undef $self->{data};
      undef $self->{cache};
      last;
    }
  }
  $self->{cache} = $features or return;
  shift @{$self->{cache}};
}

1;
