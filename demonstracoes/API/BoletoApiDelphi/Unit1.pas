unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, IdSSLOpenSSL, IdHTTP, superobject,
  IdCoderMIME;

type
  TBoleto = class(TForm)
    GroupBox1: TGroupBox;
    Label4: TLabel;
    Label3: TLabel;
    Label2: TLabel;
    Label1: TLabel;
    edCnpjCedente: TEdit;
    edTokenSh: TEdit;
    edcnpjSH: TEdit;
    cmbAmbiente: TComboBox;
    GroupBox2: TGroupBox;
    Label5: TLabel;
    Label6: TLabel;
    edNossoNumero: TLabeledEdit;
    edNumeroDoc: TLabeledEdit;
    edConta: TLabeledEdit;
    edContaDV: TLabeledEdit;
    edBanco: TLabeledEdit;
    edConvenio: TLabeledEdit;
    btnIncluir: TButton;
    edValor: TLabeledEdit;
    btnConsultar: TButton;
    edidintegracao: TLabeledEdit;
    GroupBox3: TGroupBox;
    btnSolicitarImp: TButton;
    cbtipoimpressao: TComboBox;
    btnConsultarImpressao: TButton;
    edProtImp: TLabeledEdit;
    edSituacaoImp: TLabeledEdit;
    GroupBox5: TGroupBox;
    btnGerarRemessa: TButton;
    mmRemessa: TMemo;
    btnSalvarRemessa: TButton;
    GroupBox4: TGroupBox;
    btnLerRetorno: TButton;
    btnSubirRetorno: TButton;
    mmRetorno: TMemo;
    GroupBox6: TGroupBox;
    mmResposta: TMemo;
    mmRespostaAPI: TMemo;
    SaveDialogRemessa: TSaveDialog;
    OpenDialogRetorno: TOpenDialog;
    SaveDialogPDF: TSaveDialog;
    edSituacaoRetorno: TLabeledEdit;
    edProtocoloRetorno: TLabeledEdit;
    btnConsultarRetorno: TButton;
    procedure ConfigurarAmbiente(const ambiente: integer);
    function HttpRequest(const aBody: string; const aMethod: String; aURL : String; aTimeout : integer;
      aResponseContent: TStringStream = nil; const aContentType: string = ''): string;
    procedure FormCreate(Sender: TObject);
    procedure btnIncluirClick(Sender: TObject);
    procedure btnConsultarClick(Sender: TObject);
    procedure btnSolicitarImpClick(Sender: TObject);
    procedure btnConsultarImpressaoClick(Sender: TObject);
    procedure btnGerarRemessaClick(Sender: TObject);
    procedure btnSalvarRemessaClick(Sender: TObject);
    procedure btnLerRetornoClick(Sender: TObject);
    procedure btnSubirRetornoClick(Sender: TObject);
    procedure btnConsultarRetornoClick(Sender: TObject);
    procedure cmbAmbienteChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Boleto: TBoleto;
  ROTA_URL: string;
  conteudoRemessa: TStringList;

const
  MSG_FIM = 'Retornando valores';
  API_VERSAO1 = '/api/v1';
  ROTA_BOLETO = API_VERSAO1 + '/boletos';
  ROTA_BOLETO_LOTE = API_VERSAO1 + '/boletos/lote';
  ROTA_REMESSA = API_VERSAO1 + '/remessas/lote';
  ROTA_BAIXA = API_VERSAO1 + '/boletos/baixa/lote';
  ROTA_ALTERAR = API_VERSAO1 + '/boletos/altera/lote';
  ROTA_IMPRIME = API_VERSAO1 + '/boletos/impressao/';
  ROTA_RETORNOS = API_VERSAO1 + '/retornos';
  ROTA_CEDENTE = API_VERSAO1 + '/cedentes';
  ROTA_CONTA = API_VERSAO1 + '/cedentes/contas';
  ROTA_CONVENIO = API_VERSAO1 + '/cedentes/contas/convenios';
  ROTA_EMAIL = API_VERSAO1 + '/email';
  ROTA_EMAIL_LOTE = API_VERSAO1 + '/email/lote';
  ROTA_IMPRIME_LOTE = API_VERSAO1 + '/boletos/impressao/lote/';
  ROTA_DESCARTA = API_VERSAO1 + '/boletos/descarta/lote';
  TIMEOUT_PADRAO = 60000;
  FORMATO_DATA_CONSMOV = 'dd/mm/yyyy';
  VERSAO = '3.0.10.6025';
  LIMITE_TENTATIVAS = 3;
  LIMITE_TITULOS_CONSULTA = 1000;

