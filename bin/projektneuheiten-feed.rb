#!/usr/bin/env ruby1.9.3
# encoding: UTF-8

# The MIT License (MIT)

# Copyright (c) 2014 <m.a.n.u.e.l@posteo.net>

# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Source:
# http://git.io/vOZ2l

require 'rubygems'
require 'net/http'
require 'digest'
require 'fileutils'
require 'json'
require 'date'
require 'cgi'
require 'erb'

include ERB::Util
include FileUtils

ATOM = <<-EOF
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title><%= TITLE %></title>
  <subtitle><%= TITLE %></subtitle>
  <id>uuid:<%= TITLE %></id>
  <link href="<%= SELF %>" rel="self" type="application/atom+xml" />
  <link href="<%= LINK %>" />
  <updated><%= UPDATED %></updated>
  <author>
    <name>Wikipedia</name>
    <email>m.a.n.u.e.l@posteo.net</email>
  </author>
  <% for item in SECTIONS[0...SECTIONS.length-2] %>
  <entry>
    <title><%= item.title %></title>
    <link href="<%= item.link %>"/>
    <id><%= item.id %></id>
    <updated><%= item.rfc3339 %></updated>
    <content type="html" xml:base="<%= API_BASE %>"><![CDATA[<%= item.content %>]]></content>
  </entry>
  <% end %>
</feed>
EOF

RSS = <<-EOF
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0"
  xmlns:content="http://purl.org/rss/1.0/modules/content/"
  xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <title><%= TITLE %></title>
    <description><%= TITLE %></description>
    <link><%= LINK %></link>
    <atom:link href="<%= SELF %>" rel="self" type="application/rss+xml" />
    <language>de-DE</language>
    <% for item in SECTIONS[0...SECTIONS.length-2] %>
      <item>
        <title><%= item.title %></title>
        <guid isPermaLink="false"><%= item.id %></guid>
        <link><%= item.link %></link>
        <pubDate><%= item.rfc822 %></pubDate>
        <description><![CDATA[<%= item.qualified %>]]></description>
        <content:encoded><![CDATA[<%= item.qualified %>]]></content:encoded>
      </item>
    <% end %>
  </channel>
</rss>
EOF

API_AGENT  = 'Wikipedia:Projektneuheiten (Feed) - German-Wikipedia'
API_BASE   = 'https://de.wikipedia.org'
API_FORMAT = 'format=json'
API_ACTION = 'action=query'
API_TITLES = 'titles=Wikipedia:Projektneuheiten'
API_PARAMS = 'prop=revisions&rvprop=content&rvparse'

API_URI    = URI "#{API_BASE}/w/api.php?#{API_FORMAT}&#{API_ACTION}&#{API_TITLES}&#{API_PARAMS}"

TITLE      = 'Wikipedia:Projektneuheiten'
LINK       = 'https://de.wikipedia.org/wiki/Wikipedia:Projektneuheiten'
SECTIONS   = []
WEB        = CGI.new
REFERENCE  = 'r3'
SELF       = 'https://tools.wmflabs.org' + ENV['REQUEST_URI'].to_s

FORMAT = case WEB['type']
  when /rss/ then :rss
  when /atom/ then :atom
  else :atom
end

class Section
  attr_reader :title, :content, :year

  def initialize(title)
    @title   = title
    @content = String.new

    def @title.int
      sub(/Februar/, 'February')
      .sub(/März/, 'March')
      .sub(/Mai/, 'May')
      .sub(/Juni/, 'June')
      .sub(/Juli/, 'July')
      .sub(/Oktober/, 'October')
      .sub(/Dezember/, 'December')
    end
  end

  def qualified
    @content.gsub(/href="(\/)([^"]*)"/, "href=\"#{API_BASE}" + '\1\2"')
  end

  def id
    'uuid:' + FORMAT.to_s + '-' + REFERENCE + '-' + Digest::MD5.hexdigest(content).to_s
  end

  def link
    LINK + title.sub(/(\d*)\. (\w*)/, '#\1._\2')
  end

  def rfc822
    DateTime.parse(title.int + ' ' + year).strftime("%a, %d %b %Y %H:%M:%S %z")
  end

  def rfc3339
    DateTime.parse(title.int + ' ' + year).strftime('%Y-%m-%dT%H:%M:%S.00Z')
  end

  def year=(value)
    @year = value
  end

  def <<(line)
    @content += line
  end
end

def generate
  # 1/2h = 30min = 1800s
  if File.mtime('api.backup.json').to_i < (Time.now.to_i - 1800)
    begin
      return if File.writable? 'api.json'
      File.open 'api.json', 'w' do |io|
        Net::HTTP.start API_URI.host, API_URI.port, use_ssl: true do |http|
          request = Net::HTTP::Get.new API_URI.to_s, 'User-Agent' => API_AGENT
          http.request request do |response|
            raise "HTTP #{response.code}" unless response.kind_of? Net::HTTPSuccess
            response.read_body { |chunk| io << chunk }
          end
        end
      end
      File.rename 'api.json', 'api.backup.json'
    end
  end
  rescue Exception => msg
    # Display the system generated error message
    rm 'api.json'
    $stderr.puts msg
    exit 1
end

def parse
  title = String.new
  year = case FORMAT
    # RFC 822
    when :rss then DateTime.now.strftime("%a, %d %b %Y %H:%M:%S %z")
    # RFC 3339
    when :atom then DateTime.now.strftime('%Y-%m-%dT%H:%M:%S.00Z')
  end

  File.open 'api.backup.json', 'r' do |fd|
    json     = JSON.parse(fd.read)
    title    = json['query']['pages']['3180504']['title']
    revision = json['query']['pages']['3180504']['revisions'][0]['*']
  
    revision.each_line do |line|
      year = $1 if line =~ /<h2><[^>]*>\w+ (\d+)<\/[^>]*>/
      next if line =~ /<h1|2>/
      if line =~ /mw-headline"[^>]*>(\d+\.[^<]*)<\/[^>]*>/
        SECTIONS << Section.new($1)
      else
        if SECTIONS.last.is_a? Section
          SECTIONS.last.year = year
          SECTIONS.last << line
        end
      end
    end
  end
end

touch 'api.backup.json',
  mtime: Time.mktime(1970, 1, 1),
  verbose: false unless File.file? 'api.backup.json'

generate
parse

case FORMAT
  when :rss
    UPDATED = File.mtime('api.backup.json').strftime("%a, %d %b %Y %H:%M:%S %z")
    WEB.out('application/rss+xml') { ERB.new(RSS).result() }
  else
    UPDATED = File.mtime('api.backup.json').strftime('%Y-%m-%dT%H:%M:%S.00Z')
    WEB.out('application/atom+xml') { ERB.new(ATOM).result() }
end
