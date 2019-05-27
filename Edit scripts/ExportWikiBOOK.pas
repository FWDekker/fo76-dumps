unit ExportWikiBOOK;

uses ExportCore,
     ExportWikiCore;


var outputLines: TStringList;


function Initialize: integer;
begin
    outputLines := TStringList.Create;
end;

function Process(e: IInterface): integer;
begin
    if (Signature(e) <> 'BOOK') then
    begin
        AddMessage('Warning: ' + Name(e) + ' is not a BOOK');
        Exit;
    end;

    outputLines.Add('==' + evBySignature(e, 'FULL') + '==');
    outputLines.Add('Form ID:      ' + StringFormID(e));
    outputLines.Add('Weight:       ' + evByPath(eBySignature(e, 'DATA'), 'Weight'));
    outputLines.Add('Value:        ' + evByPath(eBySignature(e, 'DATA'), 'Value'));
    outputLines.Add('Can be taken: ' + CanBeTakenString(e));
    outputLines.Add('Transcript:' + #10 + GetBookContents(e));
    outputLines.Add(#10);
end;

function Finalize: integer;
begin
    CreateDir('dumps/');
    outputLines.SaveToFile('dumps/BOOK.wiki');
end;


function CanBeTakenString(book: IInterface): string;
var flags: string;
    pickUpFlag: string;
begin
    flags := evByPath(eBySignature(book, 'DNAM'), 'Flags');
    if (Length(flags) = 1) then
    begin
        Result := 'no';
    end;

    pickUpFlag := copy(flags, 2, 1);
    if (pickUpFlag = '0') then
    begin
        Result := 'yes';
    end
    else
    begin
        Result := 'no';
    end;
end;

function GetBookContents(book: IInterface): string;
var desc: string;
begin
    desc := Trim(EscapeWiki(evBySignature(book, 'DESC')));

    if (desc = '') then
    begin
        Result := 'No transcript';
    end
    else
    begin
        Result := '' +
            '{{Transcript|text=' + #10 +
            desc + #10 +
            '}}';
    end;
end;


end.
