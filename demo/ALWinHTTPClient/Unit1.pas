unit Unit1;

interface

uses Windows,
     Messages,
     SysUtils,
     Variants,
     Classes,
     Graphics,
     Controls,
     Forms,
     Dialogs,
     StdCtrls,
     shellapi,
     ExtCtrls,
     ComCtrls,
     AlWinHttpClient,
     AlWinHttpWrapper,
     OleCtrls,
     SHDocVw,
     ComObj;

type
  TForm1 = class(TForm)
    MainStatusBar: TStatusBar;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    GroupBox3: TGroupBox;
    Label18: TLabel;
    Label19: TLabel;
    EditUserName: TEdit;
    EditPassword: TEdit;
    GroupBox4: TGroupBox;
    Label14: TLabel;
    Label17: TLabel;
    Label20: TLabel;
    EditSendTimeout: TEdit;
    EditReceiveTimeout: TEdit;
    EditConnectTimeout: TEdit;
    GroupBox6: TGroupBox;
    GroupBox7: TGroupBox;
    GroupBox2: TGroupBox;
    RadioButtonAccessType_NAMED_PROXY: TRadioButton;
    RadioButtonAccessType_NO_PROXY: TRadioButton;
    RadioButtonAccessType_DEFAULT_PROXY: TRadioButton;
    GroupBox1: TGroupBox;
    Label15: TLabel;
    Label12: TLabel;
    Label11: TLabel;
    Label16: TLabel;
    Label13: TLabel;
    EdProxyPort: TEdit;
    EdProxyUserName: TEdit;
    EdProxyServer: TEdit;
    EdProxyPassword: TEdit;
    EdProxyBypass: TEdit;
    GroupBox5: TGroupBox;
    Label24: TLabel;
    EditBufferUploadSize: TEdit;
    CheckBoxInternetOption_BYPASS_PROXY_CACHE: TCheckBox;
    CheckBoxInternetOption_ESCAPE_DISABLE: TCheckBox;
    CheckBoxInternetOption_REFRESH: TCheckBox;
    CheckBoxInternetOption_SECURE: TCheckBox;
    CheckBoxInternetOption_ESCAPE_PERCENT: TCheckBox;
    CheckBoxInternetOption_NULL_CODEPAGE: TCheckBox;
    CheckBoxInternetOption_ESCAPE_DISABLE_QUERY: TCheckBox;
    GroupBox8: TGroupBox;
    MemoRequestRawHeader: TMemo;
    Label8: TLabel;
    RadioButtonProtocolVersion1_0: TRadioButton;
    RadioButtonProtocolVersion1_1: TRadioButton;
    GroupBox9: TGroupBox;
    editURL: TEdit;
    Label4: TLabel;
    Label6: TLabel;
    MemoPostDataStrings: TMemo;
    MemoPostDataFiles: TMemo;
    Label7: TLabel;
    Label5: TLabel;
    GroupBox10: TGroupBox;
    Label2: TLabel;
    MemoResponseRawHeader: TMemo;
    MemoContentBody: TMemo;
    Label3: TLabel;
    Label1: TLabel;
    ButtonPost: TButton;
    ButtonGet: TButton;
    ButtonOpenInExplorer: TButton;
    CheckBoxInternetOption_KEEP_CONNECTION: TCheckBox;
    CheckBoxInternetOption_NO_COOKIES: TCheckBox;
    CheckBoxInternetOption_NO_AUTO_REDIRECT: TCheckBox;
    CheckBoxHttpEncodePostData: TCheckBox;
    ButtonHead: TButton;
    CheckBoxUrlEncodePostData: TCheckBox;
    Panel1: TPanel;
    Label9: TLabel;
    Label10: TLabel;
    Panel2: TPanel;
    PanelWebBrowser: TPanel;
    ButtonTrace: TButton;
    procedure ButtonGetClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ButtonOpenInExplorerClick(Sender: TObject);
    procedure ButtonPostClick(Sender: TObject);
    procedure ButtonHeadClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ButtonTraceClick(Sender: TObject);
    procedure OnCfgEditChange(Sender: TObject);
    procedure OnCfgEditKeyPress(Sender: TObject; var Key: Char);
  private
    FWinHttpClient: TalWinHttpClient;
    FDownloadSpeedStartTime: TdateTime;
    FDownloadSpeedBytesRead: Integer;
    FDownloadSpeedBytesNotRead: Integer;
    fMustInitWinHTTP: Boolean;
    procedure initWinHTTP;
  public
    procedure OnHttpClientStatusChange(sender: Tobject; InternetStatus: DWord; StatusInformation: Pointer; StatusInformationLength: DWord);
    procedure OnHttpDownloadProgress(sender: Tobject; Read: Integer; Total: Integer);
    procedure OnHttpUploadProgress(sender: Tobject; Sent: Integer; Total: Integer);
  end;

