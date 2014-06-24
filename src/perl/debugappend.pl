#!/usr/bin/perl


# takes a value and wraps it
# returns a hashref
# with "val" defined
# which can be undefined...
# and some other state.
sub wrap($) {
    my $arg = shift;
    my %hash = (
        "val" => $arg, # what if this "value" was a function that took some args?
        #"count" => 0,
        "debug" => ""
    );
    return \%hash;
}

sub debugdump($) {
    my $wrapped = shift;
    print qq(val=$wrapped->{"val"} dbg=$wrapped->{"debug"}\n);
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
            # this is a wrapped M value:
            my $ret = &$func($val);
            # increment count and append debug information
            #$ret->{"count"}++;
            $ret->{"debug"} = $wrapped->{"debug"} . $ret->{"debug"};
            return $ret;
        } else {
            # if val is not defined don't perform operation
            return $wrapped;
        }
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


# takes a raw->raw func and turns
# it into a function that returns wrapped values with
# a debug string added to the M
sub lift_with_dbg_string($$) {
    my $func = shift;
    my $dbgstring = shift;

    return sub($) {
        my $arg = shift;
        my $retval = &$func($arg);
        my $ret = wrap($retval);
        $ret->{"debug"} = $dbgstring;
        return $ret;
    }
}

############### bindm and lift #######################
# http://blog.sigfpe.com/2006/08/you-could-have-invented-monads-and.html
# this is 'f'
sub addOne($) {
    my $arg = shift;
    return $arg + 1;
}

# this is 'f-prime' ?
sub addOneDbg($) {
    my $arg = shift;
    my $retval = addOne($arg);
    my $ret = wrap($retval);
    $ret->{"debug"} = "addOne was called.";
    return $ret;
}


debugdump(addOneDbg(42));

my $val = &{bindm(\&addOneDbg)}(addOneDbg(42));
debugdump($val);
# or:
$val = addOneDbg(42);
$val = &{bindm(\&addOneDbg)}($val);
debugdump($val);

# or:
$val = &{bindm(\&addOneDbg)}(wrap(42));
$val = &{bindm(\&addOneDbg)}($val);
$val = &{bindm(\&addOneDbg)}($val);
$val = &{bindm(\&addOneDbg)}($val);
debugdump($val);

# or:
my $dumbAddOneDbg = lift(\&addOne);
$val = &{bindm($dumbAddOneDbg)}(wrap(42));
$val = &{bindm($dumbAddOneDbg)}($val);
$val = &{bindm($dumbAddOneDbg)}($val);
debugdump($val);

# or:
my $addonedebug = lift_with_dbg_string(\&addOne, "addOne was called!");

$val = &{bindm($addonedebug)}(wrap(42));
$val = &{bindm($addonedebug)}($val);
$val = &{bindm($addonedebug)}($val);
$val = &{bindm($addonedebug)}($val);
$val = &{bindm($addonedebug)}($val);
#$val = &{bindm($addonedebug)}($val);
#$val = &{bindm($addonedebug)}($val);
debugdump($val);

####################################################