implementation

{$R *.dfm}

{ TForm1 }

procedure TBoleto.btnConsultarClick(Sender: TObject);
var
  erro: string;
  _Objeto: ISuperObject;
  I: integer;
  _StringStream: TStringStream;
begin
  _StringStream:= TStringStream.Create;
  mmRespostaAPI.Clear;
  mmResposta.Clear;

  if edidintegracao.Text = '' then
    mmResposta.Lines.Add('Campo IDintegracao � obrigat�rio')
  else
  begin
    erro:= HttpRequest('', 'GET', ROTA_URL + ROTA_BOLETO + '?idintegracao=' + edidintegracao.Text, TIMEOUT_PADRAO, _StringStream, 'application/json');
    if Erro = '' then
    begin

      _Objeto := SO(Utf8ToAnsi(_StringStream.DataString));
      mmRespostaAPI.Lines.Add(_Objeto.AsJSon(true));

      if _Objeto.S['_mensagem'] = 'Nenhum registro encontrado' then
        mmResposta.Lines.Add('Nenhum registro encontrado')
      else
      begin
        for I := 0 to pred(_Objeto.O['_dados'].AsArray.Length) do
          begin
          mmResposta.Lines.Add('ITEM: ' + IntToStr(I+1));
          mmResposta.Lines.Add('Idintegra��o: ' + _Objeto.O['_dados'].AsArray[I].S['IdIntegracao']);
          mmResposta.Lines.Add('Situacao: ' + _Objeto.O['_dados'].AsArray[I].S['situacao']);
          mmResposta.Lines.Add('');
          mmResposta.Lines.Add('...DADOS...');
          mmResposta.Lines.Add('TituloNossoNumero: ' + _Objeto.O['_dados'].AsArray[I].S['TituloNossoNumero']);
          mmResposta.Lines.Add('TituloNossoNumeroImpressao: ' + _Objeto.O['_dados'].AsArray[I].S['TituloNossoNumeroImpressao']);
          mmResposta.Lines.Add('TituloValor: ' + _Objeto.O['_dados'].AsArray[I].S['TituloValor']);
          mmResposta.Lines.Add('TituloNumeroDocumento: ' + _Objeto.O['_dados'].AsArray[I].S['TituloNumeroDocumento']);
          mmResposta.Lines.Add('TituloDataEmissao: ' + _Objeto.O['_dados'].AsArray[I].S['TituloDataEmissao']);
          mmResposta.Lines.Add('TituloDataVencimento: ' + _Objeto.O['_dados'].AsArray[I].S['TituloDataVencimento']);
          mmResposta.Lines.Add('TituloAceite: ' + _Objeto.O['_dados'].AsArray[I].S['TituloAceite']);
          mmResposta.Lines.Add('TituloDocEspecie: ' + _Objeto.O['_dados'].AsArray[I].S['TituloDocEspecie']);
          mmResposta.Lines.Add('TituloLocalPagamento: ' + _Objeto.O['_dados'].AsArray[I].S['TituloLocalPagamento']);
          mmResposta.Lines.Add('');
          mmResposta.Lines.Add('...JUROS...');
          mmResposta.Lines.Add('TituloCodigoJuros: ' + _Objeto.O['_dados'].AsArray[I].S['TituloCodigoJuros']);
          mmResposta.Lines.Add('TituloValorJuros: ' + _Objeto.O['_dados'].AsArray[I].S['TituloValorJuros']);
          mmResposta.Lines.Add('TituloDataJuros: ' + _Objeto.O['_dados'].AsArray[I].S['TituloDataJuros']);
          mmResposta.Lines.Add('...MULTA...');
          mmResposta.Lines.Add('TituloCodigoMulta: ' + _Objeto.O['_dados'].AsArray[I].S['TituloCodigoMulta']);
          mmResposta.Lines.Add('TituloDataMulta: ' + _Objeto.O['_dados'].AsArray[I].S['TituloDataMulta']);
          mmResposta.Lines.Add('TituloValorMultaTaxa: ' + _Objeto.O['_dados'].AsArray[I].S['TituloValorMultaTaxa']);
          mmResposta.Lines.Add('TituloValorMulta: ' + _Objeto.O['_dados'].AsArray[I].S['TituloValorMulta']);
          mmResposta.Lines.Add('');
          mmResposta.Lines.Add('...DESCONTO 01...');
          mmResposta.Lines.Add('TituloCodDesconto: ' + _Objeto.O['_dados'].AsArray[I].S['TituloCodDesconto']);
          mmResposta.Lines.Add('TituloDataDesconto: ' + _Objeto.O['_dados'].AsArray[I].S['TituloDataDesconto']);
          mmResposta.Lines.Add('TituloValorDescontoTaxa: ' + _Objeto.O['_dados'].AsArray[I].S['TituloValorDescontoTaxa']);
          mmResposta.Lines.Add('PagamentoValorDesconto: ' + _Objeto.O['_dados'].AsArray[I].S['PagamentoValorDesconto']);
          mmResposta.Lines.Add('');
          mmResposta.Lines.Add('...DESCONTO 02...');
          mmResposta.Lines.Add('TituloCodDesconto2: ' + _Objeto.O['_dados'].AsArray[I].S['TituloCodDesconto']);
          mmResposta.Lines.Add('TituloDataDesconto2: ' + _Objeto.O['_dados'].AsArray[I].S['TituloDataDesconto']);
          mmResposta.Lines.Add('TituloValorDescontoTaxa2: ' + _Objeto.O['_dados'].AsArray[I].S['TituloValorDescontoTaxa']);
          mmResposta.Lines.Add('PagamentoValorDesconto2: ' + _Objeto.O['_dados'].AsArray[I].S['PagamentoValorDesconto']);
          mmResposta.Lines.Add('');
          mmResposta.Lines.Add('...SACADO...');
          mmResposta.Lines.Add('SacadoNome: ' + _Objeto.O['_dados'].AsArray[I].S['SacadoNome']);
          mmResposta.Lines.Add('SacadoCPFCNPJ: ' + _Objeto.O['_dados'].AsArray[I].S['SacadoCPFCNPJ']);
          mmResposta.Lines.Add('SacadoEnderecoCidade: ' + _Objeto.O['_dados'].AsArray[I].S['SacadoEnderecoCidade']);
          mmResposta.Lines.Add('SacadoEnderecoBairro: ' + _Objeto.O['_dados'].AsArray[I].S['SacadoEnderecoBairro']);
          mmResposta.Lines.Add('SacadoEnderecoCEP: ' + _Objeto.O['_dados'].AsArray[I].S['SacadoEnderecoCEP']);
          mmResposta.Lines.Add('SacadoEnderecoPais: ' + _Objeto.O['_dados'].AsArray[I].S['SacadoEnderecoPais']);
          mmResposta.Lines.Add('SacadoEnderecoLogradouro: ' + _Objeto.O['_dados'].AsArray[I].S['SacadoEnderecoLogradouro']);
          mmResposta.Lines.Add('SacadoEnderecoComplemento: ' + _Objeto.O['_dados'].AsArray[I].S['SacadoEnderecoComplemento']);
          mmResposta.Lines.Add('SacadoTelefone: ' + _Objeto.O['_dados'].AsArray[I].S['SacadoTelefone']);
          mmResposta.Lines.Add('SacadoEmail: ' + _Objeto.O['_dados'].AsArray[I].S['SacadoEmail']);
          mmResposta.Lines.Add('SacadoEnderecoUF: ' + _Objeto.O['_dados'].AsArray[I].S['SacadoEnderecoUF']);
          mmResposta.Lines.Add('SacadoCelular: ' + _Objeto.O['_dados'].AsArray[I].S['SacadoCelular']);
          mmResposta.Lines.Add('SacadoEnderecoNumero: ' + _Objeto.O['_dados'].AsArray[I].S['SacadoEnderecoNumero']);
          mmResposta.Lines.Add('');
          mmResposta.Lines.Add('...MENSAGENS...');
          mmResposta.Lines.Add('TituloMensagem01: ' + _Objeto.O['_dados'].AsArray[I].S['TituloMensagem01']);
          mmResposta.Lines.Add('TituloMensagem02: ' + _Objeto.O['_dados'].AsArray[I].S['TituloMensagem02']);
          mmResposta.Lines.Add('TituloMensagem03: ' + _Objeto.O['_dados'].AsArray[I].S['TituloMensagem03']);
          mmResposta.Lines.Add('TituloMensagem04: ' + _Objeto.O['_dados'].AsArray[I].S['TituloMensagem04']);
          mmResposta.Lines.Add('TituloMensagem05: ' + _Objeto.O['_dados'].AsArray[I].S['TituloMensagem05']);
          mmResposta.Lines.Add('TituloMensagem06: ' + _Objeto.O['_dados'].AsArray[I].S['TituloMensagem06']);
          mmResposta.Lines.Add('TituloMensagem07: ' + _Objeto.O['_dados'].AsArray[I].S['TituloMensagem07']);
          mmResposta.Lines.Add('TituloMensagem08: ' + _Objeto.O['_dados'].AsArray[I].S['TituloMensagem08']);
          mmResposta.Lines.Add('TituloMensagem09: ' + _Objeto.O['_dados'].AsArray[I].S['TituloMensagem09']);
          mmResposta.Lines.Add('');
          mmResposta.Lines.Add('...AVALISTA...');
          mmResposta.Lines.Add('TituloInscricaoSacadorAvalista: ' + _Objeto.O['_dados'].AsArray[I].S['TituloInscricaoSacadorAvalista']);
          mmResposta.Lines.Add('TituloSacadorAvalistaUF: ' + _Objeto.O['_dados'].AsArray[I].S['TituloSacadorAvalistaUF']);
          mmResposta.Lines.Add('TituloSacadorAvalistaEndereco: ' + _Objeto.O['_dados'].AsArray[I].S['TituloSacadorAvalistaEndereco']);
          mmResposta.Lines.Add('TituloSacadorAvalistaCidade: ' + _Objeto.O['_dados'].AsArray[I].S['TituloSacadorAvalistaCidade']);
          mmResposta.Lines.Add('TituloSacadorAvalista: ' + _Objeto.O['_dados'].AsArray[I].S['TituloSacadorAvalista']);
        end;
        _StringStream.Free;
      end;
    end
    else
    begin
      mmResposta.Lines.Add('Erro ao Consultar o Boleto:');
      mmResposta.Lines.Add(Erro);
    end;
  end;