var
  Form1: TForm1;

implementation

Uses DateUtils,
     HttpApp,
     ALMultiPartFormDataParser,
     AlFcnFile,
     AlFcnMisc,
     AlFcnMime,
     AlHttpCommon;

{$R *.dfm}

{***************************}
procedure TForm1.initWinHTTP;
Begin
  if not fMustInitWinHTTP then Exit;
  fMustInitWinHTTP := False;
  With FWinHTTPClient do begin
    UserName := EditUserName.Text;
    Password := EditPassword.Text;

    if AlIsInteger(EditConnectTimeout.Text) then ConnectTimeout := strtoint(EditConnectTimeout.Text);
    if AlIsInteger(EditsendTimeout.Text) then SendTimeout := strtoint(EditSendTimeout.Text);
    if AlIsInteger(EditReceiveTimeout.Text) then ReceiveTimeout := strtoint(EditReceiveTimeout.Text);

    if RadioButtonProtocolVersion1_0.Checked then ProtocolVersion := HTTPpv_1_0
    else ProtocolVersion := HTTPpv_1_1;

    if AlIsInteger(EditBufferUploadSize.Text) then UploadBufferSize := strtoint(EditBufferUploadSize.Text);

    ProxyParams.ProxyServer := EdProxyServer.Text;
    ProxyParams.ProxyPort := strToInt(EdProxyPort.Text);
    ProxyParams.ProxyUserName := EdProxyUserName.Text;
    ProxyParams.ProxyPassword := EdProxyPassword.Text;
    ProxyParams.ProxyBypass := EdProxyBypass.Text;

    if RadioButtonAccessType_NO_PROXY.Checked then AccessType := wHttpAt_NO_PROXY
    else if RadioButtonAccessType_NAMED_PROXY.Checked then AccessType := wHttpAt_NAMED_PROXY
    else if RadioButtonAccessType_DEFAULT_PROXY.Checked then AccessType := wHttpAt_DEFAULT_PROXY;

    InternetOptions := [];
    If CheckBoxInternetOption_BYPASS_PROXY_CACHE.checked then InternetOptions := InternetOptions + [wHttpIo_BYPASS_PROXY_CACHE];
    If CheckBoxInternetOption_ESCAPE_DISABLE.checked then InternetOptions := InternetOptions + [wHttpIo_ESCAPE_DISABLE];
    If CheckBoxInternetOption_ESCAPE_DISABLE_QUERY.checked then InternetOptions := InternetOptions + [wHttpIo_ESCAPE_DISABLE_QUERY];
    If CheckBoxInternetOption_ESCAPE_PERCENT.checked then InternetOptions := InternetOptions + [wHttpIo_ESCAPE_PERCENT];
    If CheckBoxInternetOption_NULL_CODEPAGE.checked then InternetOptions := InternetOptions + [wHttpIo_NULL_CODEPAGE];
    If CheckBoxInternetOption_REFRESH.checked then InternetOptions := InternetOptions + [wHttpIo_REFRESH];
    If CheckBoxInternetOption_SECURE.checked then InternetOptions := InternetOptions + [wHttpIo_SECURE];
    If CheckBoxInternetOption_NO_COOKIES.checked then InternetOptions := InternetOptions + [wHttpIo_NO_COOKIES];
    If CheckBoxInternetOption_KEEP_CONNECTION.checked then InternetOptions := InternetOptions + [wHttpIo_KEEP_CONNECTION];
    If CheckBoxInternetOption_NO_AUTO_REDIRECT.checked then InternetOptions := InternetOptions + [wHttpIo_NO_AUTO_REDIRECT];

    RequestHeader.RawHeaderText := MemoRequestRawHeader.Text;
  end;
