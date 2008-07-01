use inc::Module::Install;

name 'Ayalike';
all_from 'lib/Ayalike.pm';

requires 'Text::Diff' => '0.35';
requires 'Catalyst::Authentication::Store::DBIx::Class' => '0.10';
requires 'Catalyst::Runtime' => '5.7012';
requires 'Catalyst::Plugin::Authentication' => '0.10005';
requires 'Catalyst::Plugin::Authorization::Roles' => '0.05';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::FormValidator';
requires 'Catalyst::Plugin::I18N';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::View::TT';
requires 'Config::Any';
requires 'Data::Dumper' => '2.121';
requires 'DateTime';
requires 'DateTime::Format::Natural';
requires 'DateTime::Format::Strptime';
requires 'DateTime::TimeZone';
requires 'DBIx::Class';
requires 'File::Path' => '2.04';
requires 'File::Spec';
requires 'Moose' => '0.36';
requires 'MooseX::AttributeHelpers' => '0.07';
requires 'SQL::Translator';
requires 'Text::Diff';
requires 'Text::Patch';
requires 'Tree::Simple' => '1.18';
requires 'Tree::Simple::VisitorFactory' => '0.10';
requires 'YAML'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats

feature 'Markdown Support',
    -default => 1,
    'Text::Markdown' => 0;

feature 'Textile Support',
    -default => 1,
    'Text::Textile' => 0;

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
