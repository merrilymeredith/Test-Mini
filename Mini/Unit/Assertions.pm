use MooseX::Declare;

class Mini::Unit::Assert with Throwable {
  has 'message' => (is => 'ro');
  sub BUILDARGS { return shift->SUPER::BUILDARGS(message => join '', @_); }
}

class Mini::Unit::Skip extends Mini::Unit::Assert {}

role Mini::Unit::Assertions {
  use MooseX::AttributeHelpers;
  has _assertions => (
    metaclass => 'Number',
    is        => 'rw',
    isa       => 'Int',
    default   => 0,
    provides  => {
      add => '_add_assertions',
    },
  );

  method assert($test, $msg = "Failed assertion, no message given") {
    $self->_add_assertions(1);
    $msg = $msg->() if ref $msg eq 'CODE';
    Mini::Unit::Assert->throw($msg) unless $test;
  }
}