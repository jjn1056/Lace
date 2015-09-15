package Lace::Catalyst::Model::Include;

use Moose;
extends 'Catalyst::Model';

sub transform {
  my ($self, $view, $zoom, %args) = @_;
  return $args{src};
}

__PACKAGE__->meta->make_immutable;
