let
    Source = Table.FromColumns(
      {Lines.FromBinary(File.Contents(#"File Location"), null, null, 1252)},
      {"txt"}
      ),
    #"Separations" = 
      Table.AddColumn(
        Source, 
        "Separations", 
        each if Text.StartsWith([txt], "Mode") 
          then  {0,
                 8,
                 Text.PositionOf([txt],"LastWriteTime")+14,
                 Text.PositionOf([txt],"Name")} 
          else null),
// PowerShell command:
//     cd "To the folder to start at"
//     Get-ChildItem "whatever*wildcard" -Force -Recurse  | Format-Table -AutoSize | Out-File A:\OutputHere.txt -width 300
    #"Folders" = 
      Table.AddColumn(
        #"Separations", 
        "Folder", 
        each if Text.StartsWith([txt], "    Directory:") 
          then Text.Middle([txt],15) 
          else null
        ),
    #"Fill Down" = Table.FillDown(#"Folders",{"Folder","Separations"}),
    #"Delete Rows" = 
      Table.SelectRows(
        #"Fill Down",
          each (not Text.StartsWith([txt], "Mode") 
            and not Text.StartsWith([txt], "----")
            and not Text.StartsWith([txt], "    Directory:") 
            and  [txt]<>null
            and  [txt]<>""
            )
      ),
    #"Insert delimiters" = 
      Table.AddColumn(
        #"Delete Rows", 
        "NewColumns", 
        each Text.Combine(
          Splitter.SplitTextByPositions([Separations])([txt]),
          "\"
        )
        ),
    #"Split Column by Delimiter" = 
      Table.SplitColumn(
        #"Insert delimiters", 
        "NewColumns", 
        Splitter.SplitTextByDelimiter("\", QuoteStyle.None),
        {"Mode", "LastWriteTime", "Length", "Name"}
        ),
    #"Added ext" = 
      Table.AddColumn(
        #"Split Column by Delimiter", 
        "ext", 
        each if Text.Contains([Name], ".") 
          then Text.AfterDelimiter([Name], ".", {0, RelativePosition.FromEnd}) 
          else ""
          ),
    #"Remove Columns" = Table.RemoveColumns(#"Added ext",{"txt", "Separations"}),
    #"Changed Type" = 
      Table.TransformColumnTypes(
          #"Remove Columns",
          { {"Mode", type text}, 
            {"LastWriteTime", type datetime}, 
            {"Length", Int64.Type}, 
            {"Name", type text}
          }
      )
in
    #"Remove Columns"
