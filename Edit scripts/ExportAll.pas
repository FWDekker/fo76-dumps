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

var ExportAll_selection: TStrings;



(**
 * Opens a prompt from which the user can select which dumps to include.
 *
 * @return the dumps selected by the user
 *)
function _selectDumps(): TStrings;
var form: TForm;
    clb: TCheckListBox;

    i: Integer;
begin
    result := THashedStringList.create();

    form := frmFileSelect;
    try
        form.caption := 'Select dump scripts';

        clb := TCheckListBox(form.findComponent('CheckListBox1'));
        clb.items.add('ALCH.csv');
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
        clb.items.add('OMOD.csv');
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



function initialize(): Integer;
begin
    ExportAll_selection := _selectDumps();
    if ExportAll_selection.count = 0 then begin
        result := 1;
        exit;
    end;

    if ExportAll_selection.indexOf('ALCH.csv') >= 0 then begin
        ExportTabularALCH.initialize();
    end;
    if ExportAll_selection.indexOf('ARMO.csv') >= 0 then begin
        ExportTabularARMO.initialize();
    end;
    if ExportAll_selection.indexOf('CLAS.csv') >= 0 then begin
        ExportTabularCLAS.initialize();
    end;
    if ExportAll_selection.indexOf('COBJ.csv') >= 0 then begin
        ExportTabularCOBJ.initialize();
    end;
    if ExportAll_selection.indexOf('ENTM.csv') >= 0 then begin
        ExportTabularENTM.initialize();
    end;
    if ExportAll_selection.indexOf('FACT.csv') >= 0 then begin
        ExportTabularFACT.initialize();
    end;
    if ExportAll_selection.indexOf('FLOR.csv') >= 0 then begin
        ExportTabularFLOR.initialize();
    end;
    if ExportAll_selection.indexOf('GLOB.csv') >= 0 then begin
        ExportTabularGLOB.initialize();
    end;
    if ExportAll_selection.indexOf('GMST.csv') >= 0 then begin
        ExportTabularGMST.initialize();
    end;
    if ExportAll_selection.indexOf('IDs.csv') >= 0 then begin
        ExportTabularIDs.initialize();
    end;
    if ExportAll_selection.indexOf('LVLI.csv') >= 0 then begin
        ExportTabularLVLI.initialize();
    end;
    if ExportAll_selection.indexOf('MISC.csv') >= 0 then begin
        ExportTabularMISC.initialize();
    end;
    if ExportAll_selection.indexOf('NPC_.csv') >= 0 then begin
        ExportTabularNPC_.initialize();
    end;
    if ExportAll_selection.indexOf('OMOD.csv') >= 0 then begin
        ExportTabularOMOD.initialize();
    end;
    if ExportAll_selection.indexOf('OTFT.csv') >= 0 then begin
        ExportTabularOTFT.initialize();
    end;
    if ExportAll_selection.indexOf('RACE.csv') >= 0 then begin
        ExportTabularRACE.initialize();
    end;
    if ExportAll_selection.indexOf('WEAP.csv') >= 0 then begin
        ExportTabularWEAP.initialize();
    end;
    if ExportAll_selection.indexOf('BOOK.wiki') >= 0 then begin
        ExportWikiBOOK.initialize();
    end;
    if ExportAll_selection.indexOf('DIAL.wiki') >= 0 then begin
        ExportWikiDIAL.initialize();
    end;
    if ExportAll_selection.indexOf('NOTE.wiki') >= 0 then begin
        ExportWikiNOTE.initialize();
    end;
    if ExportAll_selection.indexOf('TERM.wiki') >= 0 then begin
        ExportWikiTERM.initialize();
    end;
end;

