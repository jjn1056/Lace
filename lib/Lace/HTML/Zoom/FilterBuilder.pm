package Lace::HTML::Zoom::FilterBuilder;

use warnings;
use strict;

use base 'HTML::Zoom::FilterBuilder';

=head2 get_attribute

Given the name of an attribute at the top of a selection, return it.  If the
select has more than one match, return each value into an array:

    my $zoom = HTML::Zoom->from_html(<<HTML);
      <body>
        <p data-zoom="Poets">
          <div>aaa</div>
          <div data-zoom="Users1">bbb</div>
        </p>
        <div data-zoom="Users2">ccc</div>
        <div data-zoom="Users3">ddd</div>
      </body>
    HTML

    $zoom->select('*[data-zoom]')
      ->get_attribute('data-zoom', \my @data)
      ->run;

    ## @data = ('Poets','Users1', 'Users2', 'Users3');

Similar in spirit to L</collect> but for attributes instead of content.

=cut

sub get_attribute {
  my ($self, $attr, $return_array) = @_;
  return sub {
    push @$return_array, $_[0]->{attrs}->{$attr};
    return $_[0];
  };
}

=head2 get_attribute

Given the name of an attribute at the top of a selection, return it.  If the
select has more than one match, return each value into an array:

    my $zoom = HTML::Zoom->from_html(<<HTML);
      <body>
        <p data-zoom="Poets">
          <div>aaa</div>
          <div data-zoom="Users1">bbb</div>
        </p>
        <div data-zoom="Users2">ccc</div>
        <div data-zoom="Users3">ddd</div>
      </body>
    HTML

    $zoom->select('*[data-zoom]')
      ->get_attribute('data-zoom', \my @data)
      ->run;

    ## @data = ('Poets','Users1', 'Users2', 'Users3');

Similar in spirit to L</collect> but for attributes instead of content.

=cut

sub apply_resultset {
  my ($self, $resultset) = @_;
  return my $hz = $self->fill(
    [$resultset->result_source->columns],
    $resultset->all);
}

=head2 fill

Mega fill tool

