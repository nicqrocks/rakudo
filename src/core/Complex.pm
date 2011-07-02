# XXX should also be Cool
my class Complex is Numeric {
    has num $!re;
    has num $!im;

    # XXX should not be needed, but currently segfaults
    # with the autogenerated accessors (has num $.re)
    method re() { $!re }
    method im() { $!im }

    proto method new(|$) { * }
    multi method new(Real \$re, Real \$im) {
        my $new = self.CREATE;
        $new.BUILD($re.Num, $im.Num);
        $new;
    }
    method BUILD(Num \$re, Num \$im) {
        $!re = $re;
        $!im = $im;
    }
    method reals() {
        (self.re, self.im);
    }

    method isNaN() {
        self.re.isNaN || self.im.isNaN;
    }

    method Real() {
        if $!im == 0 {
            $!re;
        } else {
#            fail "You can only coerce a Complex to Real if the imaginary part is zero"
            Real
        }
    }

    # should probably be eventually supplied by role Numeric
    method Num() { self.Real.Num }
    method Int() { self.Real.Int }
    method Rat() { self.Real.Rat }

    multi method Bool(Complex:D:) {
        $!re != 0e0 || $!im != 0e0;
    }

    method Complex() { self }
    multi method Str(Complex:D:) {
        my $op = $.im < 0 ?? ' - ' !! ' + ';
        $!re.Str ~ $op ~ $!im.abs ~ 'i';
    }

    multi method perl(Complex:D:) {
        "Complex.new($.re, $.im)";
    }
    method conjugate() {
        Complex.new($.re, -$.im);
    }

    method abs(Complex $x:) {
        nqp::p6box_n(nqp::add_n(
                nqp::mul_n($!re, $!re),
                nqp::mul_n($!im, $!im),
            )
        ).sqrt;
    }

    method polar() {
        $.abs, atan2($.im, $.re);
    }
}

multi sub prefix:<->(Complex \$a) {
    my $new := nqp::create(Complex);
    nqp::bindattr_n( $new, Complex, '$!re',
        nqp::neg_n(
            nqp::getattr_n(pir::perl6_decontainerize__PP($a), Complex, '$!re')
        )
    );
    nqp::bindattr_n( $new, Complex, '$!im',
        nqp::neg_n(
            nqp::getattr_n(pir::perl6_decontainerize__PP($a), Complex, '$!im')
        )
    );
    $new;
}

multi sub infix:<+>(Complex \$a, Complex \$b) {
    my $new := nqp::create(Complex);
    nqp::bindattr_n( $new, Complex, '$!re',
        nqp::add_n(
            nqp::getattr_n(pir::perl6_decontainerize__PP($a), Complex, '$!re'),
            nqp::getattr_n(pir::perl6_decontainerize__PP($b), Complex, '$!re'),
        )
    );
    nqp::bindattr_n( $new, Complex, '$!im',
        nqp::add_n(
            nqp::getattr_n(pir::perl6_decontainerize__PP($a), Complex, '$!im'),
            nqp::getattr_n(pir::perl6_decontainerize__PP($b), Complex, '$!im'),
        )
    );
    $new;
}

multi sub infix:<+>(Complex \$a, Real \$b) {
    my $new := nqp::create(Complex);
    nqp::bindattr_n( $new, Complex, '$!re',
        nqp::add_n(
            nqp::getattr_n(pir::perl6_decontainerize__PP($a), Complex, '$!re'),
            nqp::unbox_n($b.Num)
        )
    );
    nqp::bindattr_n($new, Complex, '$!im',
        nqp::getattr_n(pir::perl6_decontainerize__PP($a), Complex, '$!im'),
    );
    $new
}

multi sub infix:<+>(Real \$a, Complex \$b) {
    my $new := nqp::create(Complex);
    nqp::bindattr_n($new, Complex, '$!re',
        nqp::add_n(
            nqp::unbox_n($a.Num),
            nqp::getattr_n(pir::perl6_decontainerize__PP($b), Complex, '$!re'),
        )
    );
    nqp::bindattr_n($new, Complex, '$!im',
        nqp::getattr_n(pir::perl6_decontainerize__PP($b), Complex, '$!im'),
    );
    $new;
}

multi sub infix:<->(Complex \$a, Complex \$b) {
    my $new := nqp::create(Complex);
    nqp::bindattr_n( $new, Complex, '$!re',
        nqp::sub_n(
            nqp::getattr_n(pir::perl6_decontainerize__PP($a), Complex, '$!re'),
            nqp::getattr_n(pir::perl6_decontainerize__PP($b), Complex, '$!re'),
        )
    );
    nqp::bindattr_n($new, Complex, '$!im',
        nqp::sub_n(
            nqp::getattr_n(pir::perl6_decontainerize__PP($a), Complex, '$!im'),
            nqp::getattr_n(pir::perl6_decontainerize__PP($b), Complex, '$!im'),
        )
    );
    $new
}

