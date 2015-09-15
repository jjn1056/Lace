package Lace::Catalyst::Model::Page;

use Moo;
extends 'Catalyst::Model';

sub transform {
  my ($self, $view, $zoom, %args) = @_;
  return $zoom->select('title')->replace_content($args{title})
}

1;