http://git.shadowcat.co.uk/gitweb/gitweb.cgi?p=catagits/HTML-Zoom.git;a=blob;f=t/fill.t;h=dbc9f25ad5159ecaf0135604c50066092a7d5d7f;hb=a023c7128887766a825de1205da02434a08bab32

    ## $fill( \@target, @list[\@values] )
    ## fill a selection from an array of targets, using a list.  Syntax is a bit
    ## like DBIC->populate, the first argument is an array of css style selectors
    ## while the remaining list is a list of arrayrefs where each arrayref item
    ## matches the expected value for the cooresponding css selection in $target
    
    {
      ok my $z = HTML::Zoom
        ->from_html(q[<ul><li class="even">Even</li><li class="odd">Odd</li></ul>])
        ->select('ul')
        ->$fill(
          ['.even','.odd'],
          [0,1],
          [2,3],
        ), 'Made Zoom object from array';
        
      is(
        $z->to_html,
        '<ul><li class="even">0</li><li class="odd">1</li><li class="even">2</li><li class="odd">3</li></ul>',
        'Got correct from repeat_content'
      );  
    }

    ## $fill( \@target, \&code ) 
    ## Same as above but using an iterator coderef instead of a pregenerated list 
    {
      my @items = ( [0,1], [2,3] );
      ok my $z = HTML::Zoom
        ->from_html(q[<ul><li class="even">Even</li><li class="odd">Odd</li></ul>])
        ->select('ul')
        ->$fill(
          ['.even','.odd'],
          sub { shift @items }
        ), 'Made Zoom object from itr';
        
      for my $cnt (1..2) {
        is(
          $z->to_html,
          '<ul><li class="even">0</li><li class="odd">1</li><li class="even">2</li><li class="odd">3</li></ul>',
          'Got correct from repeat_content: '.$cnt
        );
        ok(
           (@items = ( [0,1], [2,3] )),
           'Reset the items array'
        );
      }
    }

    ## $fill( \@targets[\%pair[$selector, \&code]], @list[\@values] )
    ## Target has a value of a coderef that is expected to take the item from the
    ## list of data and provide the actual value that goes into the target
    
    {
      ok my $z = HTML::Zoom
        ->from_html(q[<ul><li class="even">Even</li><li class="odd">Odd</li></ul>])
        ->select('ul')
        ->$fill(
          [
            {'.even' => sub { my ($i,$cnt,$z) = @_; return $i->[0]; } },
          {'.odd' => sub { my ($i,$cnt,$z) = @_; return $i->[1]; } },         
        ],
        [0,1],
        [2,3],
      ), 'Made Zoom object from code style';

    for my $cnt (1..2) {
      is(
        $z->to_html,
        '<ul><li class="even">0</li><li class="odd">1</li><li class="even">2</li><li class="odd">3</li></ul>',
        'Got correct from repeat_content: '.$cnt
      );
    }
  }
  
  ## $fill( \@targets[\%pair[$selector, \&code]], @list[\%values] )
  ## Like above but showing how this can be used to get a value from any type of
  ## list item.
  
  {
    ok my $z = HTML::Zoom
      ->from_html(q[<ul><li class="even">Even</li><li class="odd">Odd</li></ul>])
      ->select('ul')
      ->$fill(
        [
          {'.even' => sub { my ($i,$cnt,$z) = @_; return $i->{even}; } },
          {'.odd' => sub { my ($i,$cnt,$z) = @_; return $i->{odd}; } },         
        ],
        { even => 0, odd => 1},
        { even => 2, odd => 3},        
      ), 'Made Zoom object from code style';

    for my $cnt (1..2) {
      is(
        $z->to_html,
        '<ul><li class="even">0</li><li class="odd">1</li><li class="even">2</li><li class="odd">3</li></ul>',
        'Got correct from repeat_content: '.$cnt
      );
    }
  }

  ## As above example, but showing how you can an anonymous subroutine in a
  ## reusable way.  This technique makes the power of closures possible.  Also
  ## since the current $zoom is passed, opens the possibility for recursivity.
  
  {
    ok my $even_or_odd = sub {
      my ($i,$cnt,$z) = @_;
      return $cnt % 2 ? $i->{odd} : $i->{even};
    };
    
    ok my $z = HTML::Zoom
      ->from_html(q[<ul><li class="even">Even</li><li class="odd">Odd</li></ul>])
      ->select('ul')
      ->$fill(
        [
          {'.even' => $even_or_odd },
          {'.odd' => $even_or_odd },         
        ],
        { even => 0, odd => 1},
        { even => 2, odd => 3},        
      ), 'Made Zoom object from code style';

    for my $cnt (1..2) {
      is(
        $z->to_html,
        '<ul><li class="even">0</li><li class="odd">1</li><li class="even">2</li><li class="odd">3</li></ul>',
        'Got correct from repeat_content: '.$cnt
      );
    }
  }

  ## Just an example of above showing off how you can use Perl to generate the
  ## needed structures.  Does the same thing as the above example.
  
  {
    ok my $even_or_odd = sub {
      my ($i,$cnt,$z) = @_;
      return $cnt % 2 ? $i->{odd} : $i->{even};
    };
    
    ok my $z = HTML::Zoom
      ->from_html(q[<ul><li class="even">Even</li><li class="odd">Odd</li></ul>])
      ->select('ul')
      ->$fill(
        [
          map { +{$_ => $even_or_odd} } qw(.even .odd),
        ],
        { even => 0, odd => 1},
        { even => 2, odd => 3},        
      ), 'Made Zoom object from code style';

    for my $cnt (1..2) {
      is(
        $z->to_html,
        '<ul><li class="even">0</li><li class="odd">1</li><li class="even">2</li><li class="odd">3</li></ul>',
        'Got correct from repeat_content: '.$cnt
      );
    }
  }
  
  ## $fill( \@targets[\%pair[$selector, \&code]], @list[$object] )
  ## using a list of objects, we get replace values.
  
  {
    {
      package Test::HTML::Zoom::EvenOdd;
        
      sub new {
        my $class = shift;
        bless { _e=>$_[0], _o=>$_[1] }, $class; 
      }
        
      sub even { shift->{_e} }
      sub odd { shift->{_o} }
    }
    
    ok my $even_or_odd = sub {
      my ($i,$cnt,$z) = @_;
      return $cnt % 2 ? $i->odd : $i->even;
    };
    
    ok my $z = HTML::Zoom
      ->from_html(q[<ul><li class="even">Even</li><li class="odd">Odd</li></ul>])
      ->select('ul')
      ->$fill(
        [
          map { +{$_ => $even_or_odd} } qw(.even .odd),
        ],
        Test::HTML::Zoom::EvenOdd->new(0,1),
        Test::HTML::Zoom::EvenOdd->new(2,3),
      ), 'Made Zoom object from code style';

    for my $cnt (1..2) {
      is(
        $z->to_html,
        '<ul><li class="even">0</li><li class="odd">1</li><li class="even">2</li><li class="odd">3</li></ul>',
        'Got correct from repeat_content: '.$cnt
      );
    }
  }

  ## fill( \@targets[\%pair[$selector, $key_or_accessor]], @list[\%values] )
  ## Looks a lot like how pure.js uses 'directives' to map a selector to a value
  ## from each item in the data list.  In this example the value part of the
  ## \@targets pair is a scalar that should be the name of a key (for hashref
  ## values) or an accessor (as in below example) when the @list is of $objects.
  
  {
    ok my $z = HTML::Zoom
      ->from_html(q[<ul><li class="even">Even</li><li class="odd">Odd</li></ul>])
      ->select('ul')
      ->$fill(
        [
          { '.even' => 'even'},
          { '.odd' => 'odd'},
        ],
        { even => 0, odd => 1},
        { even => 2, odd => 3},        
      ), 'Made Zoom object from declare accessors style';

    for my $cnt (1..2) {
      is(
        $z->to_html,
        '<ul><li class="even">0</li><li class="odd">1</li><li class="even">2</li><li class="odd">3</li></ul>',
        'Got correct from repeat_content: '.$cnt
      );
    }
  }

  ## fill( \@targets[\%pair[$selector, $key_or_accessor]], @list[$object] )
  ## As above example, but with objects instead of plain hashrefs.
  {
    ok my $z = HTML::Zoom
      ->from_html(q[<ul><li class="even">Even</li><li class="odd">Odd</li></ul>])
      ->select('ul')
      ->$fill(
        [
          { '.even' => 'even'},
          { '.odd' => 'odd'},
        ],
        Test::HTML::Zoom::EvenOdd->new(0,1),
        Test::HTML::Zoom::EvenOdd->new(2,3),        
      ), 'Made Zoom object from declare accessors style';

    for my $cnt (1..2) {
      is(
        $z->to_html,
        '<ul><li class="even">0</li><li class="odd">1</li><li class="even">2</li><li class="odd">3</li></ul>',
        'Got correct from repeat_content: '.$cnt
      );
    }
  }

  ## fill( \%targets, @list[$object] )
  ## Ideally the targets are an array so that you properly control the order that
  ## the replaces happen, but if you don't care you can take advantage of the
  ## shorthand target structure of a hashref
  
  {
    ok my $z = HTML::Zoom
      ->from_html(q[<ul><li class="even">Even</li><li class="odd">Odd</li></ul>])
      ->select('ul')
      ->$fill(
        {
          '.even' => 'even',
          '.odd' => 'odd'
        },
        Test::HTML::Zoom::EvenOdd->new(0,1),
        Test::HTML::Zoom::EvenOdd->new(2,3),        
      ), 'Made Zoom object from declare accessors style';

    for my $cnt (1..2) {
      is(
        $z->to_html,
        '<ul><li class="even">0</li><li class="odd">1</li><li class="even">2</li><li class="odd">3</li></ul>',
        'Got correct from repeat_content: '.$cnt
      );
    }
  }
  
  ## Helper for when you have a list of object or hashs and you just want to map
  ## target classes to accessors.  Otherwise as above example.
  
  {
    ok my $z = HTML::Zoom
      ->from_html(q[<ul><li class="even">Even</li><li class="odd">Odd</li></ul>])
      ->select('ul')
      ->$fill(
        { map { ".".$_ => $_ } qw(even odd) },
        Test::HTML::Zoom::EvenOdd->new(0,1),
        Test::HTML::Zoom::EvenOdd->new(2,3),        
      ), 'Made Zoom object from declare accessors style';

    for my $cnt (1..2) {
      is(
        $z->to_html,
        '<ul><li class="even">0</li><li class="odd">1</li><li class="even">2</li><li class="odd">3</li></ul>',
        'Got correct from repeat_content: '.$cnt
      );
    }
  }

  ## fill( \@targets, @list[$object_or_hashref])
  ## if the target is arrayref but the data is a list of objects or hashes, we
  ## guess the target is a class form of the target items, but use the value of
  ## the item as the hash or object accessor
  
  {
    ok my $z = HTML::Zoom
      ->from_html(q[<ul><li class="even">Even</li><li class="odd">Odd</li></ul>])
      ->select('ul')
      ->$fill(
        [qw(even odd)],
        Test::HTML::Zoom::EvenOdd->new(0,1),
        Test::HTML::Zoom::EvenOdd->new(2,3),        
      ), 'Made Zoom object from declare accessors style';

    for my $cnt (1..2) {
      is(
        $z->to_html,
        '<ul><li class="even">0</li><li class="odd">1</li><li class="even">2</li><li class="odd">3</li></ul>',
        'Got correct from repeat_content: '.$cnt
      );
    }
  }
  
  ## Using above shortcut with iterator instead of fixed list

  {
    my @list = (
      Test::HTML::Zoom::EvenOdd->new(0,1),
      Test::HTML::Zoom::EvenOdd->new(2,3),         
    );
    
    ok my $z = HTML::Zoom
      ->from_html(q[<ul><li class="even">Even</li><li class="odd">Odd</li></ul>])
      ->select('ul')
      ->$fill(
        [qw(even odd)],
        sub { shift @list },       
      ), 'Made Zoom object from declare accessors style';

    is(
      $z->to_html,
      '<ul><li class="even">0</li><li class="odd">1</li><li class="even">2</li><li class="odd">3</li></ul>',
      'Got correct from repeat_content',
    );
  }
}

