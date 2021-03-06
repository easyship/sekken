require 'spec_helper'

describe Sekken::Operation do

  subject(:operation)  { Sekken::Operation.new(wsdl_operation, wsdl, http_mock) }

  let(:wsdl)           { Sekken::WSDL.new fixture('wsdl/temperature'), http_mock }
  let(:wsdl_operation) { wsdl.operation('ConvertTemperature', 'ConvertTemperatureSoap12', 'ConvertTemp') }

  describe '#endpoint' do
    it 'returns the SOAP endpoint' do
      expect(operation.endpoint).to eq('http://www.webservicex.net/ConvertTemperature.asmx')
    end

    it 'can be overwritten' do
      operation.endpoint = 'http://example.com'
      expect(operation.endpoint).to eq('http://example.com')
    end
  end

  describe '#soap_version' do
    it 'returns the SOAP version determined by the service and port' do
      expect(operation.soap_version).to eq('1.2')
    end

    it 'can be overwritten' do
      operation.soap_version = '1.1'
      expect(operation.soap_version).to eq('1.1')
    end
  end

  describe '#soap_action' do
    it 'returns the SOAP action for the operation' do
      expect(operation.soap_action).to eq('http://www.webserviceX.NET/ConvertTemp')
    end

    it 'can be overwritten' do
      operation.soap_action = 'ConvertSomething'
      expect(operation.soap_action).to eq('ConvertSomething')
    end
  end

  describe '#encoding' do
    it 'defaults to UTF-8' do
      expect(operation.encoding).to eq('UTF-8')
    end

    it 'can be overwritten' do
      operation.encoding = 'US-ASCII'
      expect(operation.encoding).to eq('US-ASCII')
    end
  end

  describe '#http_headers' do
    it 'returns a Hash of HTTP headers for a SOAP 1.2 operation' do
      expect(operation.http_headers).to eq(
        'Content-Type' => 'application/soap+xml;charset=UTF-8;action="http://www.webserviceX.NET/ConvertTemp"'
      )
    end

    it 'returns a Hash of HTTP headers for a SOAP 1.1 operation' do
      wsdl_operation = wsdl.operation('ConvertTemperature', 'ConvertTemperatureSoap', 'ConvertTemp')
      operation = Sekken::Operation.new(wsdl_operation, wsdl, http_mock)

      expect(operation.http_headers).to eq(
        'SOAPAction'   => '"http://www.webserviceX.NET/ConvertTemp"',
        'Content-Type' => 'text/xml;charset=UTF-8'
      )
    end

    it 'can be overwritten' do
      headers = { 'SecretToken' => 'abc'}
      operation.http_headers = headers

      expect(operation.http_headers).to eq(headers)
    end
  end

  describe '#example_request' do
    it 'returns an example request Hash following Sekken\'s conventions' do
      expect(operation.example_body).to eq(
        ConvertTemp: {
          Temperature: 'double',
          FromUnit: 'string',
          ToUnit: 'string'
        }
      )
    end
  end

  describe '#build' do
    it 'returns an example request Hash following Sekken\'s conventions' do
      operation.body = {
        ConvertTemp: {
          Temperature: 30,
          FromUnit: 'degreeCelsius',
          ToUnit: 'degreeFahrenheit'
        }
      }

      expected = Nokogiri.XML(%{
        <env:Envelope
            xmlns:lol0="http://www.webserviceX.NET/"
            xmlns:env="http://www.w3.org/2003/05/soap-envelope">
          <env:Header/>
          <env:Body>
            <lol0:ConvertTemp>
              <lol0:Temperature>30</lol0:Temperature>
              <lol0:FromUnit>degreeCelsius</lol0:FromUnit>
              <lol0:ToUnit>degreeFahrenheit</lol0:ToUnit>
            </lol0:ConvertTemp>
          </env:Body>
        </env:Envelope>
      })

      expect(operation.build).
        to be_equivalent_to(expected).respecting_element_order
    end
  end

  describe '#xml_envelope' do
    let(:xml) do
      '<?xml version="1.0" encoding="UTF-8"?>
    <Envelope>
      <Body>
        <VerifySignature>
          <UrlEndPoint></UrlEndPoint>
          <HttpParameters></HttpParameters>
        </VerifySignature>
      </Body>
    </Envelope>'
    end

    it 'returns the xml request' do
      http_mock.fake_request('http://www.webservicex.net/ConvertTemperature.asmx')
      operation.xml_envelope = xml

      expect(operation.xml_envelope).to eq(xml)
    end

    it 'returns a Sekken response object' do
      http_mock.fake_request('http://www.webservicex.net/ConvertTemperature.asmx')
      operation.xml_envelope = xml

      response = operation.call
      expect(response).to be_a(Sekken::Response)
    end
  end

  describe '#call' do
    it 'calls the operation with a Hash of options and returns a Response' do
      http_mock.fake_request('http://www.webservicex.net/ConvertTemperature.asmx')

      operation.body = {
        ConvertTemp: {
          Temperature: 30,
          FromUnit: 'degreeCelsius',
          ToUnit: 'degreeFahrenheit'
        }
      }

      response = operation.call

      expect(response).to be_a(Sekken::Response)
    end
  end

end
