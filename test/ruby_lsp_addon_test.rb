$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "bundler/setup"
require "minitest/autorun"
require "sorbet-runtime"
require "core_ext/uri"
require "language_server-protocol"
require "ruby_indexer/ruby_indexer"
require "ruby_lsp/addon"
require "ruby_lsp/base_server"
require "ruby_lsp/server"
require "ruby_lsp/requests"
require "ruby_lsp/utils"
require "ruby_lsp/store"
require "ruby_lsp/document"
require "ruby_lsp/global_state"
require "ruby_lsp/ruby_document"
require "ruby_lsp/type_inferrer"
require "prism"
require "pry"
require "ruby_lsp/reek/addon"

class RubyLspAddonTest < Minitest::Test
  def setup
    @addon = RubyLsp::Reek::Addon.new
    super
  end

  def test_name
    assert_equal "Reek: Code smell detector for Ruby", @addon.name
  end

  def test_diagnostic
    source = <<~RUBY
      def foo
        s = 'hello'
        puts s
      end
    RUBY
    with_server(source, "simple.rb") do |server, uri|
      server.process_message(
        id: 2,
        method: "textDocument/diagnostic",
        params: {
          textDocument: {
            uri:
          }
        }
      )

      result = server.pop_response

      assert_instance_of(RubyLsp::Result, result)
      assert_equal "full", result.response.kind
      assert_equal 1, result.response.items.size
      item = result.response.items.first
      assert_equal({line: 1, character: 0}, item.range.start.to_hash)
      assert_equal({line: 1, character: 0}, item.range.end.to_hash)
      assert_equal RubyLsp::Constant::DiagnosticSeverity::WARNING, item.severity
      assert_equal "UncommunicativeVariableName", item.code
      assert_equal(
        "https://github.com/troessner/reek/blob/v6.3.0/docs/Uncommunicative-Variable-Name.md",
        item.code_description.href
      )
      assert_equal "Reek", item.source
      assert_equal("has the variable name 's'", item.message)
    end
  end

  private

  # Overridden from RubyLsp/TestHelper so that we can override the linters configuration
  def with_server(
    source = nil,
    path = "fake.rb",
    stub_no_typechecker: false,
    load_addons: true,
    &block
  )
    server = RubyLsp::Server.new(test_mode: true)
    uri = Kernel.URI(File.join(server.global_state.workspace_path, path))
    server.global_state.instance_variable_set(:@linters, ["reek"])
    server.global_state.stubs(:typechecker).returns(false) if stub_no_typechecker

    if source
      server.process_message(
        {
          method: "textDocument/didOpen",
          params: {
            textDocument: {
              uri:,
              text: source,
              version: 1
            }
          }
        }
      )
    end

    server.global_state.index.index_single(
      RubyIndexer::IndexablePath.new(nil, uri.to_standardized_path),
      source
    )
    server.load_addons if load_addons
    block.call(server, uri)
  ensure
    if load_addons
      RubyLsp::Addon.addons.each(&:deactivate)
      RubyLsp::Addon.addons.clear
    end
  end
end
