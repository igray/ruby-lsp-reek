# Ruby Lsp Reek

Adds [Reek](https://github.com/troessner/reek/tree/master) as a linter for [Ruby LSP](https://github.com/Shopify/ruby-lsp)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruby-lsp-reek'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ruby-lsp-reek

## Usage

Add `reek` to the list of linters in your Ruby LSP configuration.

### Example: VS Code

In `settings.json`:

```json
"rubyLsp.linters": [ "rubocop", "reek" ]
```

After that, open the VS code command palette and select the option `Developer: Reload Window`.

### Example: [LazyVim](https://www.lazyvim.org/):

Update your nvim-lspconfig as follows:

```lua
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ruby_lsp = {
          init_options = {
            linters = { "rubocop", "reek" },
          },
        },
      },
    },
  },
```

See the [Ruby LSP Editor docs](https://github.com/Shopify/ruby-lsp/blob/main/EDITORS.md)
for more information on how to configure other editors.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and the created tag, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/igray/ruby-lsp-reek. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to
the [code of
conduct](https://github.com/igray/ruby-lsp-reek/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Ruby::Lsp::Reek project's codebases, issue
trackers, chat rooms and mailing lists is expected to follow the [code of
conduct](https://github.com/igray/ruby-lsp-reek/blob/main/CODE_OF_CONDUCT.md).
