
require "minitest/autorun"
require_relative '../card_ref'

class CardRefTest < Minitest::Test

  def setup
    @good = ['Fog', 'Executioner\'s Capsule', 'Spite/Malice']
    @bad = ['garbage', 'Spite', 'Malice']
    @sut = CardRef.new
  end

  def test_get_card_ok
    @good.each do |card_name|
      assert_equal card_name, @sut.get_card(card_name)['name']
    end
  end

  def test_get_card_raises
    @bad.each do |card_name|
      assert_raises(RuntimeError){ @sut.get_card(card_name) }
    end
  end

  def test_has_card_true
    @good.each do |card_name|
      assert @sut.has_card?(card_name)
    end
  end

  def test_has_card_false
    @bad.each do |card_name|
      refute @sut.has_card?(card_name)
    end
  end
end