end;

{********************************************************}
procedure TForm1.OnHttpClientStatusChange(Sender: Tobject;
                                          InternetStatus: DWord;
                                          StatusInformation: Pointer;
                                          StatusInformationLength: DWord);
var StatusStr: String;
begin
  case InternetStatus of
    WINHTTP_CALLBACK_STATUS_CLOSING_CONNECTION: StatusStr := 'Closing the connection to the server';
    WINHTTP_CALLBACK_STATUS_CONNECTED_TO_SERVER: StatusStr := 'Successfully connected to the server';
    WINHTTP_CALLBACK_STATUS_CONNECTING_TO_SERVER: StatusStr := 'Connecting to the server';
    WINHTTP_CALLBACK_STATUS_CONNECTION_CLOSED: StatusStr := 'Successfully closed the connection to the server';
    WINHTTP_CALLBACK_STATUS_DATA_AVAILABLE: StatusStr := 'Data is available to be retrieved with WinHttpReadData';
    WINHTTP_CALLBACK_STATUS_HANDLE_CREATED: StatusStr := 'An HINTERNET handle has been created';
    WINHTTP_CALLBACK_STATUS_HANDLE_CLOSING: StatusStr := 'This handle value has been terminated';
    WINHTTP_CALLBACK_STATUS_HEADERS_AVAILABLE: StatusStr := 'The response header has been received and is available with WinHttpQueryHeaders';
    WINHTTP_CALLBACK_STATUS_INTERMEDIATE_RESPONSE: StatusStr := 'Received an intermediate (100 level) status code message from the server';
    WINHTTP_CALLBACK_STATUS_NAME_RESOLVED: StatusStr := 'Successfully found the IP address of the server';
    WINHTTP_CALLBACK_STATUS_READ_COMPLETE: StatusStr := 'Data was successfully read from the server';
    WINHTTP_CALLBACK_STATUS_RECEIVING_RESPONSE: StatusStr := 'Waiting for the server to respond to a request';
    WINHTTP_CALLBACK_STATUS_REDIRECT: StatusStr := 'An HTTP request is about to automatically redirect the request';
    WINHTTP_CALLBACK_STATUS_REQUEST_ERROR: StatusStr := 'An error occurred while sending an HTTP request';
    WINHTTP_CALLBACK_STATUS_REQUEST_SENT: StatusStr := 'Successfully sent the information request to the server';
    WINHTTP_CALLBACK_STATUS_RESOLVING_NAME: StatusStr := 'Looking up the IP address of a server name';
    WINHTTP_CALLBACK_STATUS_RESPONSE_RECEIVED: StatusStr := 'Successfully received a response from the server';
    WINHTTP_CALLBACK_STATUS_SECURE_FAILURE: StatusStr := 'One or more errors were encountered while retrieving a Secure Sockets Layer (SSL) certificate from the server';
    WINHTTP_CALLBACK_STATUS_SENDING_REQUEST: StatusStr := 'Sending the information request to the server';
    WINHTTP_CALLBACK_STATUS_SENDREQUEST_COMPLETE: StatusStr := 'The request completed successfully';
    WINHTTP_CALLBACK_STATUS_WRITE_COMPLETE: StatusStr := 'Data was successfully written to the server';
    else
      StatusStr := 'Unknown status: ' + inttostr(InternetStatus);
   end;

 MainStatusBar.Panels[0].Text := StatusStr;
 application.ProcessMessages;
