package Lace::Catalyst::Model::OrderedList;

use Moo;
extends 'Catalyst::Model';

sub transform {
  my ($self, $view, $zoom, %args) = @_;
    return $zoom->select('ol')->repeat_content([
      map {
        my $item = $_;
        sub { $_->select('li')->replace_content($item) },
      } @{$args{items}}
    ]);
}

1;
