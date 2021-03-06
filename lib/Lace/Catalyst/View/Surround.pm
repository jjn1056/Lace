package Lace::Catalyst::View::Surround;

use Moo;
extends 'Catalyst::View';

sub transform {
  my ($self, $view, $zoom, %args) = @_;
  my $target = $args{target} || 'content';
  my $with = $view->retrieve_document($args{with});

  return $with->select("*[id=$target]")
    ->replace_content($zoom->to_events);
}

1;
