package Lace::Catalyst::View::Section;

use Moo;
extends 'Catalyst::View';

sub transform {
  my ($self, $view, $zoom, %args) = @_;
  return $zoom
    ->select('h1')
    ->replace_content($args{header})
    ->select('p')
    ->replace_content($args{body});
}

1;

