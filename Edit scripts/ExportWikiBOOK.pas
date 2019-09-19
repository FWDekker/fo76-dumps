unit ExportWikiBOOK;

uses ExportCore,
     ExportWikiCore;


var ExportWikiBOOK_outputLines: TStringList;


function initialize: Integer;
begin
    ExportWikiBOOK_outputLines := TStringList.create;
end;

function canProcess(e: IInterface): Boolean;
begin
    result := signature(e) = 'BOOK';
end;

function process(book: IInterface): Integer;
begin
    if not canProcess(book) then begin
        addMessage('Warning: ' + name(book) + ' is not a BOOK. Entry was ignored.');
        exit;
    end;

    ExportWikiBOOK_outputLines.add('==[' + getFileName(getFile(book)) + '] ' + evBySignature(book, 'FULL') + '==');
    ExportWikiBOOK_outputLines.add('Form ID:      ' + stringFormID(book));
    ExportWikiBOOK_outputLines.add('Editor ID:    ' + evBySignature(book, 'EDID'));
    ExportWikiBOOK_outputLines.add('Weight:       ' + evByPath(eBySignature(book, 'DATA'), 'Weight'));
    ExportWikiBOOK_outputLines.add('Value:        ' + evByPath(eBySignature(book, 'DATA'), 'Value'));
    ExportWikiBOOK_outputLines.add('Can be taken: ' + canBeTakenString(book));
    ExportWikiBOOK_outputLines.add('Transcript:' + #10 + getBookContents(book));
    ExportWikiBOOK_outputLines.add(#10);
end;

function finalize: Integer;
begin
    createDir('dumps/');
    ExportWikiBOOK_outputLines.saveToFile('dumps/BOOK.wiki');
end;


function canBeTakenString(book: IInterface): String;
var flags: String;
    pickUpFlag: String;
begin
    flags := evByPath(eBySignature(book, 'DNAM'), 'Flags');
    if length(flags) = 1 then begin
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
