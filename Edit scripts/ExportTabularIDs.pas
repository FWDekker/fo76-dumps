unit ExportTabularIDs;

uses ExportCore,
     ExportTabularCore,
     ExportJson,
     ExportLargeFile;


var ExportTabularIDs_buffer: TStringList;
var ExportTabularIDs_size: Integer;
var ExportTabularIDs_maxSize: Integer;


function initialize(): Integer;
begin
    ExportTabularIDs_buffer := TStringList.create();
    ExportTabularIDs_size := 0;
    ExportTabularIDs_maxSize := 10000000;

    createDir('dumps/');
    clearLargeFiles('dumps/IDs.csv');

    appendLargeFile('dumps/IDs.csv', ExportTabularIDs_buffer, ExportTabularIDs_size, ExportTabularIDs_maxSize,
        '"File", ' +       // Name of the originating ESM
        '"Signature", ' +  // Signature
        '"Form ID", ' +    // Form ID
        '"Editor ID", ' +  // Editor ID
        '"Name", ' +       // Full name
        '"Keywords"'       // Sorted JSON array of keywords. Each keyword is represented as `{EditorID} [KYWD:{FormID}]`
    );
end;

function process(el: IInterface): Integer;
begin
    _process(el);
end;

function _process(el: IInterface): Integer;
begin
    appendLargeFile(
        'dumps/IDs.csv',
        ExportTabularIDs_buffer,
        ExportTabularIDs_size,
        ExportTabularIDs_maxSize,
        escapeCsvString(getFileName(getFile(el))) + ', ' +
            escapeCsvString(signature(el)) + ', ' +
            escapeCsvString(lowerCase(intToHex(formID(el), 8))) + ', ' +
            escapeCsvString(getEditValue(elementBySignature(el, 'EDID'))) + ', ' +
            escapeCsvString(getEditValue(elementBySignature(el, 'FULL'))) + ', ' +
            escapeCsvString(getJsonChildArray(elementByPath(el, 'Keywords\KWDA')))
    );
end;

function finalize(): Integer;
begin
    flushLargeFile('dumps/IDs.csv', ExportTabularIDs_buffer, ExportTabularIDs_size);
    freeLargeFile(ExportTabularIDs_buffer);
end;


end.