end;

procedure TBoleto.btnConsultarImpressaoClick(Sender: TObject);
var
  erro, _Retorno, caminho: string;
  I: integer;
  _Objeto: ISuperObject;
  conteudoPDF: TStringList;
  _StringStream: TStringStream;
begin
  mmRespostaAPI.Clear;
  mmResposta.Clear;

  if edProtImp.Text = '' then
    mmResposta.Lines.Add('Campo IDintegracao � obrigat�rio')
  else
  begin
    _StringStream:= TStringStream.Create;

    erro:= HttpRequest('', 'GET',  ROTA_URL + ROTA_IMPRIME_LOTE + edProtImp.Text, TIMEOUT_PADRAO, _StringStream);
   _Objeto := SO(Utf8ToAnsi(_StringStream.DataString));

    if _Objeto.S['_mensagem'] = 'Impress�o em processamento' then
    begin
      mmRespostaAPI.Lines.Add(_Objeto.AsJSon(true));
      edSituacaoImp.Text:= 'PROCESSANDO';
      mmResposta.Lines.Add('Impress�o em processamento');
    end
    else
    begin
      edSituacaoImp.Text:= 'PROCESSADO';
      mmResposta.Lines.Add('Impress�o Processada');

      SaveDialogPDF.Filter := 'PDF file|*.pdf';
      SaveDialogPDF.DefaultExt := 'pdf';

      if SaveDialogPDF.Execute
      then caminho:= SaveDialogPDF.FileName;

      _StringStream.SaveToFile(caminho);
      _StringStream.Free;
    end;
  end;

