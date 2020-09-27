(**
 * Exports (a selection of) all available dumps.
 *)
unit ExportAll;

uses ExportTabularARMO,
     ExportTabularCLAS,
     ExportTabularCOBJ,
     ExportTabularENTM,
     ExportTabularFACT,
     ExportTabularFLOR,
     ExportTabularGLOB,
     ExportTabularGMST,
     ExportTabularIDs,
     ExportTabularLVLI,
     ExportTabularMISC,
     ExportTabularNPC_,
     ExportTabularOTFT,
     ExportTabularRACE,
     ExportTabularWEAP,
     ExportWikiBOOK,
     ExportWikiDIAL,
     ExportWikiNOTE,
     ExportWikiTERM;

var ExportAll_selection: String;



(**
 * Opens a prompt from which the user can select which dumps to include.
 *
 * @return the dumps selected by the user
 *)
function _selectDumps(): TStringList;
var form: TForm;
    clb: TCheckListBox;

    i: Integer;
begin
    result := TStringList.create();

    form := frmFileSelect;
    try
        form.caption := 'Select dump scripts';

        clb := TCheckListBox(form.findComponent('CheckListBox1'));
        clb.items.add('ARMO.csv');
        clb.items.add('CLAS.csv');
        clb.items.add('COBJ.csv');
        clb.items.add('ENTM.csv');
        clb.items.add('FACT.csv');
        clb.items.add('FLOR.csv');
        clb.items.add('GLOB.csv');
        clb.items.add('GMST.csv');
        clb.items.add('IDs.csv');
        clb.items.add('LVLI.csv');
        clb.items.add('MISC.csv');
        clb.items.add('NPC_.csv');
        clb.items.add('OTFT.csv');
        clb.items.add('RACE.csv');
        clb.items.add('WEAP.csv');
        clb.items.add('BOOK.wiki');
        clb.items.add('DIAL.wiki');
        clb.items.add('NOTE.wiki');
        clb.items.add('TERM.wiki');

        // Show form
        if form.showModal() <> mrOk then begin
            exit;
        end;

        // Process input
        for i := 0 to pred(clb.items.count) do begin
            if clb.checked[i] then begin
                result.add(clb.items[i]);
            end;
        end;
    finally
        form.free();
    end;
end;

(**
 * Returns `true` if the user has selected the given dump to be performed.
 *
 * @return `true` if the user has selected the given dump to be performed
 *)
function _hasSelectedDump(dump: String): Boolean;
begin
    result := pos(dump, ExportAll_selection) <> 0;
end;



function initialize(): Integer;
begin
    ExportAll_selection := _selectDumps().text;
    if ExportAll_selection = '' then begin
        result := 1;
        exit;
    end;

    if _hasSelectedDump('ARMO.csv') then begin
        ExportTabularARMO.initialize();
    end;
    if _hasSelectedDump('CLAS.csv') then begin
        ExportTabularCLAS.initialize();
    end;
    if _hasSelectedDump('COBJ.csv') then begin
        ExportTabularCOBJ.initialize();
    end;
    if _hasSelectedDump('ENTM.csv') then begin
        ExportTabularENTM.initialize();
    end;
    if _hasSelectedDump('FACT.csv') then begin
        ExportTabularFACT.initialize();
    end;
    if _hasSelectedDump('FLOR.csv') then begin
        ExportTabularFLOR.initialize();
    end;
    if _hasSelectedDump('GLOB.csv') then begin
        ExportTabularGLOB.initialize();
    end;
    if _hasSelectedDump('GMST.csv') then begin
        ExportTabularGMST.initialize();
    end;
    if _hasSelectedDump('IDs.csv') then begin
        ExportTabularIDs.initialize();
    end;
    if _hasSelectedDump('LVLI.csv') then begin
        ExportTabularLVLI.initialize();
    end;
    if _hasSelectedDump('MISC.csv') then begin
        ExportTabularMISC.initialize();
    end;
    if _hasSelectedDump('NPC_.csv') then begin
        ExportTabularNPC_.initialize();
    end;
    if _hasSelectedDump('OTFT.csv') then begin
        ExportTabularOTFT.initialize();
    end;
    if _hasSelectedDump('RACE.csv') then begin
        ExportTabularRACE.initialize();
    end;
    if _hasSelectedDump('WEAP.csv') then begin
        ExportTabularWEAP.initialize();
    end;
    if _hasSelectedDump('BOOK.wiki') then begin
        ExportWikiBOOK.initialize();
    end;
    if _hasSelectedDump('DIAL.wiki') then begin
        ExportWikiDIAL.initialize();
    end;
    if _hasSelectedDump('NOTE.wiki') then begin
        ExportWikiNOTE.initialize();
    end;
    if _hasSelectedDump('TERM.wiki') then begin
        ExportWikiTERM.initialize();
    end;
end;

