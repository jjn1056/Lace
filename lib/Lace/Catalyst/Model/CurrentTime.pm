package Lace::Catalyst::Model::CurrentTime;

use Moose;
extends 'Catalyst::Model';

sub transform {
  my ($self, $view, $fb) = @_;
  return $fb->replace_content(scalar localtime);
}

__PACKAGE__->meta->make_immutable;
