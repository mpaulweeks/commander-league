
require "minitest/autorun"
require_relative '../script/generate_multiverse'

require 'json'

class GenerateMultiverseTest < Minitest::Test

  def setup
    @test_path = 'rb/test/tmp/multiverse_ids.json'
  end

  def test_idempotent
    FilePath.stub :multiverse_ids, @test_path do
      generate_multiverse_ids()
      before = JSON.parse(File.read(@test_path))
      generate_multiverse_ids()
      after = JSON.parse(File.read(@test_path))

      assert_equal before, after
    end
  end

  def test_structure
    FilePath.stub :multiverse_ids, @test_path do
      generate_multiverse_ids()
      res = JSON.parse(File.read(@test_path))
      assert_equal res['Black Lotus'], 382866
    end
  end
end