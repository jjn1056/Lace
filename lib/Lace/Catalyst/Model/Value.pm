package Lace::Catalyst::Model::Value;

use Moose;
extends 'Catalyst::Model';

sub transform {
  my ($self, $view, $fb, %args) = @_;
  my $value = $args{value};
  if(ref \$value eq 'SCALAR') {
    return $fb->replace_content($value);
  } elsif(ref $value eq 'ARRAY') {
    return $fb->fill(($args{at}||die("Missing 'at' parameter")) => $value);
  }
}

__PACKAGE__->meta->make_immutable;
