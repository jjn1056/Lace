package Lace::Catalyst::View::Page;

use Moo;
extends 'Catalyst::View';

sub transform {
  my ($self, $view, $zoom, %args) = @_;
  return $zoom->select('title')->replace_content($args{title})
}

1;
