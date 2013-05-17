guard 'bundler' do
  watch('Gemfile')
end

guard 'rspec', cli: '--format Fuubar --color', version: 2 do
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^spec/.+_spec\.rb$})
  watch('spec/spec_helper.rb')  { "spec" }
end