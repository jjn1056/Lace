package HTML::Zoom::FilterBuilder;

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

1;
