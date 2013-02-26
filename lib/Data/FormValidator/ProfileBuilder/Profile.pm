package Data::FormValidator::ProfileBuilder::Profile;
use strict;
use Class::Accessor::Lite
    ro => [ qw(name) ],
    rw => [ qw(
        required
        optional
        constraint_methods
        field_filters
    ) ]
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
        required => [],
        optional => [],
        field_filters => {},
        constraint_methods => {}, # FIXME
    );
    foreach my $key (keys %defaults) {
        if (! defined $self->$key) {
            $self->$key($defaults{$key});
        }
    }
}

sub add_required {
    my ($self, @fields) = @_;
    push @{$self->required}, @fields;
}

sub add_optional {
    my ($self, @fields) = @_;
    push @{$self->optional}, @fields;
}

sub add_field_filter {
    my ($self, $name, $code) = @_;
    if (exists $self->field_filters->{$name}) {
        Carp::croak("Field filter for '$name' already exists");
    }

    $self->field_filters->{$name} = $code;
}

sub remove_constraint_methods {
    my ($self, $key) = @_;
    delete $self->constraint_methods->{$key};
}

sub clear_constraint_methods {
    my $self = shift;
    my $hash = $self->constraint_methods;
    foreach my $key (keys %$hash) {
        $self->remove_constraint_methods($key);
    }
}

sub add_constraint_method {
    my ($self, $name, $constraint) = @_;
    my $list = $self->constraint_methods->{$name} ||= [];
    push @$list, $constraint;
}

sub to_hash {
    my $self = shift;
    my %hash;
    foreach my $field (qw(required optional constraint_methods field_filters)) {
        my $value = $self->$field;
        if (! defined $value) {
            next;
        }

        # if this is a hashref or an arrayref, don't include
        # in the resulting has if it's empty
        my $ref = ref $value;
        if ($ref) {
            if ($ref eq 'HASH' && scalar keys %$value == 0) {
                next;
            }
            if ($ref eq 'ARRAY' && scalar @$value == 0) {
                next;
            }
        }
        $hash{$field} = $self->$field;
    }
    return \%hash;
}

1;