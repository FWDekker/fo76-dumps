(**
 * Exports (a selection of) all available dumps.
 *)
unit ExportAll;

uses ExportTabularALCH,
     ExportTabularARMO,
     ExportTabularCLAS,
     ExportTabularCOBJ,
     ExportTabularENTM,
     ExportTabularFACT,
     ExportTabularFLOR,
     ExportTabularGLOB,
     ExportTabularGMST,
     ExportTabularIDs,
     ExportTabularLSCR,
     ExportTabularLVLI,
     ExportTabularMISC,
     ExportTabularNPC_,
     ExportTabularOMOD,
     ExportTabularOTFT,
     ExportTabularRACE,
     ExportTabularWEAP,
     ExportWikiBOOK,
     ExportWikiDIAL,
     ExportWikiNOTE,
     ExportWikiTERM;

var ExportAll_selected_IDs: Boolean;
var ExportAll_selected_ALCH: Boolean;
var ExportAll_selected_ARMO: Boolean;
var ExportAll_selected_CLAS: Boolean;
var ExportAll_selected_COBJ: Boolean;
var ExportAll_selected_ENTM: Boolean;
var ExportAll_selected_FACT: Boolean;
var ExportAll_selected_FLOR: Boolean;
var ExportAll_selected_GLOB: Boolean;
var ExportAll_selected_GMST: Boolean;
var ExportAll_selected_LSCR: Boolean;
var ExportAll_selected_LVLI: Boolean;
var ExportAll_selected_MISC: Boolean;
var ExportAll_selected_NPC_: Boolean;
var ExportAll_selected_OMOD: Boolean;
var ExportAll_selected_OTFT: Boolean;
var ExportAll_selected_RACE: Boolean;
var ExportAll_selected_WEAP: Boolean;
var ExportAll_selected_BOOK: Boolean;
var ExportAll_selected_DIAL: Boolean;
var ExportAll_selected_NOTE: Boolean;
var ExportAll_selected_TERM: Boolean;



(**
 * Opens a prompt from which the user can select which dumps to include, and writes the user's selection to global
 * variables.
 *)
function _selectDumps(): Integer;
var selection: TMemIniFile;

    form: TForm;
    clb: TCheckListBox;

    i: Integer;
begin
    selection := TMemIniFile.create('fo76dump_selected_types.ini');

    form := frmFileSelect;
    try
        form.caption := 'Select dump scripts';

        clb := TCheckListBox(form.findComponent('CheckListBox1'));
        clb.items.add('IDs.csv');

        clb.items.add('ALCH.csv');
        clb.items.add('ARMO.csv');
        clb.items.add('CLAS.csv');
        clb.items.add('COBJ.csv');
        clb.items.add('ENTM.csv');
        clb.items.add('FACT.csv');
        clb.items.add('FLOR.csv');
        clb.items.add('GLOB.csv');
        clb.items.add('GMST.csv');
        clb.items.add('LSCR.csv');
        clb.items.add('LVLI.csv');
        clb.items.add('MISC.csv');
        clb.items.add('NPC_.csv');
        clb.items.add('OMOD.csv');
        clb.items.add('OTFT.csv');
        clb.items.add('RACE.csv');
        clb.items.add('WEAP.csv');

        clb.items.add('BOOK.wiki');
        clb.items.add('DIAL.wiki');
        clb.items.add('NOTE.wiki');
        clb.items.add('TERM.wiki');

        // Show form
        if form.showModal() <> mrOk then begin exit; end;

        // Process selection
        for i := 0 to pred(clb.items.count) do begin
            selection.writeBool('', clb.items[i], clb.checked[i]);
        end;
    finally
        form.free();
    end;

    ExportAll_selected_IDs := selection.readBool('', 'IDs.csv', False);

    ExportAll_selected_ALCH := selection.readBool('', 'ALCH.csv', False);
    ExportAll_selected_ARMO := selection.readBool('', 'ARMO.csv', False);
    ExportAll_selected_CLAS := selection.readBool('', 'CLAS.csv', False);
    ExportAll_selected_COBJ := selection.readBool('', 'COBJ.csv', False);
    ExportAll_selected_ENTM := selection.readBool('', 'ENTM.csv', False);
    ExportAll_selected_FACT := selection.readBool('', 'FACT.csv', False);
    ExportAll_selected_FLOR := selection.readBool('', 'FLOR.csv', False);
    ExportAll_selected_GLOB := selection.readBool('', 'GLOB.csv', False);
    ExportAll_selected_GMST := selection.readBool('', 'GMST.csv', False);
    ExportAll_selected_LSCR := selection.readBool('', 'LSCR.csv', False);
    ExportAll_selected_LVLI := selection.readBool('', 'LVLI.csv', False);
    ExportAll_selected_MISC := selection.readBool('', 'MISC.csv', False);
    ExportAll_selected_NPC_ := selection.readBool('', 'NPC_.csv', False);
    ExportAll_selected_OMOD := selection.readBool('', 'OMOD.csv', False);
    ExportAll_selected_OTFT := selection.readBool('', 'OTFT.csv', False);
    ExportAll_selected_RACE := selection.readBool('', 'RACE.csv', False);
    ExportAll_selected_WEAP := selection.readBool('', 'WEAP.csv', False);

    ExportAll_selected_BOOK := selection.readBool('', 'BOOK.wiki', False);
    ExportAll_selected_DIAL := selection.readBool('', 'DIAL.wiki', False);
    ExportAll_selected_NOTE := selection.readBool('', 'NOTE.wiki', False);
    ExportAll_selected_TERM := selection.readBool('', 'TERM.wiki', False);

    selection.free();
