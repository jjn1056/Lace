package Lace::Catalyst::View;

use HTML::Zoom;
use HTML::Zoom::FilterBuilder::Template;
use HTML::Zoom::FilterBuilder::Fill;
use HTML::Zoom::FilterBuilder::GetAttribute;
use HTML::Zoom::FilterBuilder::ApplyResultSet;

use Moo;
use Lace::Catalyst::View::_PerRequest;
use Catalyst::Utils;
use JSONY;

extends 'Catalyst::View';
with 'Catalyst::Component::InstancePerContext';

our @DEFAULT_MODELS = (qw/
  Lace::Catalyst::Model::ViewData
  Lace::Catalyst::Model::Value
  Lace::Catalyst::Model::Surround
  Lace::Catalyst::Model::Include
  Lace::Catalyst::Model::Page
  Lace::Catalyst::Model::Section
  Lace::Catalyst::Model::OrderedList
  Lace::Catalyst::Model::CurrentTime/);
 
has _map => (is=>'ro', required=>1);

sub COMPONENT {
  my ($class, $app, $args) = @_;

  $args = $class->merge_config_hashes($class->config, $args);
  $args->{_map} = +{$class->create_documents($app)};

  if($app->debug) {
    $app->log->debug( "Lace Document Root Directory: '${\$app->config->{root}}'\n" );
    my $column_width = Catalyst::Utils::term_width() - 6;
    my $t = Text::SimpleTable->new($column_width);
    $t->row($_) for keys %{$args->{_map}};
    $app->log->debug( "Loaded Lace Documents\n" . $t->draw . "\n" );
  }

  $class->inject_default_models($app, @DEFAULT_MODELS);

  return $class->new($app, $args);
}

sub inject_default_models {
  my ($class, $app, @models) = @_;
  foreach my $model(@models) {
    $app->setup_injected_component(
      Catalyst::Utils::class2classsuffix($model),
      +{ from_component => $model});
  }
}

sub next_uuid { our $cnt = ++$cnt }
sub jsony { our $jsony ||= JSONY->new }

sub create_documents {
  my ($class, $app) = @_;
  my @templates = $class->find_template_paths($app->config->{root});

  my %map = map {

    # Something an action can match.
    my $match_path = $_->relative($app->config->{root})->stringify;

    # First, find all data-lace-class and assign a 'uuid'
    my @uuids = ();
    my $zoom = HTML::Zoom->from_file("$_")
      ->select('*[data-lace-class]')
      ->transform_attribute( 'data-lace-uuid' => sub { my $uuid = $class->next_uuid; push @uuids, $uuid; $uuid;  })
      ->memoize;

    # Look for and get all the named
    my %info;
    foreach my $uuid (@uuids) {
      $zoom->select("*[data-lace-uuid=$uuid]")
        ->get_attribute('data-lace-class', \my @class)
        ->then
        ->get_attribute('data-lace-conf', \my @conf)
        ->then
        ->get_attribute('data-lace-id', \my @id)
        ->run;


        my %conf = map { %$_ } 
        map { defined $_ ? $class->jsony->load($_) : () }
          @conf;

      $info{$uuid} = +{
        id => shift @id,
        class => shift @class,
        conf => \%conf};
    }      

    # Cleanup
    $zoom = $zoom->select("*[data-lace-class]")
      ->remove_attribute('data-lace-class')
      ->select('*[data-lace-conf]')
      ->remove_attribute('data-lace-conf')
      ->select('*[data-lace-id]')
      ->remove_attribute('data-lace-id');

    $match_path => [$zoom, \%info];
    
  } @templates;

  use Devel::Dwarn;
  Dwarn keys %map;
  Dwarn map {$_->[1] } values %map;
  Dwarn map {$_->[0]->to_html } values %map;

  return %map;
}

sub find_template_paths {
  my ($class, $root) = @_;
  my @templates;
  $root->recurse(callback=>sub {
      my $class = shift;
      push @templates, $class
        if (!$class->is_dir && $class->basename =~/\.html$/);
    });

  return @templates;
}

sub build_per_context_instance {
  my ($self, $c, @args) = @_;
  #use Devel::Dwarn;  Dwarn @args;
  return Lace::Catalyst::View::_PerRequest->new(
    parent_view=>$self,
    ctx=>$c);
}

1;
