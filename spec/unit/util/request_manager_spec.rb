require 'spec_helper'
require 'puppet/util/request_manager'

describe '#perform_http_request' do
  let(:uri) { 'http://test.com' }
  let(:method) { :get }

  def call_perform_http_request
    parameters = { method: method }
    expectations = { codes: codes }
    expectations[:messages] = messages if defined?(messages)

    Puppet::Util::RequestManager.perform_http_request(URI(uri), parameters, expectations, timeout)
  end

  after do
    WebMock.reset!
  end

  context 'with matching code and message' do
    let(:codes) { [201] }
    let(:messages) { ['test'] }
    let(:timeout) { 60 }
    it do
      stub_request(method, /.*test.com.*/).to_return(status: [201], body: 'test')

      expect(call_perform_http_request).to be true
      expect(WebMock).to have_requested(method, uri).times(1)
    end
  end

  context 'with matching code and not matching message' do
    let(:codes) { [200] }
    let(:messages) { ['not matching message'] }
    let(:timeout) { 0 }
    it do
      stub_request(method, /.*test.com.*/).to_return(status: [200], body: 'test')

      expect(call_perform_http_request).to be false
      expect(WebMock).to have_requested(method, uri).times(1)
    end
  end

  context 'with two failed requests and one success request' do
    let(:codes) { [200] }
    let(:timeout) { 60 }
    it do
      stub_request(method, /.*test.com.*/).to_return(status: [404]).then
                                          .to_return(status: [404]).then
                                          .to_return(status: [200])

      expect(call_perform_http_request).to be true
      expect(WebMock).to have_requested(method, uri).times(3)
    end
  end

  context 'with one timeouted, one not found and one fatal request' do
    let(:codes) { [200] }
    let(:timeout) { 60 }
    it do
      stub_request(method, /.*test.com.*/).to_timeout.then
                                          .to_return(status: [404]).then
                                          .to_return(status: [501]).then

      expect { call_perform_http_request }.to raise_error(Puppet::Error, /Unrecoverable response recieved/)
      expect(WebMock).to have_requested(method, uri).times(3)
    end
  end

  context 'with too many not found requests' do
    let(:codes) { [200] }
    let(:timeout) { 10 }
    it do
      stub_request(method, /.*test.com.*/).to_return(status: [404]).times(20)

      expect(call_perform_http_request).to be false
      expect(a_request(method, uri)).to have_been_made.at_least_times(6)
    end
  end
end
