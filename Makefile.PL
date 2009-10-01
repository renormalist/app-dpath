use inc::Module::Install;

name     'App-DPath';
all_from 'lib/App/DPath.pm';
author   'Steffen Schwigon <<ss5@renormalist.net>>';
license  'perl';

build_requires 'Test::More';
build_requires 'Data::Structure::Util';

requires 'YAML::Syck';
requires 'JSON';
requires 'TAP::DOM';
requires 'Config::INI';
requires 'Data::DPath';
requires 'XML::Simple';
requires 'Config::General';
requires 'App::Cmd' => '0.301';

install_script 'dpath';

repository 'git://github.com/renormalist/app-dpath.git';
bugtracker 'http://rt.cpan.org/NoAuth/ReportBug.html?Queue=App-DPath';

#makemaker_args dist => { PREOP => 'pod2text lib/App/DPath.pm > README' } ;

auto_install;

WriteAll;