function process(el: IInterface): Integer;
begin
    if ExportAll_selection.indexOf('ALCH.csv') >= 0 then begin if ExportTabularALCH.canProcess(el) then begin
        ExportTabularALCH.process(el);
    end end;
    if ExportAll_selection.indexOf('ARMO.csv') >= 0 then begin if ExportTabularARMO.canProcess(el) then begin
        ExportTabularARMO.process(el);
    end end;
    if ExportAll_selection.indexOf('CLAS.csv') >= 0 then begin if ExportTabularCLAS.canProcess(el) then begin
        ExportTabularCLAS.process(el);
    end end;
    if ExportAll_selection.indexOf('COBJ.csv') >= 0 then begin if ExportTabularCOBJ.canProcess(el) then begin
        ExportTabularCOBJ.process(el);
    end end;
    if ExportAll_selection.indexOf('ENTM.csv') >= 0 then begin if ExportTabularENTM.canProcess(el) then begin
        ExportTabularENTM.process(el);
    end end;
    if ExportAll_selection.indexOf('FACT.csv') >= 0 then begin if ExportTabularFACT.canProcess(el) then begin
        ExportTabularFACT.process(el);
    end end;
    if ExportAll_selection.indexOf('FLOR.csv') >= 0 then begin if ExportTabularFLOR.canProcess(el) then begin
        ExportTabularFLOR.process(el);
    end end;
    if ExportAll_selection.indexOf('GLOB.csv') >= 0 then begin if ExportTabularGLOB.canProcess(el) then begin
        ExportTabularGLOB.process(el);
    end end;
    if ExportAll_selection.indexOf('GMST.csv') >= 0 then begin if ExportTabularGMST.canProcess(el) then begin
        ExportTabularGMST.process(el);
    end end;
    if ExportAll_selection.indexOf('IDs.csv') >= 0 then begin if ExportTabularIDs.canProcess(el) then begin
        ExportTabularIDs.process(el);
    end end;
    if ExportAll_selection.indexOf('LVLI.csv') >= 0 then begin if ExportTabularLVLI.canProcess(el) then begin
        ExportTabularLVLI.process(el);
    end end;
    if ExportAll_selection.indexOf('MISC.csv') >= 0 then begin if ExportTabularMISC.canProcess(el) then begin
        ExportTabularMISC.process(el);
    end end;
    if ExportAll_selection.indexOf('NPC_.csv') >= 0 then begin if ExportTabularNPC_.canProcess(el) then begin
        ExportTabularNPC_.process(el);
    end end;
    if ExportAll_selection.indexOf('OMOD.csv') >= 0 then begin if ExportTabularOMOD.canProcess(el) then begin
        ExportTabularOMOD.process(el);
    end end;
    if ExportAll_selection.indexOf('OTFT.csv') >= 0 then begin if ExportTabularOTFT.canProcess(el) then begin
        ExportTabularOTFT.process(el);
    end end;
    if ExportAll_selection.indexOf('RACE.csv') >= 0 then begin if ExportTabularRACE.canProcess(el) then begin
        ExportTabularRACE.process(el);
    end end;
    if ExportAll_selection.indexOf('WEAP.csv') >= 0 then begin if ExportTabularWEAP.canProcess(el) then begin
        ExportTabularWEAP.process(el);
    end end;
    if ExportAll_selection.indexOf('BOOK.wiki') >= 0 then begin if ExportWikiBOOK.canProcess(el) then begin
        ExportWikiBOOK.process(el);
    end end;
    if ExportAll_selection.indexOf('DIAL.wiki') >= 0 then begin if ExportWikiDIAL.canProcess(el) then begin
        ExportWikiDIAL.process(el);
    end end;
    if ExportAll_selection.indexOf('NOTE.wiki') >= 0 then begin if ExportWikiNOTE.canProcess(el) then begin
        ExportWikiNOTE.process(el);
    end end;
    if ExportAll_selection.indexOf('TERM.wiki') >= 0 then begin if ExportWikiTERM.canProcess(el) then begin
        ExportWikiTERM.process(el);
    end end;
end;

function finalize(): Integer;
var ExportAll_outputLines: TStringList;
begin
    if ExportAll_selection.indexOf('ALCH.csv') >= 0 then begin
        ExportTabularALCH.finalize();
    end;
    if ExportAll_selection.indexOf('ARMO.csv') >= 0 then begin
        ExportTabularARMO.finalize();
    end;
    if ExportAll_selection.indexOf('CLAS.csv') >= 0 then begin
        ExportTabularCLAS.finalize();
    end;
    if ExportAll_selection.indexOf('COBJ.csv') >= 0 then begin
        ExportTabularCOBJ.finalize();
    end;
    if ExportAll_selection.indexOf('ENTM.csv') >= 0 then begin
        ExportTabularENTM.finalize();
    end;
    if ExportAll_selection.indexOf('FACT.csv') >= 0 then begin
        ExportTabularFACT.finalize();
    end;
    if ExportAll_selection.indexOf('FLOR.csv') >= 0 then begin
        ExportTabularFLOR.finalize();
    end;
    if ExportAll_selection.indexOf('GLOB.csv') >= 0 then begin
        ExportTabularGLOB.finalize();
    end;
    if ExportAll_selection.indexOf('GMST.csv') >= 0 then begin
        ExportTabularGMST.finalize();
    end;
    if ExportAll_selection.indexOf('IDs.csv') >= 0 then begin
        ExportTabularIDs.finalize();
    end;
    if ExportAll_selection.indexOf('LVLI.csv') >= 0 then begin
        ExportTabularLVLI.finalize();
    end;
    if ExportAll_selection.indexOf('MISC.csv') >= 0 then begin
        ExportTabularMISC.finalize();
    end;
    if ExportAll_selection.indexOf('NPC_.csv') >= 0 then begin
        ExportTabularNPC_.finalize();
    end;
    if ExportAll_selection.indexOf('OMOD.csv') >= 0 then begin
        ExportTabularOMOD.finalize();
    end;
    if ExportAll_selection.indexOf('OTFT.csv') >= 0 then begin
        ExportTabularOTFT.finalize();
    end;
    if ExportAll_selection.indexOf('RACE.csv') >= 0 then begin
        ExportTabularRACE.finalize();
    end;
    if ExportAll_selection.indexOf('WEAP.csv') >= 0 then begin
        ExportTabularWEAP.finalize();
    end;
    if ExportAll_selection.indexOf('BOOK.wiki') >= 0 then begin
        ExportWikiBOOK.finalize();
    end;
    if ExportAll_selection.indexOf('DIAL.wiki') >= 0 then begin
        ExportWikiDIAL.finalize();
    end;
    if ExportAll_selection.indexOf('NOTE.wiki') >= 0 then begin
        ExportWikiNOTE.finalize();
    end;
    if ExportAll_selection.indexOf('TERM.wiki') >= 0 then begin
        ExportWikiTERM.finalize();
    end;

    ExportAll_selection.free();

    createDir('dumps/');
    ExportAll_outputLines := TStringList.create();
    ExportAll_outputLines.add('All dumps completed. ' + errorStats(true));
    ExportAll_outputLines.saveToFile('dumps/_done.txt');
    ExportAll_outputLines.free();

    addMessage(errorStats(false));
    addMessage('Any errors and warnings have been written to `dumps/_done.txt`.');
end;


end.
