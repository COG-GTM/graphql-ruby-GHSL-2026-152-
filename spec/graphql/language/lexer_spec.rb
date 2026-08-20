# frozen_string_literal: true
require "spec_helper"
require_relative "./lexer_examples"
describe GraphQL::Language::Lexer do
  subject { GraphQL::Language::Lexer }
  include LexerExamples

  def assert_bad_unicode(string, expected_err_message = "Parse error on bad Unicode escape sequence")
    err = assert_raises(GraphQL::ParseError) do
      subject.tokenize(string)
    end
    assert_equal expected_err_message, err.message
  end

  it "rejects unterminated block strings without backtracking" do
    # Each added backslash used to double the work of failing to match
    # BLOCK_STRING_REGEXP, so this took hours to raise:
    query_string = '"""' + ("\\" * 64)

    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    assert_raises(GraphQL::ParseError) { subject.tokenize(query_string) }
    elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at

    assert elapsed < 1, "Lexing an unterminated block string took #{elapsed} seconds"
  end
end
