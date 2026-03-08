# Backticks

Ruby gem providing an OOP wrapper for command-line processes with PTY support.

## Development

```bash
bundle install
bundle exec rake spec
```

## Project Structure

- `lib/backticks/` - gem source; `runner.rb` spawns processes, `command.rb` manages running commands
- `spec/` - RSpec tests; `runner_spec.rb` is pure unit tests with mocked PTY/IO, `command_spec.rb` mixes unit and functional tests with real subprocesses
- `backticks.gemspec` - gem metadata; version is in `lib/backticks/version.rb`

## CI

GitHub Actions runs specs against Ruby 3.2, 3.3, and head on every push/PR to master.

## Releasing

1. Bump `VERSION` in `lib/backticks/version.rb`
2. Commit and push to master
3. Go to Actions > Release > "Run workflow"

The workflow reads the version from source, publishes to RubyGems via trusted publisher, then creates the GitHub release. Do not create releases manually; the workflow is the single source of truth for the release tag.

## PTY Considerations

This gem uses PTY for unbuffered I/O. Tests that mock `IO.select` must ensure stdout/stderr are still drained, or `Command#join` will loop forever waiting for `eof?`. In CI (no TTY), `STDIN.tty?` returns false, which changes `capture()` behavior. See the `given interactive is true` tests in `command_spec.rb` for the pattern.
