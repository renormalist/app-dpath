use inc::Module::Install;

name     'App-DPath';
all_from 'lib/App/DPath.pm';
author   'Steffen Schwigon <<ss5@renormalist.net>>';
license  'perl';

build_requires 'Test::More';

requires 'YAML::Syck';
requires 'Data::DPath';
requires 'App::Cmd';
repository 'git://github.com/renormalist/app-dpath.git';

auto_install;

WriteAll;