end;

{*****************************************************************************}
procedure TForm1.OnHttpDownloadProgress(sender: Tobject; Read, Total: Integer);
Var In1, In2: integer;
begin
 if MainStatusBar.Panels[1].Text = '' then Begin
   FDownloadSpeedStartTime := now;
   FDownloadSpeedBytesNotRead := Read;
 End;
 FDownloadSpeedBytesRead := Read;

 MainStatusBar.Panels[1].Text := 'Read '+inttostr(read) + ' bytes of '+inttostr(total) + ' bytes';

 in1 := FDownloadSpeedBytesRead - FDownloadSpeedBytesNotRead;
 in2 := MillisecondsBetween(now, FDownloadSpeedStartTime);
 if (in1 > 0) and (in2 > 0) then MainStatusBar.Panels[2].Text := 'Download speed: '+ Inttostr(Round((in1 / 1000) / (in2 / 1000))) +'kbps';

 application.ProcessMessages;
end;

{***************************************************************************}
procedure TForm1.OnHttpUploadProgress(sender: Tobject; Sent, Total: Integer);
begin
 MainStatusBar.Panels[1].Text := 'Send '+inttostr(sent) + ' bytes of '+inttostr(total) + ' bytes';
 application.ProcessMessages;
end;

{***********************************************}
procedure TForm1.ButtonGetClick(Sender: TObject);
Var AHTTPResponseHeader: TALHTTPResponseHeader;
    AHTTPResponseStream: TStringStream;
begin
  MainStatusBar.Panels[0].Text := '';
  MainStatusBar.Panels[1].Text := '';
  MainStatusBar.Panels[2].Text := '';
  initWinHTTP;
  MemoContentBody.Lines.Clear;
  MemoResponseRawHeader.Lines.Clear;
  AHTTPResponseHeader := TALHTTPResponseHeader.Create;
  AHTTPResponseStream := TstringStream.Create('');
  try
    try
      FWinHttpClient.Get(editURL.Text, AHTTPResponseStream, AHTTPResponseHeader);
      MemoContentBody.Lines.Text := AHTTPResponseStream.DataString;
      MemoResponseRawHeader.Lines.Text := AHTTPResponseHeader.RawHeaderText;
    except
      MemoContentBody.Lines.Text := AHTTPResponseStream.DataString;
      MemoResponseRawHeader.Lines.Text := AHTTPResponseHeader.RawHeaderText;
      Raise;
    end;
  finally
    AHTTPResponseHeader.Free;
    AHTTPResponseStream.Free;
  end;
end;

{********************************************}
procedure TForm1.FormDestroy(Sender: TObject);
begin
  FWinHttpClient.Free;
end;

{************************************************}
procedure TForm1.ButtonHeadClick(Sender: TObject);
Var AHTTPResponseHeader: TALHTTPResponseHeader;
    AHTTPResponseStream: TStringStream;
begin
  MainStatusBar.Panels[0].Text := '';
  MainStatusBar.Panels[1].Text := '';
  MainStatusBar.Panels[2].Text := '';
  initWinHTTP;
  MemoContentBody.Lines.Clear;
  MemoResponseRawHeader.Lines.Clear;
  AHTTPResponseHeader := TALHTTPResponseHeader.Create;
  AHTTPResponseStream := TstringStream.Create('');
  try
    try
      FWinHttpClient.Head(editURL.Text, AHTTPResponseStream, AHTTPResponseHeader);
      MemoContentBody.Lines.Text := AHTTPResponseStream.DataString;
      MemoResponseRawHeader.Lines.Text := AHTTPResponseHeader.RawHeaderText;
    except
      MemoContentBody.Lines.Text := AHTTPResponseStream.DataString;
      MemoResponseRawHeader.Lines.Text := AHTTPResponseHeader.RawHeaderText;
      Raise;
    end;
  finally
    AHTTPResponseHeader.Free;
    AHTTPResponseStream.Free;
  end;
