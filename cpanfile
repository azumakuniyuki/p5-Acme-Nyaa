requires 'Module::Load';
requires 'perl', '5.010001';

on build => sub {
    requires 'ExtUtils::MakeMaker', '6.59';
    requires 'Test::More';
};
