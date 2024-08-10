# frozen_string_literal: true

require 'reek'

module RubyLsp
  module Reek
    # Implements Ruby LSP Formatter interface: specifically run_diagnostic
    class Runner
      include RubyLsp::Requests::Support::Formatter

      def initialize
        @config = ::Reek::Configuration::AppConfiguration.from_default_path
      end

      # We are not implementing this method, but it is required by the interface
      #
      # @param uri [String] The URI of the document to format.
      # @param document [RubyLsp::Interface::TextDocumentItem] The document to format.
      # @return [String] The formatted document.
      def run_formatting(_uri, document)
        document.source
      end

      # @param uri [String] The URI of the document to run diagnostics on.
      # @param document [RubyLsp::Interface::TextDocumentItem] The document to run diagnostics on.
      def run_diagnostic(uri, document)
        return [] if config.path_excluded?(Pathname.new(uri.path))

        examiner = ::Reek::Examiner.new(document.source, configuration: config)
        examiner.smells.map { |w| warning_to_diagnostic(w) }
      end

      private

      attr_reader :config

      # @param warning [Reek::SmellWarning] The warning to convert to a diagnostic.
      # @return [RubyLsp::Interface::Diagnostic] The diagnostic.
      def warning_to_diagnostic(warning)
        ::RubyLsp::Interface::Diagnostic.new(
          range: ::RubyLsp::Interface::Range.new(
            start: ::RubyLsp::Interface::Position.new(
              line: warning.lines.first - 1,
              character: 0
            ),
            end: ::RubyLsp::Interface::Position.new(
              line: warning.lines.last - 1,
              character: 0
            )
          ),
          severity: Constant::DiagnosticSeverity::WARNING,
          code: warning.smell_type,
          code_description: ::RubyLsp::Interface::CodeDescription.new(href: warning.explanatory_link),
          source: 'Reek',
          message: warning.message
        )
      end
    end
  end
end
