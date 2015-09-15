package Lace::Catalyst::Model::Page;

use Moo;
extends 'Catalyst::Model';

sub transform {
  my ($self, $view, $fb, %args) = @_;
  return $fb->repeat([ sub {
    $_->select('title')->replace_content($args{title});
      }]);
}

1;
