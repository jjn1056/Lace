package Lace::Catalyst::Model::Section;

use Moo;
extends 'Catalyst::Model';

sub transform {
  my ($self, $view, $fb, %args) = @_;
  return $fb
    ->repeat_content([ sub { $_->select('h1')->replace_content($args{header}) } ])
    ->then
    ->repeat_content([ sub { $_->select('p')->replace_content($args{body}) } ]);

}

1;