end;

procedure TBoleto.btnConsultarRetornoClick(Sender: TObject);
var
  erro: string;
  _StringStream: TStringStream;
  _Objeto, _Conciliados, _NaoConciliados: ISuperObject;
begin
  _StringStream:= TStringStream.Create;
  mmRespostaAPI.Clear;
  mmResposta.Clear;

  if edProtocoloRetorno.Text = '' then
    mmResposta.Lines.Add('Campo Protocolo � obrigat�rio')
  else
  begin
    erro:= HttpRequest('', 'GET', ROTA_URL + ROTA_RETORNOS + '/' + edProtocoloRetorno.Text, TIMEOUT_PADRAO, _StringStream, 'application/json');
    if Erro = '' then
    begin
      _Objeto := SO(Utf8ToAnsi(_StringStream.DataString));
      mmRespostaAPI.Lines.Add(_Objeto.AsJSon(true));

      if _Objeto.O['_dados'].S['situacao'] = 'PROCESSADO' then
      begin
        edSituacaoRetorno.Text:= 'PROCESSADO';
        _Conciliados:= _Objeto.O['_dados'].O['titulos'];
        _NaoConciliados:= _Objeto.O['_dados'].O['titulosNaoConciliados'];

        if _Conciliados.AsArray.Length > 0 then
        begin
          mmResposta.Lines.Add('Titulos Conciliados:');
          mmResposta.Lines.Add(_Conciliados.AsJSon(true))
        end;

        if _NaoConciliados.AsArray.Length > 0 then
        begin
          mmResposta.Lines.Add('Titulos N�o Conciliados:');
          mmResposta.Lines.Add(_NaoConciliados.AsJSon(true))
        end;

      end
      else
      begin
        mmResposta.Lines.Add(_Objeto.S['mensagem']);
        edSituacaoRetorno.Text:= _Objeto.S['situacao']
      end;

    end
    else
    begin
      mmResposta.Lines.Add('Erro ao consultar retorno:');
      mmResposta.Lines.Add(erro)
    end;
  end;

