package Lace::Catalyst::View::Value;

use Moo;
extends 'Catalyst::View';

sub transform {
  my ($self, $view, $zoom, %args) = @_;
  my $value = $args{value};
  $zoom->from_html($value)
}

1;
