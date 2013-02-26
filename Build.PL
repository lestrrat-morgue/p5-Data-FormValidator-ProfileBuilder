use strict;
BEGIN {
    my @plugins = qw(Repository);
    if (! -f "README.mkdn") {
        push @plugins, "ReadmeMarkdownFromPod";
    }
    require Module::Build::Pluggable;
    Module::Build::Pluggable->import(@plugins);
}

my $builder = Module::Build::Pluggable->new(
    module_name         => 'Data::FormValidator::ProfileBuilder',
    license             => 'artistic_2',
    configure_requires  => {
        'Module::Build'             => '0.40',
        'Module::Build::Pluggable'  => '0.05',
    },
    create_makefile_pl  => 'small',
    test_requires       => {
        'Data::FormValidator'   => 0,
    },
);

$builder->create_build_script;

if (-f "META.yml" && ! -f "MYMETA.yml") { # fallback if we don't have CPAN::Meta
    require File::Copy;
    File::Copy::copy("META.yml", "MYMETA.yml") or warn "Error: $!\n";
    if ( -f 'MYMETA.yml' ) {
        warn "Copied META.yml to MYMETA.yml for bootstrapping\n";
    } else {
        warn "Could not copy META.yml to MYMETA.yml.  That's odd!\n";
    }
}
