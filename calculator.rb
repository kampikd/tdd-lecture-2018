require 'minitest/autorun'
require 'net/http'
require 'json'

class ZeroDivisionError < StandardError; end;

class Calculator
  def initialize(base = 10, a = 0, b = 0)
    @base = base || 10
    @a = base_to_dec(a)
    @b = base_to_dec(b)
  end

  def add
    dec_to_base(@a + @b)
  end

  def subtract
    dec_to_base(@a - @b)
  end

  def multiply
    dec_to_base(@a * @b)
  end

  def divide
    raise ZeroDivisionError if @b.zero?
    dec_to_base((@a / @b).to_i)
  end

  def usd_to_pln(usd)
    @a = usd
    @b = usd_exchange_rate
    multiply
  end

  private

  def base_to_dec(num)
    num.to_s.to_i(@base)
  end

  def dec_to_base(num)
    @base == 10 ? num : num.to_s(@base)
  end

  def usd_exchange_rate
    response = Net::HTTP.get('http://api.nbp.pl/api/exchangerates/rates/A/USD')
    json = JSON.parse(response.body)
    json['rates'][0]['mid'].to_f
  end
end


class CalculatorDecimalTest < Minitest::Test
  def setup
    @calculator = Calculator.new(10, 2, 3)
  end

  def teardown
    @calculator = nil
  end

  def test_add
    assert_equal 5, @calculator.add
  end

  def test_subtract
    assert_equal -1, @calculator.subtract
  end

  def test_multiply
    assert_equal 6, @calculator.multiply
  end

  def test_divide
    assert_equal 0, @calculator.divide
  end

  def test_result_is_numeric
    assert_kind_of Numeric, @calculator.add
  end

  def test_divide_by_zero
    @calculator = Calculator.new(10, 3, 0)
    assert_raises(::ZeroDivisionError) { @calculator.divide }
  end
end

class CalculatorCurrencyExchangeTest < Minitest::Test
  def setup
    @calculator = Calculator.new(10)
  end

  def teardown
    @calculator = nil
  end

  def test_usd_pln_exchange
    @calculator.stub :usd_exchange_rate, 3.79 do
      assert_equal 2*3.79, @calculator.usd_to_pln(2)
    end
  end
end

class CalculatorBinTest < Minitest::Test
  def setup
    @calculator = Calculator.new(2, '1', '10')
  end

  def test_add
    assert @calculator.add == '11'
  end

  def test_subtract
    assert_equal '-1', @calculator.subtract
  end

  def test_multiply
    assert_equal '10', @calculator.multiply
  end

  def test_divide
    assert_equal '0', @calculator.divide
  end

  def test_result_is_string
    assert_kind_of String, @calculator.add
  end
end
