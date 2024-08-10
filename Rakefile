# frozen_string_literal: true

task :code_analysis do
  sh 'bundle exec standardrb lib test'
  sh 'bundle exec reek lib'
end
