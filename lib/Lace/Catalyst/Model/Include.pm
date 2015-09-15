package Lace::Catalyst::Model::Include;

use Moose;
extends 'Catalyst::Model';

sub transform {
  my ($self, $view, $fb, %args) = @_;
  return $fb->append_content($args{src});
}

__PACKAGE__->meta->make_immutable;
