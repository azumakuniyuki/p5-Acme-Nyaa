use inc::Module::Install;
name 'Acme-Nyaa';
all_from 'lib/Acme/Nyaa.pm';

requires 'Module::Load';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
# install_script 'bin/nyaa';
WriteAll;