end;

{*************************************************}
procedure TForm1.ButtonTraceClick(Sender: TObject);
Var AHTTPResponseHeader: TALHTTPResponseHeader;
    AHTTPResponseStream: TStringStream;
begin
  MainStatusBar.Panels[0].Text := '';
  MainStatusBar.Panels[1].Text := '';
  MainStatusBar.Panels[2].Text := '';
  initWinHTTP;
  MemoContentBody.Lines.Clear;
  MemoResponseRawHeader.Lines.Clear;
  AHTTPResponseHeader := TALHTTPResponseHeader.Create;
  AHTTPResponseStream := TstringStream.Create('');
  try
    try
      FWinHttpClient.Trace(editURL.Text, AHTTPResponseStream, AHTTPResponseHeader);
      MemoContentBody.Lines.Text := AHTTPResponseStream.DataString;
      MemoResponseRawHeader.Lines.Text := AHTTPResponseHeader.RawHeaderText;
    except
      MemoContentBody.Lines.Text := AHTTPResponseStream.DataString;
      MemoResponseRawHeader.Lines.Text := AHTTPResponseHeader.RawHeaderText;
      Raise;
    end;
  finally
    AHTTPResponseHeader.Free;
    AHTTPResponseStream.Free;
  end;
end;

{**********************************************************}
procedure TForm1.ButtonOpenInExplorerClick(Sender: TObject);
Var AFullPath: String;
begin
  AFullPath := ALGetModulePath + '~tmp.html';
  MemoContentBody.Lines.SaveToFile(AFullPath);
  ShellExecute(0,'OPEN',Pchar(AFullPath),nil,nil,SW_SHOW)
end;

{************************************************}
procedure TForm1.ButtonPostClick(Sender: TObject);
Var AHTTPResponseHeader: TALHTTPResponseHeader;
    AHTTPResponseStream: TStringStream;
    ARawPostDatastream: TStringStream;
    AMultiPartFormDataFile: TALMultiPartFormDataContent;
    AMultiPartFormDataFiles: TALMultiPartFormDataContents;
    aTmpPostDataString: TStrings;
    i: Integer;
begin
  MainStatusBar.Panels[0].Text := '';
  MainStatusBar.Panels[1].Text := '';
  MainStatusBar.Panels[2].Text := '';
  initWinHTTP;
  MemoContentBody.Lines.Clear;
  MemoResponseRawHeader.Lines.Clear;
  AHTTPResponseHeader := TALHTTPResponseHeader.Create;
  AHTTPResponseStream := TstringStream.Create('');
  AMultiPartFormDataFiles := TALMultiPartFormDataContents.Create(true);
  aTmpPostDataString := TstringList.Create;
  try
    Try

      aTmpPostDataString.Assign(MemoPostDataStrings.lines);

      For I := 0 To MemoPostDataFiles.Lines.Count - 1 do
        if MemoPostDataFiles.Lines[i] <> '' then begin
          AMultiPartFormDataFile := TALMultiPartFormDataContent.Create;
          TmemoryStream(AMultiPartFormDataFile.DataStream).LoadFromFile(MemoPostDataFiles.Lines.ValueFromIndex[i]);
          AMultiPartFormDataFile.ContentDisposition := 'form-data; name="'+MemoPostDataFiles.Lines.Names[i]+'"; filename="'+MemoPostDataFiles.Lines.ValueFromIndex[i]+'"';
          AMultiPartFormDataFile.ContentType := ALGetDefaultMIMEContentTypeFromExt(ExtractFileExt(MemoPostDataFiles.Lines.ValueFromIndex[i]));
          AMultiPartFormDataFiles.Add(AMultiPartFormDataFile);
        end;

      if AMultiPartFormDataFiles.Count > 0 then
        FWinHttpClient.PostMultiPartFormData(editURL.Text,
                                             aTmpPostDataString,
                                             AMultiPartFormDataFiles,
                                             AHTTPResponseStream,
                                             AHTTPResponseHeader)

      else if aTmpPostDataString.Count > 0 then begin
        if CheckBoxUrlEncodePostData.Checked then FWinHttpClient.PostURLEncoded(editURL.Text,
                                                                                aTmpPostDataString,
                                                                                AHTTPResponseStream,
                                                                                AHTTPResponseHeader,
                                                                                CheckBoxHTTPEncodePostData.Checked)
        else begin

          if CheckBoxHTTPEncodePostData.Checked then ARawPostDatastream := TstringStream.create(HTTPEncode(aTmpPostDataString.text))
          else ARawPostDatastream := TstringStream.create(aTmpPostDataString.text);
          try

            FWinHttpClient.post(editURL.Text,
                                ARawPostDatastream,
                                AHTTPResponseStream,
                                AHTTPResponseHeader);

          finally
            ARawPostDatastream.free;
          end;

        end;
      end

      else FWinHttpClient.Post(
                               editURL.Text,
                               AHTTPResponseStream,
                               AHTTPResponseHeader
                              );

      MemoContentBody.Lines.Text := AHTTPResponseStream.DataString;
      MemoResponseRawHeader.Lines.Text := AHTTPResponseHeader.RawHeaderText;
    Except
      MemoContentBody.Lines.Text := AHTTPResponseStream.DataString;
      MemoResponseRawHeader.Lines.Text := AHTTPResponseHeader.RawHeaderText;
      Raise;
    end;
  finally
    AHTTPResponseHeader.Free;
    AHTTPResponseStream.Free;
    AMultiPartFormDataFiles.Free;
    aTmpPostDataString.free;
  end;
