require 'minitest/autorun'
require 'webmock/minitest'
require 'dropbox'

def error(message)
  <<-EOS
HTTP/1.1 409 Conflict
Content-Type: application/json

{
    "error_summary": "#{message}/...",
    "error": {
        ".tag": "#{message}"
    }
}
  EOS
end

def too_many_write_operations_error
  <<-EOS
HTTP/1.1 429 Too Many Requests
Content-Type: application/json

{
    "error_summary": "too_many_write_operations/...",
    "error": {
        ".tag": "too_many_write_operations"
    }
}
  EOS
end

def stub(name)
  File.new("test/stubs/#{name}.json")
end

def url(path)
  "https://api.dropboxapi.com/2/#{path}"
end

def content_url(path)
  "https://content.dropboxapi.com/2/#{path}"
end
