let
    Source = Table.FromColumns(
      {Lines.FromBinary(File.Contents("C:\Users\plc320\OneDrive - Hanover Insurance\Desktop\Clay Monthly\ClayDir.txt"), null, null, 1252)},
      {"txt"}
      ),
    #"Filtered Rows" = Table.SelectRows(#"Source",
        each (not Text.Contains([txt], "Mode                 LastWriteTime         Length Name ") 
          and not Text.Contains([txt], "----                 -------------         ------ ---- ") 
          and  [txt]<>null
          and  [txt]<>""
        )
    ),
    #"Added Conditional Column" = Table.AddColumn(#"Filtered Rows", "Folder", 
      each if Text.StartsWith([txt], "    Directory:") then Text.Middle([txt],15) else null),
    #"Filled Down" = Table.FillDown(#"Added Conditional Column",{"Folder"}),
    #"Filtered Rows1" = Table.SelectRows(#"Filled Down", each not Text.StartsWith([txt], "    Directory:")),
    #"Split Column by Position" = Table.SplitColumn(#"Filtered Rows1", "txt", 
      Splitter.SplitTextByPositions({0, 6,34,50}, false), {"txt.1", "txt.2", "txt.3", "txt.4"}),
    #"Changed Type" = Table.TransformColumnTypes(#"Split Column by Position",{{"txt.1", type text}, {"txt.2", type datetime}, {"txt.3", Int64.Type}, {"txt.4", type text}})
in
    #"Changed Type"