end;



function initialize(): Integer;
begin
    _selectDumps();

    if ExportAll_selected_IDs then begin ExportTabularIDs.initialize(); end;

    if ExportAll_selected_ALCH then begin ExportTabularALCH.initialize(); end;
    if ExportAll_selected_ARMO then begin ExportTabularARMO.initialize(); end;
    if ExportAll_selected_CLAS then begin ExportTabularCLAS.initialize(); end;
    if ExportAll_selected_COBJ then begin ExportTabularCOBJ.initialize(); end;
    if ExportAll_selected_ENTM then begin ExportTabularENTM.initialize(); end;
    if ExportAll_selected_FACT then begin ExportTabularFACT.initialize(); end;
    if ExportAll_selected_FLOR then begin ExportTabularFLOR.initialize(); end;
    if ExportAll_selected_GLOB then begin ExportTabularGLOB.initialize(); end;
    if ExportAll_selected_GMST then begin ExportTabularGMST.initialize(); end;
    if ExportAll_selected_LSCR then begin ExportTabularLSCR.initialize(); end;
    if ExportAll_selected_LVLI then begin ExportTabularLVLI.initialize(); end;
    if ExportAll_selected_MISC then begin ExportTabularMISC.initialize(); end;
    if ExportAll_selected_NPC_ then begin ExportTabularNPC_.initialize(); end;
    if ExportAll_selected_OMOD then begin ExportTabularOMOD.initialize(); end;
    if ExportAll_selected_OTFT then begin ExportTabularOTFT.initialize(); end;
    if ExportAll_selected_RACE then begin ExportTabularRACE.initialize(); end;
    if ExportAll_selected_WEAP then begin ExportTabularWEAP.initialize(); end;

    if ExportAll_selected_BOOK then begin ExportWikiBOOK.initialize(); end;
    if ExportAll_selected_DIAL then begin ExportWikiDIAL.initialize(); end;
    if ExportAll_selected_NOTE then begin ExportWikiNOTE.initialize(); end;
    if ExportAll_selected_TERM then begin ExportWikiTERM.initialize(); end;
end;

