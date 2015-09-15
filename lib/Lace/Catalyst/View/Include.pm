package Lace::Catalyst::View::Include;

use Moose;
extends 'Catalyst::View';

sub transform {
  my ($self, $view, $zoom, %args) = @_;
  return $args{src};
}

__PACKAGE__->meta->make_immutable;
