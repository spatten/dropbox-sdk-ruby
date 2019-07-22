require 'test_helper'

class DropboxClientTest < Minitest::Test
  def test_client_initialize
    dbx = Dropbox::Client.new('12345678' * 8)

    assert dbx.is_a?(Dropbox::Client), 'Dropbox::Client did not initialize'
  end

  def test_client_initialize_error
    assert_raises(Dropbox::ClientError) do
      Dropbox::Client.new('')
    end

    assert_raises(Dropbox::ClientError) do
      Dropbox::Client.new(nil)
    end
  end

  def test_invalid_access_token
    dbx = Dropbox::Client.new('12345678' * 8)

    stub_request(:post, url('auth/token/revoke')).to_return(error('invalid_token'))
    assert_raises(Dropbox::ApiError) do
      dbx.revoke_token
    end
  end

  def test_too_many_write_requests_errors
    too_many_writes_response = {'status' => 429, 'body' => {
    "error_summary": "too_many_write_operations/...",
    "error": {
               ".tag": "too_many_write_operations"
             }
    }.to_json}
    success_response = stub('file')
    stub_request(:post, url('files/delete'))
      .to_return(too_many_writes_response,
                 success_response)
    dbx = Dropbox::Client.new('12345678' * 8)
    response = dbx.delete('/testing123/foo83.txt')
    assert_instance_of Dropbox::FileMetadata, response
  end

  def test_too_many_write_upload_requests_errors
    too_many_writes_response = {'status' => 429, 'body' => {
    "error_summary": "too_many_write_operations/...",
    "error": {
               ".tag": "too_many_write_operations"
             }
    }.to_json}
    success_response = stub('file')
    stub_request(:post, content_url('files/upload'))
      .to_return(too_many_writes_response,
                 success_response)
    dbx = Dropbox::Client.new('12345678' * 8)
    response = dbx.upload('/testing123/foo83.txt', 'some content')
    assert_instance_of Dropbox::FileMetadata, response
  end

  def test_too_many_write_content_requests_errors
    too_many_writes_response = {'status' => 429, 'body' => {
    "error_summary": "too_many_write_operations/...",
    "error": {
               ".tag": "too_many_write_operations"
             }
    }.to_json}
    success_response = stub('file_content')
    stub_request(:get, content_url('files/download'))
      .to_return(too_many_writes_response,
                 success_response)
    dbx = Dropbox::Client.new('12345678' * 8)
    response = dbx.download('/testing123/foo83.txt')
    assert_instance_of Dropbox::FileMetadata, response.first
  end
end
