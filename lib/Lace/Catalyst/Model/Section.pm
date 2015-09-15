package Lace::Catalyst::Model::Section;

use Moo;
use HTML::Zoom;

extends 'Catalyst::Model';

sub transform {
  my ($self, $view, $zoom, %args) = @_;
  return $zoom
    ->select('h1')
    ->replace_content($args{header})
    ->select('p')
    ->replace_content($args{body});
}

1;

