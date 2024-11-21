# frozen_string_literal: true

require "reek"

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
        path = Pathname.new(uri.path)
        return [] if path_excluded?(path)

        examiner = build_examiner(path, document)
        examiner.smells.map { |smell| warning_to_diagnostic(smell) }
      end

      private

      attr_reader :config

      # Examiner does not allow separate source and origin, but we need to
      # lint the string from the editor AND know what the filename of the
      # edited file is. This patches the examiner to allow this.
      def build_examiner(path, document)
        examiner = ::Reek::Examiner.new(document.source, configuration: config)
        origin = ::Reek::Source::SourceCode.from(path).origin
        examiner.instance_variable_set(:@origin, origin)
        examiner.instance_variable_set(
          :@detector_repository,
          ::Reek::DetectorRepository.new(
            smell_types: examiner.instance_variable_get(:@smell_types),
            configuration: config.directive_for(origin)
          )
        )
        examiner
      end

      # @param warning [Reek::SmellWarning] The warning to convert to a diagnostic.
      # @return [RubyLsp::Interface::Diagnostic] The diagnostic.
      def warning_to_diagnostic(warning)
        lines = warning.lines
        ::RubyLsp::Interface::Diagnostic.new(
          range: ::RubyLsp::Interface::Range.new(
            start: ::RubyLsp::Interface::Position.new(
              line: lines.first - 1,
              character: 0
            ),
            end: ::RubyLsp::Interface::Position.new(
              line: lines.last - 1,
              character: 0
            )
          ),
          severity: Constant::DiagnosticSeverity::WARNING,
          code: warning.smell_type,
          code_description: ::RubyLsp::Interface::CodeDescription.new(href: warning.explanatory_link),
          source: "Reek",
          message: warning.message
        )
      end

      def path_excluded?(path)
        path.ascend do |ascendant|
          break true if config.path_excluded?(ascendant)

          false
        end
      end
    end
  end
end
