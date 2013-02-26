use strict;
use Test::More;

use_ok "Data::FormValidator::ProfileBuilder";

my $builder = Data::FormValidator::ProfileBuilder->new;
my $profile = $builder->new_profile("foo");
$profile->add_required(qw(aaa bbb ccc));

is_deeply($profile->to_hash, {
    required => [ qw(aaa bbb ccc) ],
});

$profile->add_optional(qw(ddd eee fff));

is_deeply($profile->to_hash, {
    required => [ qw(aaa bbb ccc) ],
    optional => [ qw(ddd eee fff) ],
});

my $DUMMY_SUB = sub { "DUMMY" };
$profile->add_field_filter(ddd => $DUMMY_SUB);

is_deeply($profile->to_hash, {
    required => [ qw(aaa bbb ccc) ],
    optional => [ qw(ddd eee fff) ],
    field_filters => {
        ddd => $DUMMY_SUB
    }
});

my $DUMMY_REGEX = qr/DUMMY/;
$profile->add_constraint_method(eee => $DUMMY_REGEX);
$profile->add_constraint_method(ddd => $DUMMY_REGEX);
$profile->add_constraint_method(ddd => $DUMMY_SUB);
is_deeply($profile->to_hash, {
    required => [ qw(aaa bbb ccc) ],
    optional => [ qw(ddd eee fff) ],
    field_filters => {
        ddd => $DUMMY_SUB
    },
    constraint_methods => {
        ddd => [ $DUMMY_REGEX, $DUMMY_SUB ],
        eee => [ $DUMMY_REGEX ], # Always a list
    },
});


done_testing;