require_relative '../../../test_helper'

describe Nfse::Envio::Lote do

  subject { Nfse::Envio::Lote.new }

  describe 'id attribute' do
    it 'must have the accessors methods' do
      subject.must_respond_to :id
      subject.must_respond_to :id=
    end

    it 'must have the right default value' do
      time = Time.now.to_i
      Time.expects(:now).returns(time)

      subject.id.must_equal "#{subject.object_id}#{time}"
    end
  end

  describe 'numero attribute' do
    it 'must have the accessors methods' do
      subject.must_respond_to :numero
      subject.must_respond_to :numero=
    end

    it 'must have the right default value' do
      subject.numero.must_equal 1
    end

    it 'must coerce the value to integer' do
      subject.numero = '123'
      subject.numero.must_equal 123
    end
  end

  describe 'cod_cidade attribute' do
    it 'must have the accessors methods' do
      subject.must_respond_to :cod_cidade
      subject.must_respond_to :cod_cidade=
    end
  end

  describe 'cnpj attribute' do
    it 'must have the accessors methods' do
      subject.must_respond_to :cnpj
      subject.must_respond_to :cnpj=
    end
  end

  describe 'razao_social attribute' do
    it 'must have the accessors methods' do
      subject.must_respond_to :razao_social
      subject.must_respond_to :razao_social=
    end
  end

  describe 'inscricao_municipal attribute' do
    it 'must have the accessors methods' do
      subject.must_respond_to :inscricao_municipal
      subject.must_respond_to :inscricao_municipal=
    end
  end

  describe 'transacao attribute' do
    it 'must have the accessors methods' do
      subject.must_respond_to :transacao
      subject.must_respond_to :transacao=
    end

    it 'must have the right default value' do
      subject.transacao.must_equal 'true'
    end
  end

  describe 'rps attribute' do
    it 'must have the accessors methods' do
      subject.must_respond_to :rps
      subject.must_respond_to :rps=
    end

    it 'must be an Array' do
      subject.rps.must_be_instance_of Array
    end

    it 'must build a Rps when passing a hash of attributes' do
      subject.rps = [{}]

      rps = subject.rps[0]
      rps.must_be_instance_of Nfse::Envio::Rps
    end
  end

  describe 'versao attribute' do
    it 'must have the accessors methods' do
      subject.must_respond_to :versao
      subject.must_respond_to :versao=
    end

    it 'must have the right default value' do
      subject.versao.must_equal 1
    end

    it 'must coerce the value to integer' do
      subject.versao = '123'
      subject.versao.must_equal 123
    end
  end

  describe 'metodo_envio attribute' do
    it 'must have the accessors methods' do
      subject.must_respond_to :metodo_envio
      subject.must_respond_to :metodo_envio=
    end

    it 'must have the right default value' do
      subject.metodo_envio.must_equal 'WS'
    end
  end

  describe '#qtd_rps' do
    it 'must return the count of RPSes that the lote has' do
      subject.rps.push(*(1..10).to_a)
      subject.qtd_rps.must_equal 10
    end
  end

  describe '#valor_servicos' do
    it 'must return the sum of all Rps#valor_servico' do
      subject.rps << stub(valor_servico: 1000)
      subject.rps << stub(valor_servico: 500)

      subject.valor_servicos.must_equal 1500
    end
  end

  describe '#valor_deducoes' do
    it 'must return the sum of all Rps#valor_deducao' do
      subject.rps << stub(valor_deducao: 1000)
      subject.rps << stub(valor_deducao: 500)

      subject.valor_deducoes.must_equal 1500
    end
  end

  describe '#data_inicio' do
    it "must return the #data_emissao of the first Lote's RPS" do
      date = Time.new(2012, 1, 1)

      subject.rps << stub(data_emissao: date)
      subject.rps << stub(data_emissao: Time.new(1900, 1, 1))

      subject.data_inicio.must_equal date.strftime('%Y-%m-%d')
    end
  end

  describe '#data_fim' do
    it "must return the #data_emissao of the last Lote's RPS" do
      date = Time.new(2012, 1, 1)

      subject.rps << stub(data_emissao: Time.new(1900, 1, 1))
      subject.rps << stub(data_emissao: date)

      subject.data_fim.must_equal date.strftime('%Y-%m-%d')
    end
  end

  describe 'intialize passing JSON as argument' do
    before do
      @attributes = {
        id: '1',
        rps: [{ numero: 2 }]
      }

      @lote = Nfse::Envio::Lote.new(JSON.generate(@attributes))
    end

    it 'lote sould have your attributes defined correctly' do
      @lote.id.must_equal(@attributes[:id])
    end

    it 'rps should have your attributes defined correctly' do
      rps = @lote.rps.first
      rps.numero.must_equal(@attributes[:rps].first[:numero])
    end
  end

  describe '#render' do
    describe 'campinas' do
      before do
        Nfse::Base.prefeitura = :campinas

        subject.id = '1ABCDZ'
        subject.cod_cidade = '6291'
        subject.cnpj = '02646676000182'
        subject.razao_social = 'EMPRESA RESP. MODELO'

        # Rps
        subject.rps << stub(render: xml('RPS[1]', prefeitura: :campinas, file: :envio))
        subject.rps << stub(render: xml('RPS[2]', prefeitura: :campinas, file: :envio))
      end

      it 'prefeitura must be right' do
        subject.template_file.must_include 'campinas'
      end

      it 'must render the right xml' do
        subject.expects(:data_inicio).returns('2009-10-01')
        subject.expects(:data_fim).returns('2009-10-01')
        subject.expects(:qtd_rps).returns(2)
        subject.expects(:valor_servicos).returns('11.00')
        subject.expects(:valor_deducoes).returns('49.30')

        xml('ns1:ReqEnvioLoteRPS', str: subject.render).must_equal xml('ns1:ReqEnvioLoteRPS', prefeitura: :campinas, file: :envio)
      end
    end

    describe 'rio_de_janeiro' do
      before do
        Nfse::Base.prefeitura = :rio_de_janeiro

        subject.numero = '3'
        subject.id = '1ABCDZ'
        subject.cnpj = '02646676000182'
        subject.inscricao_municipal = '001002003'

        # Rps
        subject.rps << stub(render: xml('Rps[1]', prefeitura: :rio_de_janeiro, file: :envio))
        subject.rps << stub(render: xml('Rps[2]', prefeitura: :rio_de_janeiro, file: :envio))
      end

      it 'prefeitura must be right' do
        subject.template_file.must_include 'rio_de_janeiro'
      end

      it 'must render the right xml' do
        xml('EnviarLoteRpsEnvio', str: subject.render).must_equal xml('EnviarLoteRpsEnvio', prefeitura: :rio_de_janeiro, file: :envio)
      end
    end
  end

end
