use Test::Mini::Unit;

class MyClass { }

testcase Test::Mini::Logger::Lapidary::Test
{
  use aliased 'IO::Scalar' => 'Buffer';
  use aliased 'Test::Mini::Logger::Lapidary' => 'Logger';

  use Text::Outdent 0.01 'outdent';

  my $buffer;
  has 'logger' => (
    is => 'rw',
    lazy => 1,
    default => sub {
      return Logger->new(buffer => Buffer->new(\($buffer = '')));
    },
  );

  sub error { return Test::Mini::Unit::Error->new(message => "Error Message\n") }

  setup
  {
    my %ends = (
      'MyClass'         => 15,
      'MyClass#method1' => 1,
      'MyClass#method2' => 2,
      'MyClass#method3' => 4,
      'MyClass#method4' => 8,
    );

    no strict 'refs';
    no warnings 'redefine';
    *{Logger.'::time'}   = sub { return $ends{$_[-1]} || 314 };
  }

  test begin_test_suite_without_filter
  {
    $self->logger->begin_test_suite(seed => 'SEED');

    assert_equal $buffer, outdent(<<'    Lapidary')
      Loaded Suite
      Seeded with SEED

    Lapidary
  }

  test begin_test_suite_with_filter
  {
    $self->logger->begin_test_suite(seed => 'SEED', filter => 'FILTER');

    assert_equal $buffer, outdent(<<'    Lapidary')
      Loaded Suite (Filtered to /FILTER/)
      Seeded with SEED

    Lapidary
  }

  test pass
  {
    $self->logger->pass('MyClass', 'method1');
    $self->logger->finish_test('MyClass', 'method1', 1);

    assert_equal $buffer, '.';
  }

  test passing_summary
  {
    $self->logger->begin_test_case('MyClass');
    $self->logger->pass('MyClass', 'method1');
    $self->logger->finish_test('MyClass', 'method1', 4);
    $self->logger->finish_test_case('MyClass');
    $self->logger->finish_test_suite('MyClass');

    assert_equal $buffer, outdent(<<'    Lapidary')
      .

      Finished in 314 seconds.

      1 tests, 4 assertions, 0 failures, 0 errors, 0 skips
    Lapidary
  }

  test fail
  {
    $self->logger->fail('MyClass', 'method1', error());
    $self->logger->finish_test('MyClass', 'method1', 1);

    assert_equal $buffer, 'F';
  }

  test failing_summary
  {
    $self->logger->fail('MyClass', 'method1', error());
    $self->logger->finish_test('MyClass', 'method1', 1);
    $self->logger->fail('MyClass', 'method2', error());
    $self->logger->finish_test('MyClass', 'method2', 2);
    $self->logger->finish_test_suite('MyClass');

    assert_equal $buffer, outdent(<<'    Lapidary')
      FF

      Finished in 314 seconds.

        1) Failure:
      method1(MyClass) [t/Test/Mini/Logger/Lapidary.t:21]:
      Error Message

        2) Failure:
      method2(MyClass) [t/Test/Mini/Logger/Lapidary.t:21]:
      Error Message

      2 tests, 3 assertions, 2 failures, 0 errors, 0 skips
    Lapidary
  }

  test error
  {
    $self->logger->error('MyClass', 'method1', 'Error message');
    $self->logger->finish_test('MyClass', 'method1', 1);

    assert_equal $buffer, 'E';
  }

  test erroring_summary
  {
    $self->logger->error('MyClass', 'method1', 'Cat. Failure.');
    $self->logger->finish_test('MyClass', 'method1', 1);
    $self->logger->error('MyClass', 'method2', error());
    $self->logger->finish_test('MyClass', 'method2', 2);
    $self->logger->finish_test_suite('MyClass');

    assert_equal $buffer, outdent(<<'    Lapidary')
      EE

      Finished in 314 seconds.

        1) Error:
      method1(MyClass):
      Cat. Failure.

        2) Error:
      method2(MyClass):
      Error Message
        Exception::Class::Base::new('Test::Mini::Unit::Error', 'message', 'Error Message^J') called at t/Test/Mini/Logger/Lapidary.t line 21
        Test::Mini::Logger::Lapidary::Test::error at t/Test/Mini/Logger/Lapidary.t line 130

      2 tests, 3 assertions, 0 failures, 2 errors, 0 skips
    Lapidary
  }


  test skip
  {
    $self->logger->skip('MyClass', 'method1', error());
    $self->logger->finish_test('MyClass', 'method1', 1);

    assert_equal $buffer, 'S';
  }

  test skipping_summary
  {
    $self->logger->skip('MyClass', 'method1', error());
    $self->logger->finish_test('MyClass', 'method1', 1);
    $self->logger->skip('MyClass', 'method2', error());
    $self->logger->finish_test('MyClass', 'method2', 2);
    $self->logger->finish_test_suite('MyClass');

    assert_equal $buffer, outdent(<<'    Lapidary')
      SS

      Finished in 314 seconds.

        1) Skipped:
      method1(MyClass) [t/Test/Mini/Logger/Lapidary.t:21]:
      Error Message

        2) Skipped:
      method2(MyClass) [t/Test/Mini/Logger/Lapidary.t:21]:
      Error Message

      2 tests, 3 assertions, 0 failures, 0 errors, 2 skips
    Lapidary
  }

  test begin_test_while_verbose
  {
    $self->logger->{verbose} = 1;
    $self->logger->begin_test('MyClass', 'method1');

    assert_equal $buffer, 'MyClass#method1: ';
  }

  test finish_test_while_verbose
  {
    $self->logger->{verbose} = 1;
    $self->logger->pass('MyClass', 'method1');
    $self->logger->finish_test('MyClass', 'method1', 1);
    $self->logger->fail('MyClass', 'method2', error());
    $self->logger->finish_test('MyClass', 'method2', 1);
    $self->logger->error('MyClass', 'method3', error());
    $self->logger->finish_test('MyClass', 'method3', 1);
    $self->logger->skip('MyClass', 'method4', error());
    $self->logger->finish_test('MyClass', 'method4', 1);

    assert_equal $buffer, outdent(<<'    Lapidary')
      1 s: .
      2 s: F
      4 s: E
      8 s: S
    Lapidary
  }

  # TODO: Finish Tests
}
