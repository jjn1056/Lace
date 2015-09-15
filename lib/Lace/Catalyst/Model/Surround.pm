package Lace::Catalyst::Model::Surround;

use Moose;
extends 'Catalyst::Model';

sub transform {
  my ($self, $view, $fb, %args) = @_;
  my $target = $args{target} || 'content';

  $fb->collect({ into => \my @body })
    ->run;

  my $with = $view->retrieve_document($args{with});


  return $with->select("*[id=$target]")
    ->replace_content(\@body);
}

__PACKAGE__->meta->make_immutable;