function process(e: IInterface): Integer;
begin
    if _hasSelectedDump('ARMO.csv') and ExportTabularARMO.canProcess(e) then begin
        ExportTabularARMO.process(e);
    end;
    if _hasSelectedDump('CLAS.csv') and ExportTabularCLAS.canProcess(e) then begin
        ExportTabularCLAS.process(e);
    end;
    if _hasSelectedDump('COBJ.csv') and ExportTabularCOBJ.canProcess(e) then begin
        ExportTabularCOBJ.process(e);
    end;
    if _hasSelectedDump('ENTM.csv') and ExportTabularENTM.canProcess(e) then begin
        ExportTabularENTM.process(e);
    end;
    if _hasSelectedDump('FACT.csv') and ExportTabularFACT.canProcess(e) then begin
        ExportTabularFACT.process(e);
    end;
    if _hasSelectedDump('FLOR.csv') and ExportTabularFLOR.canProcess(e) then begin
        ExportTabularFLOR.process(e);
    end;
    if _hasSelectedDump('GLOB.csv') and ExportTabularGLOB.canProcess(e) then begin
        ExportTabularGLOB.process(e);
    end;
    if _hasSelectedDump('GMST.csv') and ExportTabularGMST.canProcess(e) then begin
        ExportTabularGMST.process(e);
    end;
    if _hasSelectedDump('IDs.csv') and ExportTabularIDs.canProcess(e) then begin
        ExportTabularIDs.process(e);
    end;
    if _hasSelectedDump('LVLI.csv') and ExportTabularLVLI.canProcess(e) then begin
        ExportTabularLVLI.process(e);
    end;
    if _hasSelectedDump('MISC.csv') and ExportTabularMISC.canProcess(e) then begin
        ExportTabularMISC.process(e);
    end;
    if _hasSelectedDump('NPC_.csv') and ExportTabularNPC_.canProcess(e) then begin
        ExportTabularNPC_.process(e);
    end;
    if _hasSelectedDump('OTFT.csv') and ExportTabularOTFT.canProcess(e) then begin
        ExportTabularOTFT.process(e);
    end;
    if _hasSelectedDump('RACE.csv') and ExportTabularRACE.canProcess(e) then begin
        ExportTabularRACE.process(e);
    end;
    if _hasSelectedDump('WEAP.csv') and ExportTabularWEAP.canProcess(e) then begin
        ExportTabularWEAP.process(e);
    end;
    if _hasSelectedDump('BOOK.wiki') and ExportWikiBOOK.canProcess(e) then begin
        ExportWikiBOOK.process(e);
    end;
    if _hasSelectedDump('DIAL.wiki') and ExportWikiDIAL.canProcess(e) then begin
        ExportWikiDIAL.process(e);
    end;
    if _hasSelectedDump('NOTE.wiki') and ExportWikiNOTE.canProcess(e) then begin
        ExportWikiNOTE.process(e);
    end;
    if _hasSelectedDump('TERM.wiki') and ExportWikiTERM.canProcess(e) then begin
        ExportWikiTERM.process(e);
    end;
end;

function finalize(): Integer;
var ExportAll_outputLines: TStringList;
begin
    if _hasSelectedDump('ARMO.csv') then begin
        ExportTabularARMO.finalize();
    end;
    if _hasSelectedDump('CLAS.csv') then begin
        ExportTabularCLAS.finalize();
    end;
    if _hasSelectedDump('COBJ.csv') then begin
        ExportTabularCOBJ.finalize();
    end;
    if _hasSelectedDump('ENTM.csv') then begin
        ExportTabularENTM.finalize();
    end;
    if _hasSelectedDump('FACT.csv') then begin
        ExportTabularFACT.finalize();
    end;
    if _hasSelectedDump('FLOR.csv') then begin
        ExportTabularFLOR.finalize();
    end;
    if _hasSelectedDump('GLOB.csv') then begin
        ExportTabularGLOB.finalize();
    end;
    if _hasSelectedDump('GMST.csv') then begin
        ExportTabularGMST.finalize();
    end;
    if _hasSelectedDump('IDs.csv') then begin
        ExportTabularIDs.finalize();
    end;
    if _hasSelectedDump('LVLI.csv') then begin
        ExportTabularLVLI.finalize();
    end;
    if _hasSelectedDump('MISC.csv') then begin
        ExportTabularMISC.finalize();
    end;
    if _hasSelectedDump('NPC_.csv') then begin
        ExportTabularNPC_.finalize();
    end;
    if _hasSelectedDump('OTFT.csv') then begin
        ExportTabularOTFT.finalize();
    end;
    if _hasSelectedDump('RACE.csv') then begin
        ExportTabularRACE.finalize();
    end;
    if _hasSelectedDump('WEAP.csv') then begin
        ExportTabularWEAP.finalize();
    end;
    if _hasSelectedDump('BOOK.wiki') then begin
        ExportWikiBOOK.finalize();
    end;
    if _hasSelectedDump('DIAL.wiki') then begin
        ExportWikiDIAL.finalize();
    end;
    if _hasSelectedDump('NOTE.wiki') then begin
        ExportWikiNOTE.finalize();
    end;
    if _hasSelectedDump('TERM.wiki') then begin
        ExportWikiTERM.finalize();
    end;

    createDir('dumps/');
    ExportAll_outputLines := TStringList.create();
    ExportAll_outputLines.add('All dumps completed. ' + errorStats(true));
    ExportAll_outputLines.saveToFile('dumps/_done.txt');
    ExportAll_outputLines.free();

    addMessage(errorStats(false));
    addMessage('Any errors and warnings have been written to `dumps/_done.txt`.');
end;


end.
