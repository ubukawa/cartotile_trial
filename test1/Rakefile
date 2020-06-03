desc 'host the site'
task :host do
  sh "budo -d docs"
end

desc 'build the site'
task :build do
  sh "ruby build.rb src/WHO-COVID-19-global-data.csv > docs/index.html"
end
