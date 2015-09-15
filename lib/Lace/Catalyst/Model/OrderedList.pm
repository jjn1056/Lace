package Lace::Catalyst::Model::OrderedList;

use Moo;
extends 'Catalyst::Model';

sub transform {
  my ($self, $view, $fb, %args) = @_;
    return $fb->repeat_content([
      map {
        my $item = $_;
        sub { $_->select('li')->replace_content($item) },
      } @{$args{items}}
    ]);
}

1;
