
use Strict::Prototype;

sub foo {
    print "bar\n";
}

sub bar ($) {
    printf "bar : %s\n",shift;
}

sub foobar (int $msg) {
    print "Hello $msg\n";
}

print "foo...";&foo();
print "bar...";&bar("native");
print "foobar...";&foobar("Matt");