end;

procedure TBoleto.btnGerarRemessaClick(Sender: TObject);
var
  erro, json: string;
  I: integer;
  _Objeto, _ObjetoSucesso, _ObjetoFalha: ISuperObject;
  Bytes: String;
  _StringStream: TStringStream;
begin
  mmRespostaAPI.Clear;
  mmResposta.Clear;

  if edidintegracao.Text = '' then
    mmResposta.Lines.Add('Campo IDintegracao � obrigat�rio')
  else
  begin
    _StringStream:= TStringStream.Create;

    json:= '["'+StringReplace(edidintegracao.Text, ',', '","',
   [rfReplaceAll, rfIgnoreCase])+'"]';

    erro := HttpRequest(json, 'POST', ROTA_URL + ROTA_REMESSA, TIMEOUT_PADRAO, _StringStream, 'application/json');
    if erro = '' then
    begin
      _Objeto := SO(Utf8ToAnsi(_StringStream.DataString));
      mmRespostaAPI.Lines.Add(_Objeto.AsJSon(true));

      _ObjetoSucesso:= _Objeto.O['_dados'].O['_sucesso'];
      _ObjetoFalha:= _Objeto.O['_dados'].O['_falha'];

      if _ObjetoSucesso.AsArray.Length > 0 then
      begin
        mmResposta.Lines.Add('Remessa gerada com Sucesso');
        mmResposta.Lines.Add(_ObjetoSucesso.AsArray[0].AsJSon(true));

        conteudoRemessa := TStringList.Create;
        conteudoRemessa.Text := _ObjetoSucesso.AsArray[0].S['remessa'];

        mmRemessa.Lines.Add(conteudoRemessa.Text);
      end;

      if _ObjetoFalha.AsArray.Length > 0 then
      begin
        mmResposta.Lines.Add('Remessa gerada com ERRO !');
        mmResposta.Lines.Add('Erro: ' + _ObjetoFalha.AsArray[0].AsJSon(true) );
      end;
    end
    else
    begin
      mmResposta.Lines.Add('Erro ao gerar a remessa:');
      mmResposta.Lines.Add(Erro);
    end;

  end;

end;

procedure TBoleto.btnIncluirClick(Sender: TObject);
var
  json, Erro: string;
  _Objeto, _ObjetoSucesso, _ObjetoFalha: ISuperObject;
  _StringStream: TStringStream;
