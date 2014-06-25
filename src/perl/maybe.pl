#!/usr/bin/perl


# takes a value and wraps it
# returns a hashref
# with one thing defined
# "val"
# which can be undefined...
sub wrap($) {
    my $arg = shift;
    my %hash = (
        "val" => $arg
    );
    return \%hash;
}


# takes a function which is raw->wrapped
# and returns a function which is
# wrapped->wrapped
sub bindm($) {
    my ($func) = @_;

    # this is where the brains are?:
    return sub($) {
        my ($wrapped) = @_;
        my $val = $wrapped->{"val"};
        if (defined($val)) {
            return &$func($val);
        } else {
            # if val is not defined don't perform operation
            return $wrapped;
        }
    }
}

# make wrap() into a functor?
# applies func to the value inside wrap
# returns wrapped result
sub fmap($$) {
    my ($wrap, $func) = @_;
    my $val = $wrap->{"val"};

    if (defined($val)) {
        $wut = &$func($val);
        return wrap(&$func($val));
    } else {
        return $wrap;
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


############### bindm ################################
# a dumb subroutine that prints it's arg
sub printsomething($) {
    my $arg = shift;
    print "[$arg]\n";
}


# turn printsomething into a funciton that can take a wrapped value
my $printmaybe = bindm(\&printsomething);

printsomething("hi");
&$printmaybe(wrap("wrapped hi!"));

# acquiring and evaluating the bindm-ed function all in one line.
# not sure if this is idiomatic perl ha.
&{bindm(\&printsomething)}(wrap("also wrapped"));

########### lift ####################################

sub appendhi($) {
    my $arg = shift;
    return "$arg hi";
}

my $lifted = lift(\&appendhi);

print appendhi("wut") . "\n";
&$printmaybe(&$lifted("lifted wut"));

####################################################

# test bind(unit) == identity
$identity = bindm(\&wrap);
$a = wrap("wut");
my $b = &$identity($a);
&$printmaybe($a);
&$printmaybe($b);

print "test fmap\n";
my $thing = wrap("fmap!");
# should print out "fmap! hi";
&$printmaybe(fmap($thing, \&appendhi));
