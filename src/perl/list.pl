#!/usr/bin/perl


# takes a value and wraps it
# makes it into an array of that single element
# returns array ref
sub wrap($) {
    my $arg = shift;
    my @arr = ($arg);
    return \@arr;
}


# takes a function which is raw->wrapped
# and returns a function which is
# wrapped->wrapped
# since M is list, this is flatmap?
sub bindm($) {
    my ($func) = @_;

    # this is where the brains are?:
    return sub($) {
        my ($aref) = @_;
        my @ret = ();
        foreach my $elem (@$aref) {
            #push @ret, &$func($elem);

            # func returns an arrayref? (later: yes).
            my @val = @{&$func($elem)};

            # merge the array into the result:
            @ret = (@ret, @val);
        }

        return \@ret;
    }
}


# takes a raw->raw func and turns
# it into a function that returns wrapped values
sub lift($) {
    my ($func) = @_;
    return sub($) {
        my $arg = shift;
        return wrap(&$func($arg))
    }
}


###############################################

sub appendhi($) {
    my $arg = shift;
    return "$arg hi";
}

my @words = ("one", "two", "three");
my $lifted = lift(\&appendhi);

my $after = &{bindm($lifted)}(\@words);

for my $item (@{$after}) {
    print "$item ";
}

print "\n";

# a function that takes an arg and returns an array
# it's already of the form a -> M a.
sub emit_array($) {
    my $arg = shift;
    my @ret = ("$arg 1", "$arg 2");
    return \@ret;
}

$after = &{bindm(\&emit_array)}(\@words);
for my $item (@{$after}) {
    print "$item ";
}

print "\n";

####################################################

# test bind(unit) == identity
print "identity 1\n";
$identity = bindm(\&wrap);
@arr = (1,2,3);
my $a = &$identity(\@arr);
foreach my $item (@{$a}) {
    print "$item ";
}
print "\n";

# test bind(func) == func ?
# bind(wrap("candy"), more) // is equivalent to
# more("candy")
# bindm(func)(wrap("a")) == "a" ??
# where func is a -> M

print "identity 2\n";

$a = &{bindm(\&emit_array)}(wrap("a"));
$b = emit_array("a");

foreach my $item (@{$a}) {
    print "$item ";
}
print "\n";

foreach my $item (@{$b}) {
    print "$item ";
}
print "\n";
