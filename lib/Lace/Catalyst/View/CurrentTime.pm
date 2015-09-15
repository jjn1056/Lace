package Lace::Catalyst::View::CurrentTime;

use Moose;
extends 'Catalyst::View';

sub transform {
  my ($self, $view, $zoom) = @_;
  return $zoom->from_html(scalar localtime);
}

__PACKAGE__->meta->make_immutable;