begin
  _StringStream:= TStringStream.Create;

  mmRespostaAPI.Clear;
  mmResposta.Clear;
  json:= '[{'+
	'  "CedenteContaNumero": "'+ edConta.Text +'",'+
	'  "CedenteContaNumeroDV": "'+ edContaDV.Text +'",'+
	'  "CedenteConvenioNumero": "'+ edConvenio.Text +'",'+
	'  "CedenteContaCodigoBanco": "'+ edBanco.Text +'",'+
	'  "SacadoEnderecoCEP": "75400000",'+
	'  "TituloDataEmissao": "20/02/2019",'+
	'  "TituloDataVencimento": "22/02/2019",'+
	'  "TituloValor": "'+ edValor.Text +'",'+
	'  "TituloNumeroDocumento": "'+ edNumeroDoc.Text +'",'+
	'  "TituloNossoNumero": "+'+ edNossoNumero.Text +'+",'+
	'  "SacadoNome": "Teste Emiss�o",'+
	'  "SacadoCPFCNPJ": "01001001000113"'+
  '}]';

  Erro := HttpRequest(json, 'POST', ROTA_URL + ROTA_BOLETO_LOTE, TIMEOUT_PADRAO, _StringStream, 'application/json');

  if Erro = '' then
  begin
    _Objeto := SO(Utf8ToAnsi(_StringStream.DataString));
    mmRespostaAPI.Lines.Add(_Objeto.AsJSon(true));

    if _Objeto.S['_status'] = 'sucesso' then
    begin
      _ObjetoSucesso:= _Objeto.O['_dados'].O['_sucesso'];
      _ObjetoFalha:= _Objeto.O['_dados'].O['_falha'];

      if _ObjetoSucesso.AsArray.Length > 0 then
      begin
        mmResposta.Lines.Add(_Objeto.AsJSon(true));
        edidintegracao.Text:= _ObjetoSucesso.AsArray[0].S['idintegracao']
      end;

      if _ObjetoFalha.AsArray.Length > 0 then
      begin
        mmResposta.Lines.Add('Falha ao Emitir o Boleto:');
        mmResposta.Lines.Add('Erro: ' + _ObjetoFalha.AsArray[0].O['_erro'].O['erros'].AsJSon(true) );
      end;

      _StringStream.Free;
    end;
  end
  else
  begin
    mmResposta.Lines.Add('Erro ao Emitir o Boleto:');
    mmResposta.Lines.Add(Erro);
  end;

end;

procedure TBoleto.btnLerRetornoClick(Sender: TObject);
var
  _ss: TStringStream;
begin
  if OpenDialogRetorno.Execute then
  begin
    _ss := TStringStream.Create;
    _ss.LoadFromFile(OpenDialogRetorno.FileName);
    mmRetorno.Lines.Add(_ss.DataString);
  end;
end;

procedure TBoleto.btnSalvarRemessaClick(Sender: TObject);
var
  caminho: string;
begin
  SaveDialogRemessa.Filter := 'TXT file|*.txt';
  SaveDialogRemessa.DefaultExt := 'txt';
  if SaveDialogRemessa.Execute
  then caminho:= SaveDialogRemessa.FileName;

  conteudoRemessa.SaveToFile(caminho);

end;

procedure TBoleto.btnSolicitarImpClick(Sender: TObject);
var
  erro, json, tipoImpressao, idintegracao: string;
  _Objeto: ISuperObject;
  I: integer;
  _StringStream: TStringStream;
begin
  _StringStream:= TStringStream.Create;


  if edidintegracao.Text = '' then
    mmResposta.Lines.Add('Campo IDintegracao � obrigat�rio')
  else
  begin
    if cbtipoimpressao.ItemIndex = 5 then
    tipoImpressao:= '99'
    else
      tipoImpressao:= IntToStr(cbtipoimpressao.ItemIndex);

    idintegracao:= StringReplace(edidintegracao.Text, ',', '","',
     [rfReplaceAll, rfIgnoreCase]);

    json:= '{ '+
           '"tipoImpressao": "'+ tipoImpressao + '",'+
           '"boletos": ["' + idintegracao +'"]'+
           '}';

    erro:= HttpRequest(json, 'POST', ROTA_URL + ROTA_IMPRIME_LOTE, TIMEOUT_PADRAO, _StringStream, 'application/json');

    if Erro = '' then
    begin
      _Objeto := SO(Utf8ToAnsi(_StringStream.DataString));
      mmRespostaAPI.Lines.Add(_Objeto.AsJSon(true));

      if _Objeto.S['_status'] = 'sucesso' then
      begin
        mmResposta.Lines.Add(_Objeto.S['_mensagem']);
        edProtImp.Text:=  _Objeto.O['_dados'].S['protocolo'];
        edSituacaoImp.Text:=  _Objeto.O['_dados'].S['situacao'];
      end;
    end
    else
    begin
      mmResposta.Lines.Add('Erro ao Solicitar Impress�o:');
      mmResposta.Lines.Add(Erro);
    end;

  end;

