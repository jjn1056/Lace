package Lace::Catalyst::Model::ViewData;

use Moo;
 
extends 'Catalyst::Model';
with 'Catalyst::Component::InstancePerContext';
with 'Data::Perl::Role::Collection::Hash';
 
sub build_per_context_instance {
  my ($self, $c, %args) = @_;
  return $self->new(%args);
}
 
sub TO_JSON { +{shift->elements} }
 
sub AUTOLOAD {
  my ($self, @args) = @_;
  my $key = our $AUTOLOAD;
  $key =~ s/.*:://;
  return scalar(@args) ?
    $self->set($key, @args)
      : $self->get($key);
}
  
sub DESTROY {}
 
1;
 
