# frozen_string_literal: true

require 'bundler/setup'
require 'sorbet-runtime'
require 'ruby_lsp/addon'
require 'ruby_lsp/base_server'
require 'ruby_lsp/server'
require 'uri'
require_relative 'runner'
require_relative 'version'

module RubyLsp
  module Reek
    # Implements the RubyLsp::Addon interface to provide Reek linter support to Ruby LSP.
    class Addon < ::RubyLsp::Addon
      def initializer
        @runner = nil
      end

      # @return [String] The name of the addon.
      def name
        'Reek: Code smell detector for Ruby'
      end

      # @param global_state [GlobalState] The global state of the Ruby LSP server.
      # @param outgoing_queue [Thread::Queue] The outgoing message queue of the Ruby LSP server.
      def activate(global_state, message_queue)
        warn "Activating Reek Ruby LSP addon v#{::RubyLsp::Reek::VERSION}"
        @runner = Runner.new
        global_state.register_formatter('reek', @runner)
        register_additional_file_watchers(global_state, message_queue)
        warn "Initialized Reek Ruby LSP addon v#{::RubyLsp::Reek::VERSION}"
      end

      # @return [nil]
      def deactivate
        @runner = nil
      end

      # @param global_state [GlobalState] The global state of the Ruby LSP server.
      # @param outgoing_queue [Thread::Queue] The outgoing message queue of the Ruby LSP server.
      def register_additional_file_watchers(global_state, message_queue)
        return unless global_state.supports_watching_files

        message_queue << Request.new(
          id: 'reek-file-watcher',
          method: 'client/registerCapability',
          params: Interface::RegistrationParams.new(
            registrations: [
              Interface::Registration.new(
                id: 'workspace/didChangeWatchedFilesReek',
                method: 'workspace/didChangeWatchedFiles',
                register_options: Interface::DidChangeWatchedFilesRegistrationOptions.new(
                  watchers: [
                    Interface::FileSystemWatcher.new(
                      glob_pattern: '**/.reek.yml',
                      kind: Constant::WatchKind::CREATE | Constant::WatchKind::CHANGE | Constant::WatchKind::DELETE
                    )
                  ]
                )
              )
            ]
          )
        )
      end

      # @param changes [Array<Hash>] The changes to the watched files.
      def workspace_did_change_watched_files(changes)
        return unless changes.any? { |change| change[:uri].end_with?('.reek.yml') }

        @runner.init!
        warn "Re-initialized Reek Ruby LSP addon v#{::RubyLsp::Reek::VERSION} due to .reek.yml file change"
      end
    end
  end
end
