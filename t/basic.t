use Test::Most;

{
  package MyApp::View::UserNameList;

  use Moo;
  extends 'Catalyst::Model';

  sub transform {
    my ($self, $view, $zoom, %args) = @_;
    return $zoom->select('ul')->fill('*[id=name]' => $args{names} );
  }

  package MyApp::Controller::Root;
  $INC{'MyApp/Controller/Root.pm'} = __FILE__;

  use Moose;
  use MooseX::MethodAttributes;

  extends 'Catalyst::Controller';

  sub now :Local Args(0) { 
    my ($self, $c) = @_;
    $c->view->send_http_ok({
      current_time=>scalar(localtime),
      users => [ qw/a b c d/ ],
    });
  }

  sub page :Local Args(0) {
    my ($self, $c) = @_;
    $c->view->send_http_ok({
      title => "first page",
      header => "Summary",
      body => "Summary Body goes here",
    });
  }

  package MyApp;
  use Catalyst;
  use Path::Class::Dir;

__PACKAGE__->inject_components(
  'View::HTML' => { from_component => 'Lace::Catalyst::View'});

  MyApp->config(
  'root' => Path::Class::Dir->new('./t'),
  'default_view' => 'HTML',
  'Controller::Root' => { namespace=>'' });

  MyApp->setup;
}

use Catalyst::Test 'MyApp';

{
  ok my $res = request '/page';
  warn $res->content;
}

{
  ok my $res = request '/now';
  warn $res->content;
}

done_testing;

__END__

  $c->view->data->set(title=>"Hello World");

  $c->view->id('page')->title("Hello World");
  $c->view->send_http_ok;

    $c->view
      ->wrapper
        ->page
          ->title("Hi There!");

    $c->view->$_tap(
      ->page->$_tap( title=>"HW'))
      
    $c->view
      ->page
        ->title("Hello World")
        ->up
      ->summary
        ->header("My Summary")
        ->body("More stuff")
        ->up
      ->groceries
        ->add_item("Milk")
        ->add_item("Eggs", "Cheese")
        ->order_alphabetical
        ->order_desc
        ->up
      ->send_http_ok;


    $c->view
      ->page("Hello World")
      ->summary("My Summary" => "More and More stuff");
      ->groceries("Milk","Eggs", "Cheese")
      ->send_http_ok;


    $c->view->send_http_ok(
      page => "Hello World",
      summary => {"My Summary" => "More and More stuff"},
      groceries => ["Milk","Eggs", "Cheese"]);