function process(el: IInterface): Integer;
var sig: String;
begin
    // `and` does not short-cut, so use nested `if`s instead

    sig := signature(el);
    if sig = 'PGTR' then begin exit; end;

    if ExportAll_selected_IDs then begin ExportTabularIDs._process(el); end;

    if (sig = 'ALCH') then begin
        if ExportAll_selected_ALCH then begin ExportTabularALCH._process(el); end;
    end else begin if (sig = 'ARMO') then begin
        if ExportAll_selected_ARMO then begin ExportTabularARMO._process(el); end;
    end else begin if (sig = 'CLAS') then begin
        if ExportAll_selected_CLAS then begin ExportTabularCLAS._process(el); end;
    end else begin if (sig = 'COBJ') then begin
        if ExportAll_selected_COBJ then begin ExportTabularCOBJ._process(el); end;
    end else begin if (sig = 'ENTM') then begin
        if ExportAll_selected_ENTM then begin ExportTabularENTM._process(el); end;
    end else begin if (sig = 'FACT') then begin
        if ExportAll_selected_FACT then begin ExportTabularFACT._process(el); end;
    end else begin if (sig = 'FLOR') then begin
        if ExportAll_selected_FLOR then begin ExportTabularFLOR._process(el); end;
    end else begin if (sig = 'GLOB') then begin
        if ExportAll_selected_GLOB then begin ExportTabularGLOB._process(el); end;
    end else begin if (sig = 'GMST') then begin
        if ExportAll_selected_GMST then begin ExportTabularGMST._process(el); end;
    end else begin if (sig = 'LSCR') then begin
        if ExportAll_selected_LSCR then begin ExportTabularLSCR._process(el); end;
    end else begin if (sig = 'LVLI') then begin
        if ExportAll_selected_LVLI then begin ExportTabularLVLI._process(el); end;
    end else begin if (sig = 'MISC') then begin
        if ExportAll_selected_MISC then begin ExportTabularMISC._process(el); end;
    end else begin if (sig = 'NPC_') then begin
        if ExportAll_selected_NPC_ then begin ExportTabularNPC_._process(el); end;
    end else begin if (sig = 'OMOD') then begin
        if ExportAll_selected_OMOD then begin ExportTabularOMOD._process(el); end;
    end else begin if (sig = 'OTFT') then begin
        if ExportAll_selected_OTFT then begin ExportTabularOTFT._process(el); end;
    end else begin if (sig = 'RACE') then begin
        if ExportAll_selected_RACE then begin ExportTabularRACE._process(el); end;
    end else begin if (sig = 'WEAP') then begin
        if ExportAll_selected_WEAP then begin ExportTabularWEAP._process(el); end;
    end else begin if (sig = 'BOOK') then begin
        if ExportAll_selected_BOOK then begin ExportWikiBOOK._process(el); end;
    end else begin if (sig = 'QUST') then begin
        if ExportAll_selected_DIAL then begin ExportWikiDIAL._process(el); end;
    end else begin if (sig = 'NOTE') then begin
        if ExportAll_selected_NOTE then begin ExportWikiNOTE._process(el); end;
    end else begin if (sig = 'TERM') then begin
        if ExportAll_selected_TERM then begin ExportWikiTERM._process(el); end;
    end end end end end end end end end end end end end end end end end end end end end;
end;

function finalize(): Integer;
var ExportAll_outputLines: TStringList;
begin
    if ExportAll_selected_IDs then begin ExportTabularIDs.finalize(); end;

    if ExportAll_selected_ALCH then begin ExportTabularALCH.finalize(); end;
    if ExportAll_selected_ARMO then begin ExportTabularARMO.finalize(); end;
    if ExportAll_selected_CLAS then begin ExportTabularCLAS.finalize(); end;
    if ExportAll_selected_COBJ then begin ExportTabularCOBJ.finalize(); end;
    if ExportAll_selected_ENTM then begin ExportTabularENTM.finalize(); end;
    if ExportAll_selected_FACT then begin ExportTabularFACT.finalize(); end;
    if ExportAll_selected_FLOR then begin ExportTabularFLOR.finalize(); end;
    if ExportAll_selected_GLOB then begin ExportTabularGLOB.finalize(); end;
    if ExportAll_selected_GMST then begin ExportTabularGMST.finalize(); end;
    if ExportAll_selected_LSCR then begin ExportTabularLSCR.finalize(); end;
    if ExportAll_selected_LVLI then begin ExportTabularLVLI.finalize(); end;
    if ExportAll_selected_MISC then begin ExportTabularMISC.finalize(); end;
    if ExportAll_selected_NPC_ then begin ExportTabularNPC_.finalize(); end;
    if ExportAll_selected_OMOD then begin ExportTabularOMOD.finalize(); end;
    if ExportAll_selected_OTFT then begin ExportTabularOTFT.finalize(); end;
    if ExportAll_selected_RACE then begin ExportTabularRACE.finalize(); end;
    if ExportAll_selected_WEAP then begin ExportTabularWEAP.finalize(); end;

    if ExportAll_selected_BOOK then begin ExportWikiBOOK.finalize(); end;
    if ExportAll_selected_DIAL then begin ExportWikiDIAL.finalize(); end;
    if ExportAll_selected_NOTE then begin ExportWikiNOTE.finalize(); end;
    if ExportAll_selected_TERM then begin ExportWikiTERM.finalize(); end;

    createDir('dumps/');
    ExportAll_outputLines := TStringList.create();
    ExportAll_outputLines.add('All dumps completed. ' + errorStats(true));
    ExportAll_outputLines.saveToFile('dumps/_done.txt');
    ExportAll_outputLines.free();

    addMessage(errorStats(false));
    addMessage('Any errors and warnings have been written to `dumps/_done.txt`.');
end;


end.