=cut

use Scalar::Util ();

my $next_item_from_array = sub {
  my @items = @_;
  return sub { shift @items };      
};

my $next_item_from_proto = sub {
  my $proto = shift;
  if (
    ref $proto eq 'ARRAY' ||
    ref $proto eq 'HASH' ||
    Scalar::Util::blessed($proto)
  ) {
    return $next_item_from_array->($proto, @_);
  } elsif(ref $proto eq 'CODE' ) {
    return $proto;
  } else {
    die "Don't know what to do with $proto, it's a ". ref($proto);
  }
};

my $normalize_targets = sub {
  my $targets = shift;
  my $targets_type = ref $targets;
  return $targets_type eq 'ARRAY' ? $targets
    : $targets_type eq 'HASH' ? [ map { +{$_=>$targets->{$_}} } keys %$targets ]
      : die "targets data structure ". ref($targets). " not understood";
};

my $replace_from_hash_or_object = sub {
  my ($datum, $value) = @_;
  return ref($datum) eq 'HASH' ?
    $datum->{$value} : $datum->$value; 
};

sub fill {
  my ($zoom, $targets, @rest) = @_;

  # Handle simple case of ->fill( '#id', [ 1,2,3,4,...])
  
  if(ref \$targets eq 'SCALAR') {
    $targets = [$targets];
    @rest = map { [$_] } map { ref $_ eq 'ARRAY' ? @$_ : $_ } @rest;
  }

  $zoom->repeat_content(sub {
    my $itr = $next_item_from_proto->(@rest);
    $targets = $normalize_targets->($targets);
    HTML::Zoom::CodeStream->new({
      code => sub {
        my $cnt = 0;
        if(my $datum = $itr->($zoom, $cnt)) {
          $cnt++;
          return sub {
            for my $idx(0..$#{$targets}) {
              my $target = $targets->[$idx];
              my ($match, $replace) = do {
                my $type = ref $target;
                $type ? ($type eq 'HASH' ? do { 
                    my ($match, $value) = %$target;
                    ref $value eq 'CODE' ?
                      ($match, $value->($datum, $idx, $_))
                      : ($match, $replace_from_hash_or_object->($datum, $value));
                  } : die "What?")
                  : do {
                      ref($datum) eq 'ARRAY' ?
                      ($target, $datum->[$idx]) :
                      ( '.'.$target, $replace_from_hash_or_object->($datum, $target));
                    };
              };
              $_ = $_->select($match)
                ->replace_content($replace);                
            } $_;
          };
        } else {
          return;
        }
      },
    });
  });
}

1;
