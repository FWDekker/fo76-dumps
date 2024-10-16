unit ExportWikiBOOK;

uses ExportCore,
     ExportWikiCore;


var ExportWikiBOOK_outputLines: TStringList;


function initialize(): Integer;
begin
    ExportWikiBOOK_outputLines := TStringList.create();
end;

function process(el: IInterface): Integer;
begin
    if signature(el) <> 'BOOK' then begin exit; end;

    _process(el);
end;

function _process(book: IInterface): Integer;
begin
    ExportWikiBOOK_outputLines.add(
        '==[' + getFileName(getFile(book)) + '] ' +
        getEditValue(elementBySignature(book, 'FULL')) +
        '=='
    );
    ExportWikiBOOK_outputLines.add('Form ID:      ' + stringFormID(book));
    ExportWikiBOOK_outputLines.add('Editor ID:    ' + getEditValue(elementBySignature(book, 'EDID')));
    ExportWikiBOOK_outputLines.add('Weight:       ' + getEditValue(elementByPath(book, 'DATA\Weight')));
    ExportWikiBOOK_outputLines.add('Value:        ' + getEditValue(elementByPath(book, 'DATA\Value')));
    ExportWikiBOOK_outputLines.add('Can be taken: ' + canBeTakenString(book));
    ExportWikiBOOK_outputLines.add('Transcript:' + #10 + getBookContents(book));
    ExportWikiBOOK_outputLines.add(#10);
end;

function finalize(): Integer;
begin
    createDir('dumps/');
    ExportWikiBOOK_outputLines.saveToFile('dumps/BOOK.wiki');
    ExportWikiBOOK_outputLines.free();
end;


function canBeTakenString(book: IInterface): String;
var flags: String;
    pickUpFlag: String;
begin
    flags := getEditValue(elementByPath(book, 'DNAM\Flags'));
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
    desc := trim(escapeWiki(getEditValue(elementBySignature(book, 'DESC'))));

    if desc = '' then begin
        result := 'No transcript';
    end else begin
        result := '{{Transcript|text=' + #10 + desc + #10 + '}}';
    end;
end;


end.
