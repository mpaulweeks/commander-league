
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
      assert_equal 382866, res['Black Lotus']
      assert_equal 249394, res['Spite/Malice']
      refute_includes res, 'Malice/Spite'
      refute_includes res, 'Spite'
      refute_includes res, 'Malice'
    end
  end
end