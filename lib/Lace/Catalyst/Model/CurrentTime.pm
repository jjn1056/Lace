package Lace::Catalyst::Model::CurrentTime;

use Moose;
extends 'Catalyst::Model';

sub transform {
  my ($self, $view, $zoom) = @_;
  return $zoom->from_html(scalar localtime);
}

__PACKAGE__->meta->make_immutable;