end;

procedure TBoleto.btnSubirRetornoClick(Sender: TObject);
var
  _StringStream: TStringStream;
  teste, teste2: TStringList;
  erro, json: string;
  _Objeto: ISuperObject;
begin
  mmRespostaAPI.Clear;
  mmResposta.Clear;

  if mmRetorno.Text = '' then
    ShowMessage('Por favor leia um arquivo de retorno')
  else
  begin
    _StringStream:= TStringStream.Create;

    json:= '{"arquivo": "'+ TIdEncoderMIME.EncodeString(mmRetorno.Text) +'"}';

    teste:= TStringList.Create;
    teste.Text:= json;
    teste.SaveToFile('C:\Temp\teste.txt');


    erro := HttpRequest(json, 'POST',  ROTA_URL + ROTA_RETORNOS, TIMEOUT_PADRAO, _StringStream, 'application/json');

    if erro = '' then
    begin
      _Objeto := SO(Utf8ToAnsi(_StringStream.DataString));
      mmRespostaAPI.Text:= _Objeto.AsJSon(true);

      if _Objeto.S['_mensagem'] = 'Retorno pendente de processamento' then
      begin
        edSituacaoRetorno.Text:= 'PROCESSANDO';
        edProtocoloRetorno.Text:= _Objeto.O['_dados'].S['protocolo'];
        mmResposta.Lines.Add('Retorno pendente de processamento');
      end;
    end
    else
    begin
      mmResposta.Lines.Add('Erro ao enviar retorno:');
      mmResposta.Lines.Add(Erro);
    end;

  end;


end;

procedure TBoleto.cmbAmbienteChange(Sender: TObject);
begin
  ConfigurarAmbiente(cmbAmbiente.ItemIndex);
end;

procedure TBoleto.ConfigurarAmbiente(const ambiente: integer);
begin
  if ambiente = 0 then
    ROTA_URL:= 'https://cobrancabancaria.tecnospeed.com.br';

  if ambiente = 1 then
    ROTA_URL:= 'http://homologacao.cobrancabancaria.tecnospeed.com.br';
end;

procedure TBoleto.FormCreate(Sender: TObject);
begin
  ConfigurarAmbiente(cmbAmbiente.ItemIndex);
end;

function TBoleto.HttpRequest(const aBody, aMethod: String; aURL: String;
  aTimeout: integer; aResponseContent: TStringStream;
  const aContentType: string): string;
var
   JSONResposta : string ;
   idSSLIOHandler : TIdSSLIOHandlerSocketOpenSSL;
   idHttp : TIdHTTP;
   _aux : TStrings;
begin
  idHttp := TIdHTTP.Create(nil);
  idSSLIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);

  IdSSLIOHandler.ConnectTimeout := aTimeout;
  idSSLIOHandler.ReadTimeout := aTimeout;

  IdHTTP.IOHandler := IdSSLIOHandler;
  IdHTTP.HandleRedirects := True;
  IdHTTP.HTTPOptions := [];
  IdHTTP.ConnectTimeout := aTimeout;
  IdHTTP.ReadTimeout := aTimeout;

  IdHTTP.Request.ContentType := aContentType;

  idHttp.Request.CustomHeaders.AddValue('cnpj-sh', edcnpjSH.Text);
  idHttp.Request.CustomHeaders.AddValue('token-sh', edTokenSh.Text);
  idHttp.Request.CustomHeaders.AddValue('cnpj-cedente', edCnpjCedente.Text);

  _aux := TStringList.Create;
  _aux.Text := aBody;

  if aMethod = 'GET' then
   Begin
     try
       idHttp.Get(aURL, aResponseContent);
     except
       on E: EIdHTTPProtocolException do begin
         Result := E.ErrorMessage
       end;
     end;
   End
   else if aMethod = 'POST' then
   begin
     try
       idHttp.Post(aURL, _aux, aResponseContent);
     except
       on E: EIdHTTPProtocolException do begin
         if E.ErrorCode = 400 then
           Result := E.ErrorMessage
         else
         if E.ErrorCode = 401 then
           Result := E.ErrorMessage
         else
         if E.ErrorCode = 403 then
           Result := E.ErrorMessage
         else
         raise;
       end;
     end;
   end;

end;

end.