end;

{************************************************}
procedure TForm1.OnCfgEditChange(Sender: TObject);
begin
  fMustInitWinHTTP := True;
end;

{*****************************************************************}
procedure TForm1.OnCfgEditKeyPress(Sender: TObject; var Key: Char);
begin
  fMustInitWinHTTP := True;
end;


{-------------------}
var ie: IWebBrowser2;

{*******************************************}
procedure TForm1.FormCreate(Sender: TObject);
var Url, Flags, TargetFrameName, PostData, Headers: OleVariant;
begin
  fMustInitWinHTTP := True;
  FWinHttpClient := TaLWinHttpClient.Create(self);
  with FWinHttpClient do begin
    AccessType := wHttpAt_NO_PROXY;
    InternetOptions := [];
    OnStatusChange := OnHttpClientStatusChange;
    OnDownloadProgress := OnHttpDownloadProgress;
    OnUploadProgress := OnHttpUploadProgress;
    MemoRequestRawHeader.Text := RequestHeader.RawHeaderText;
  end;

  ie := CreateOleObject('InternetExplorer.Application') as IWebBrowser2;
  SetWindowLong(ie.hwnd, GWL_STYLE, GetWindowLong(ie.hwnd, GWL_STYLE) and not WS_BORDER and not WS_SIZEBOX and not WS_DLGFRAME );
  SetWindowPos(ie.hwnd, HWND_TOP, Left, Top, Width, Height, SWP_FRAMECHANGED);
  windows.setparent(ie.hwnd, PanelWebBrowser.handle);
  ie.Left := maxint; // don't understand why it's look impossible to setup the position
  ie.Top  := maxint; // don't understand why it's look impossible to setup the position
  ie.Width := 100;
  ie.Height := 300;
  ie.MenuBar := false;
  ie.AddressBar := false;
  ie.Resizable := false;
  ie.StatusBar := false;
  ie.ToolBar := 0;
  Url := 'http://www.arkadia.com/html/alcinoe_like.html';
  ie.Navigate2(Url,Flags,TargetFrameName,PostData,Headers);
  ie.Visible := true;
end;

{********************************************************************}
procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  try
    ie.quit;
  except
  end;
  sleep(500);
end;

{$IFDEF DEBUG}
initialization
  ReportMemoryleaksOnSHutdown := True;
{$ENDIF}

end.
