package Lace::Catalyst::View::_PerRequest;
  
use Moo;
use HTTP::Status;
use Data::Visitor::Callback;

extends 'Catalyst::View';

has 'parent_view' => (is=>'ro', required=>1);
has 'ctx' => (is=>'ro', required=>1);
has 'template' => (
  is=>'rw',
  required=>1,
  lazy=>1,
  default=>sub { shift->ctx->action.".html" });

has 'data' => (
  is => 'rw',
  required =>1,
  lazy =>1,
  default => sub { shift->ctx->model("ViewData") },
  );

sub transform {
  my ($self, $document) = @_;

  # $document = [$zoom, \%uuid]  %uuid  => { $id, $class, \%conf }}

  my $zoom = $document->[0];
  my %uuid = %{$document->[1]};

  foreach my $uuid (sort keys %uuid) {

    my $fb = $zoom->select("*[data-lace-uuid=$uuid]");
    my $class = $uuid{$uuid}{class};
    my %conf =  %{$uuid{$uuid}{conf}};

    Data::Visitor::Callback->new(plain_value => sub {
      my $val = pop;
      if(my $var = ($val=~m/^\$(.+)$/)[0]) {
        $_ = $self->data->$var;
      } elsif(my $var2 = ($val=~m/^file\:(.+)$/)[0]) {
        if(my $file = $self->retrieve_document($var2)) {
          $_ = $file;
        }
      }
    })->visit(%conf);

    $self->ctx->log->debug("transforming class $class ($uuid) in ${\$self->template}")
      if ref($self->ctx)->debug;

    $fb->collect({into=>\my @body})->run;
    my $new_zoom =  HTML::Zoom->new({zconfig=>$fb->_zconfig})
      ->from_events(\@body);

    $new_zoom = ($self->ctx->view($class) || die "There is no view '$class'")
      ->transform($self, $new_zoom, %conf);

    $zoom = $fb->replace($new_zoom);

    $self->ctx->log->debug("transforming completed")
      if ref($self->ctx)->debug;
  }

  return $zoom->select("*[data-lace-uuid]")
    ->remove_attribute('data-lace-uuid');
}

sub retrieve_document {
  my ($self, $path) = @_;
  if(my $document = $self->parent_view->_map->{$path}) {
    return $self->transform($document);
  } else {
    die "No document for $path";
  }
}

# Send Helpers.
foreach my $helper( grep { $_=~/^http/i} @HTTP::Status::EXPORT_OK) {
  my $subname = lc $helper;
  eval "sub send_$subname { return shift->send(HTTP::Status::$helper,\@_) }";
}

sub send {    
  my ($self, @proto) = @_;
  my ($status, @headers) = ();
  
  if(ref \$proto[0] eq 'SCALAR') {
    $status = shift @proto;
  } else {
    $status = 200;
  }

  if(ref $proto[$#proto] eq 'HASH') {
    my $var = pop @proto;
    foreach my $key (keys %$var) {
      $self->data->$key($var->{$key});
    }
  }

  if(@proto) {
    @headers = @{$proto[0]};
  }
  
  $self->ctx->res->status($status) if $status;
  $self->ctx->res->headers->push_headers(@headers) if @headers;
  
  my $lace = $self->retrieve_document($self->template);
  
  $self->ctx->res->content_type('text/html');
  
  if($self->ctx->res->has_body) {
    $self->ctx->res->write( $self->ctx->res->body->to_zoom->to_html);
    $self->ctx->res->write($lace->to_html);
    $self->ctx->res->body(undef);
  } else {
    $self->ctx->res->body($lace->to_fh);
  }

  $self->ctx->stats->profile(begin => "=> View->send". ($status ? "($status)": ''))
    if $self->ctx->debug;

  return $lace;
}

1;
