// PowerShell command:
//     cd "To the folder to start at"
//     Get-ChildItem "whatever*wildcard" -Force -Recurse  | Format-Table -AutoSize | Out-File A:\OutputHere.txt -width 300
let
    Source = Table.FromColumns(
      {Lines.FromBinary(File.Contents("C:\Users\plc320\OneDrive - Hanover Insurance\Desktop\Clay Monthly\ClayDir2.txt"), null, null, 1252)},
      {"txt"}
      ),
    #"Filtered Rows" = Table.SelectRows(Source,
        each (
          not Text.StartsWith([txt], "Mode ")
          and not Text.StartsWith([txt], "---- ") 
          and  [txt]<>null
          and  [txt]<>""
        )
    ),
    //Folder Column derived from Directory lines
    #"Add Folder Column" = Table.AddColumn(#"Filtered Rows", "Folder", 
      each if Text.StartsWith([txt], "    Directory:") then Text.Middle([txt],15) else null),
    #"Fill Down" = Table.FillDown(#"Add Folder Column",{"Folder"}),
    #"Filtered Rows1" = Table.SelectRows(#"Fill Down", each not Text.StartsWith([txt], "    Directory:")),
    #"Split Column by Position" = Table.SplitColumn(#"Filtered Rows1", "txt", 
      Splitter.SplitTextByPositions({0, 6,34,50}, false), {"Mode", "LastWriteTime", "Length", "Name"}),
    #"Changed Type" = Table.TransformColumnTypes(#"Split Column by Position",{
        {"Mode", type text}, 
        {"LastWriteTime", type datetime}, 
        {"Length", Int64.Type}, 
        {"Name", type text}
        })
in
    #"Changed Type"