multi sub infix:<->(Complex \$a, Real \$b) {
    my $new := nqp::create(Complex);
    nqp::bindattr_n( $new, Complex, '$!re',
        nqp::sub_n(
            nqp::getattr_n(pir::perl6_decontainerize__PP($a), Complex, '$!re'),
            $b.Num,
        )
    );
    nqp::bindattr_n($new, Complex, '$!im',
        nqp::getattr_n(pir::perl6_decontainerize__PP($a), Complex, '$!im')
    );
    $new
}

multi sub infix:<->(Real \$a, Complex \$b) {
    my $new := nqp::create(Complex);
    nqp::bindattr_n( $new, Complex, '$!re',
        nqp::sub_n(
            $a.Num,
            nqp::getattr_n(pir::perl6_decontainerize__PP($b), Complex, '$!re'),
        )
    );
    nqp::bindattr_n($new, Complex, '$!im',
        nqp::neg_n(
            nqp::getattr_n(pir::perl6_decontainerize__PP($b), Complex, '$!im')
        )
    );
    $new
}

multi sub infix:<*>(Complex \$a, Complex \$b) {
    my num $a_re = nqp::getattr_n(pir::perl6_decontainerize__PP($a), Complex, '$!re');
    my num $a_im = nqp::getattr_n(pir::perl6_decontainerize__PP($a), Complex, '$!im');
    my num $b_re = nqp::getattr_n(pir::perl6_decontainerize__PP($b), Complex, '$!re');
    my num $b_im = nqp::getattr_n(pir::perl6_decontainerize__PP($b), Complex, '$!im');
    my $new := nqp::create(Complex);
    nqp::bindattr_n($new, Complex, '$!re',
        nqp::sub_n(nqp::mul_n($a_re, $b_re), nqp::mul_n($a_im, $b_im)),
    );
    nqp::bindattr_n($new, Complex, '$!im',
        nqp::add_n(nqp::mul_n($a_re, $b_im), nqp::mul_n($a_im, $b_re)),
    );
    $new;
}

multi sub infix:<*>(Complex \$a, Real \$b) {
    my $new := nqp::create(Complex);
    my num $b_num = $b.Num;
    nqp::bindattr_n($new, Complex, '$!re',
        nqp::mul_n(
            nqp::getattr_n(pir::perl6_decontainerize__PP($a), Complex, '$!re'),
            $b_num,
        )
    );
    nqp::bindattr_n($new, Complex, '$!im',
        nqp::mul_n(
            nqp::getattr_n(pir::perl6_decontainerize__PP($a), Complex, '$!im'),
            $b_num,
        )
    );
    $new
}

multi sub infix:<*>(Real \$a, Complex \$b) {
    my $new := nqp::create(Complex);
    my num $a_num = $a.Num;
    nqp::bindattr_n($new, Complex, '$!re',
        nqp::mul_n(
            $a_num,
            nqp::getattr_n(pir::perl6_decontainerize__PP($b), Complex, '$!re'),
        )
    );
    nqp::bindattr_n($new, Complex, '$!im',
        nqp::mul_n(
            $a_num,
            nqp::getattr_n(pir::perl6_decontainerize__PP($b), Complex, '$!im'),
        )
    );
    $new
}

multi sub infix:</>(Complex \$a, Complex \$b) {
    my num $a_re = nqp::getattr_n(pir::perl6_decontainerize__PP($a), Complex, '$!re');
    my num $a_im = nqp::getattr_n(pir::perl6_decontainerize__PP($a), Complex, '$!im');
    my num $b_re = nqp::getattr_n(pir::perl6_decontainerize__PP($b), Complex, '$!re');
    my num $b_im = nqp::getattr_n(pir::perl6_decontainerize__PP($b), Complex, '$!im');
    my num $d    = nqp::add_n(nqp::mul_n($b_re, $b_re), nqp::mul_n($b_im, $b_im));
    my $new := nqp::create(Complex);
    nqp::bindattr_n($new, Complex, '$!re',
        nqp::div_n(
            nqp::add_n(nqp::mul_n($a_re, $b_re), nqp::mul_n($a_im, $b_im)),
            $d,
        )
    );
    nqp::bindattr_n($new, Complex, '$!im',
        nqp::div_n(
            nqp::sub_n(nqp::mul_n($a_im, $b_re), nqp::mul_n($a_re, $b_im)),
            $d,
        )
    );
    $new;
}

multi sub infix:</>(Complex \$a, Real \$b) {
    Complex.new($a.re / $b, $a.im / $b);
}

multi sub infix:</>(Real \$a, Complex \$b) {
    Complex.new($a, 0) / $b;
}

proto postfix:<i>(|$) { * }
multi postfix:<i>(Real    \$a) { Complex.new(0e0, $a);     }
multi postfix:<i>(Complex \$a) { Complex.new(-$a.im, $a.re) }
multi postfix:<i>(Numeric \$a) { $a * Complex.new(0e0, 1e0) }

# vim: ft=perl6
