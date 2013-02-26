package Data::FormValidator::ProfileBuilder;
use strict;
use Data::FormValidator::ProfileBuilder::Profile;
use Class::Accessor::Lite
    rw  => [ qw(profiles) ]
;

sub new {
    my ($class, %args) = @_;
    my $self = bless { %args }, $class;
    $self->apply_defaults;
    return $self;
}

sub apply_defaults {
    my $self = shift;
    my %defaults = (
        profiles => {},
    );
    foreach my $key (keys %defaults) {
        if (! defined $self->$key) {
            $self->$key($defaults{$key});
        }
    }
}

sub new_profile {
    my ($self, $name) = @_;
    if (exists $self->profiles->{$name}) {
        Carp::croak("Profile '$name' already exists");
    }

    my $rule = Data::FormValidator::ProfileBuilder::Profile->new(
        name => $name,
    );
    $self->profiles->{$name} = $rule;
    return $rule;
}

sub add_profile {
    my ($self, $rule) = @_;
    
    my $name = $rule->name;
    if (exists $self->profiles->{$name}) {
        Carp::croak("Profile '$name' already exists");
    }
    $self->profiles->{$name} = $rule;
    return $rule;
}

sub to_hash {
    my $self = shift;
    my $profiles = $self->profiles;
    my %hash;
    foreach my $name (keys %$profiles) {
        $hash{$name} = $profiles->{$name}->to_hash;
    }

    return \%hash;
}

1;

__END__

=head1 NAME

Data::FormValidator::ProfileBuilder - Object Oriented Approach To Declaring Data::FormValidator Profiles

=head1 SYNOPSIS

    use Data::FormValidator::ProfileBuilder;

    my $builder = Data::FormValidator::ProfileBuilder->new;
    my $profile = $builder->new_profile("profile_name_A");
    $profile->add_required(qw(A B C));
    $profile->add_optional(qw(D E F));
    $profile->add_field_filter(A => sub {
        ...
    });

    my $dfv = Data::FormValidator->new($builder->to_hash);

=head1 DESCRIPTION

Data::FormValidator accepts a big hash of validation profiles as its
constructor parameters -- which is flexible, but you always run the risk
of mistyping key names, only to find that the key had been silently ignored
when that bug hits you.

This module gives you a programatic interface to building the profile hashes,
so you don't make foolish mistakes like this:

    my $dfv = Data::FormValidator->new({
        profile_A => {
            requires => [ ... ], # Should be "required"!
        }
    });

Instead, you'd be writing:

    my $builder = Data::FormValidator::ProfileBuilder->new;
    my $profile_A = $builder->new_prorfile("name_of_profile_A");
    $profile_A->add_required("A");
    $profile_A->add_optional("B");

    my $profile_B = $builder->new_prorfile("name_of_profile_B");
    $profile_B->add_required("A");
    $profile_B->add_optional("B");

    my $dfv = Data::FormValidator->new( $builder->to_hash() );

So you will still be building that big hash, but at least there'd be no silly 
typos.

=head1 CURRENTLY SUPPORTED

=head2 required

Add required fields

=head2 optional

Add optional fields

=head2 field_filters

Add field filters

=head2 constraint_methods

=head1 TODO

Implement missing methods
    
=cut