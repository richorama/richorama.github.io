#!/usr/bin/env ruby

require "date"
require "fileutils"
require "yaml"

ROOT = File.expand_path("..", __dir__)
SITE_URL = "https://richorama.github.io"
POSTS_DIR = File.join(ROOT, "_posts")
MARKDOWN_DIR = File.join(ROOT, "markdown")

def parse_post(path)
  source = File.read(path)
  match = source.match(/\A---\s*\n(.*?)\n---\s*\n(.*)\z/m)
  raise "Missing front matter in #{path}" unless match

  data = YAML.safe_load(
    match[1],
    permitted_classes: [Date, Time],
    aliases: true
  )

  filename = File.basename(path)
  filename_match = filename.match(/\A(\d{4})-(\d{2})-(\d{2})-(.+)\.md\z/)
  raise "Unexpected post filename: #{filename}" unless filename_match

  categories = Array(data["categories"]).flat_map { |value| value.to_s.split }
  slug = filename_match[4]
  date = Date.parse(data.fetch("date").to_s)
  html_path = (categories + [date.strftime("%Y"), date.strftime("%m"), date.strftime("%d"), slug]).join("/")

  {
    filename: filename,
    title: data.fetch("title").to_s.strip,
    summary: data.fetch("summary").to_s.strip,
    date: date,
    body: match[2].rstrip,
    html_url: "#{SITE_URL}/#{html_path}/",
    markdown_url: "#{SITE_URL}/markdown/#{filename}"
  }
end

def markdown_post(post)
  <<~MARKDOWN
    # #{post[:title]}

    Published: #{post[:date].iso8601}  
    Canonical HTML: #{post[:html_url]}

    #{post[:summary]}

    ---

    #{post[:body]}
  MARKDOWN
end

def agents_index(posts)
  entries = posts.map do |post|
    <<~MARKDOWN
      ## [#{post[:title]}](#{post[:html_url]})

      Published #{post[:date].iso8601}. #{post[:summary]}

      [Markdown](#{post[:markdown_url]})
    MARKDOWN
  end

  <<~MARKDOWN
    # Richard Astbury's Blog

    Agent-readable index of articles by Richard Astbury about software engineering,
    cloud architecture, AI, mapping, Microsoft Azure, and developer tools.

    - Website: #{SITE_URL}/
    - RSS feed: #{SITE_URL}/feed.xml
    - Sitemap: #{SITE_URL}/sitemap.xml
    - Compact LLM index: #{SITE_URL}/llms.txt

    # Blog posts

    #{entries.join("\n")}
  MARKDOWN
end

def llms_index(posts)
  entries = posts.map do |post|
    "- [#{post[:title]}](#{post[:markdown_url]}): #{post[:summary]}"
  end

  <<~TEXT
    # Richard Astbury's Blog

    > Articles by Richard Astbury about software engineering, cloud architecture,
    > AI, mapping, Microsoft Azure, and developer tools.

    Canonical website: #{SITE_URL}/
    RSS feed: #{SITE_URL}/feed.xml
    Sitemap: #{SITE_URL}/sitemap.xml
    Detailed agent index: #{SITE_URL}/agents.md

    ## Posts

    #{entries.join("\n")}
  TEXT
end

posts = Dir.glob(File.join(POSTS_DIR, "*.md")).map { |path| parse_post(path) }
posts.sort_by! { |post| post[:date] }.reverse!

outputs = {
  File.join(ROOT, "agents.md") => agents_index(posts),
  File.join(ROOT, "llms.txt") => llms_index(posts)
}
posts.each do |post|
  outputs[File.join(MARKDOWN_DIR, post[:filename])] = markdown_post(post)
end

if ARGV.include?("--check")
  stale = outputs.filter_map do |path, expected|
    path unless File.exist?(path) && File.read(path) == expected
  end
  extra = Dir.glob(File.join(MARKDOWN_DIR, "*.md")) - outputs.keys
  stale.concat(extra)

  unless stale.empty?
    warn "Agent content is out of date:"
    stale.each { |path| warn "  #{path.delete_prefix("#{ROOT}/")}" }
    warn "Run: ruby scripts/generate-agent-content.rb"
    exit 1
  end

  puts "Agent content is up to date (#{posts.length} posts)."
  exit
end

FileUtils.mkdir_p(MARKDOWN_DIR)
outputs.each do |path, content|
  File.write(path, content)
end

puts "Generated agent content for #{posts.length} posts."
