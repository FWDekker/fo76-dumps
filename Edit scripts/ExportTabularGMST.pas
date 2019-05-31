unit ExportTabularGMST;

uses ExportCore,
     ExportTabularCore;


var outputLines: TStringList;


function initialize: Integer;
begin
    outputLines := TStringList.create;
    outputLines.add('"Form ID", "Editor ID", "Type", "Value"');
end;

function process(e: IInterface): Integer;
begin
    outputLines.add(
        escapeCsvString(stringFormID(e)) + ', ' +
        escapeCsvString(evBySignature(e, 'EDID')) + ', ' +
        escapeCsvString(letterToType(copy(evBySignature(e, 'EDID'), 1, 1))) + ', ' +
        escapeCsvString(gev(lastElement(eBySignature(e, 'DATA'))))
    );
end;

function finalize: Integer;
begin
    createDir('dumps/');
    outputLines.saveToFile('dumps/GMST.csv');
end;


function letterToType(letter: String): String;
begin
    if letter = 'b' then begin
        result := 'boolean';
    end else if letter = 'f' then begin
        result := 'float';
    end else if letter = 'i' then begin
        result := 'integer';
    end else if letter = 's' then begin
        result := 'string';
    end else if letter = 'u' then begin
        result := 'unsigned integer';
    end else begin
        addMessage('<! DUMP ERROR. UNKNOWN TYPE `' + letter + '` !>');
        result := '<! DUMP ERROR. UNKNOWN TYPE `' + letter + '` !>';
    end;
end;


end.
