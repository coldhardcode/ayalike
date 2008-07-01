use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'Ayalike' }
BEGIN { use_ok 'Ayalike::Controller::Site' }

ok( request('/site')->is_success, 'Request should succeed' );


