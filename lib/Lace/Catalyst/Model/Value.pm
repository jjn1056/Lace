package Lace::Catalyst::Model::Value;

use Moo;
extends 'Catalyst::Model';

sub transform {
  my ($self, $view, $zoom, %args) = @_;
  my $value = $args{value};
  $zoom->from_html($value)
}

1;
