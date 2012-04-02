use inc::Module::Install;

name     'App-DPath';
all_from 'lib/App/DPath.pm';
author   'Steffen Schwigon <<ss5@renormalist.net>>';
license  'perl';

build_requires 'Test::More';
build_requires 'Data::Structure::Util';

requires 'YAML::Any';
requires 'JSON';
requires 'TAP::DOM';
requires 'Config::INI::Serializer';
requires 'Data::DPath';
requires 'XML::Simple';
requires 'Config::General';
requires 'App::Cmd' => '0.301';
requires 'Scalar::Util';

install_script 'dpath';

repository 'git://github.com/renormalist/app-dpath.git';
bugtracker 'http://rt.cpan.org/NoAuth/ReportBug.html?Queue=App-DPath';

auto_install;

WriteAll;

