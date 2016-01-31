
require "minitest/autorun"
require_relative '../script/generate_lookup'

require 'json'

class GenerateLookupTest < Minitest::Test

  def setup
    @test_path = 'rb/test/tmp/lookup.json'
  end

  def test_idempotent
    FilePath.stub :lookup, @test_path do
      generate_lookup
      before = JSON.parse(File.read(@test_path))
      generate_lookup
      after = JSON.parse(File.read(@test_path))

      assert_equal before, after
    end
  end

  def test_structure
    FilePath.stub :lookup, @test_path do
      generate_lookup
      res = JSON.parse(File.read(@test_path))
      assert_includes res, ['Masticore', []]
      assert_includes res, ['Fog', ['G']]
      assert_includes res, ['Lightning Helix', ['R', 'W']]
      assert_includes res, ['Zendikar Resurgent', ['G']]
      assert_includes res, ['Council Guardian', ['W']]
      assert_includes res, ['Spite/Malice', ['B', 'U']]
      refute_includes res, ['Malice/Spite', ['B', 'U']]
      refute_includes res, ['Spite', ['B', 'U']]
      refute_includes res, ['Spite', ['U']]
    end
  end
end
