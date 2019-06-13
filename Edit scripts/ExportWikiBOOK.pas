unit ExportWikiBOOK;

uses ExportCore,
     ExportWikiCore;


var outputLines: TStringList;


function initialize: Integer;
begin
    outputLines := TStringList.create;
end;

function process(e: IInterface): Integer;
begin
    if signature(e) <> 'BOOK' then begin
        addMessage('Warning: ' + name(e) + ' is not a BOOK. Entry was ignored.');
        exit;
    end;

    outputLines.add('==[' + getFileName(getFile(e)) + '] ' + evBySignature(e, 'FULL') + '==');
    outputLines.add('Form ID:      ' + stringFormID(e));
    outputLines.add('Weight:       ' + evByPath(eBySignature(e, 'DATA'), 'Weight'));
    outputLines.add('Value:        ' + evByPath(eBySignature(e, 'DATA'), 'Value'));
    outputLines.add('Can be taken: ' + canBeTakenString(e));
    outputLines.add('Transcript:' + #10 + getBookContents(e));
    outputLines.add(#10);
end;

function finalize: Integer;
begin
    createDir('dumps/');
    outputLines.saveToFile('dumps/BOOK.wiki');
end;


function canBeTakenString(book: IInterface): String;
var flags: String;
    pickUpFlag: String;
begin
    flags := evByPath(eBySignature(book, 'DNAM'), 'Flags');
    if (length(flags) = 1) then begin
        result := 'no';
    end;

    pickUpFlag := copy(flags, 2, 1);
    if pickUpFlag = '0' then begin
        result := 'yes';
    end else begin
        result := 'no';
    end;
end;

function getBookContents(book: IInterface): String;
var desc: String;
begin
    desc := trim(escapeWiki(evBySignature(book, 'DESC')));

    if desc = '' then begin
        result := 'No transcript';
    end else begin
        result := '' +
            '{{Transcript|text=' + #10 +
            desc + #10 +
            '}}';
    end;
end;


end.
