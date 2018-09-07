Attribute VB_Name = "TableExport_CSV"
Const g_sOneIndent As String = "    "


Sub WriteFileUTF8_CSV(sFilename As String, sh As Worksheet)

    Dim iColNum As Integer
    Dim iRowNum As Integer
    Dim sLine As String
    Dim sCell As String
    Dim sWarningMessage As String
    
    ' delete then create the file
    DeleteFile (sFilename)
    
    Dim BinaryStream
    Set BinaryStream = CreateObject("ADODB.Stream")
    BinaryStream.Charset = "UTF-8"
    BinaryStream.Type = 2
    BinaryStream.Open

    'write BOM first
    'arrBytes = ChrW(&HFEFF)
    'Put #iOutputFileNum, , arrBytes

    Dim iLastRowNum As Integer
    Dim iLastColNum As Integer
    iLastRowNum = sh.UsedRange.Row + sh.UsedRange.Rows.Count - 1
    iLastColNum = sh.UsedRange.Column + sh.UsedRange.Columns.Count - 1

    ' find the begin row num by finding the "TableName:"
    Dim iBeginRowNum As Integer
    iBeginRowNum = 0
    
    For iRowNum = 1 To iLastRowNum
    
        sCell = GetCellString(sh, iRowNum, 1, sWarningMessage)
        If sCell = "TableName:" Then
        
            iBeginRowNum = iRowNum
            
        End If
    
    Next

    ' find the row of column name by finding the "Column:"
    Dim iColumnRowNum As Integer
    iColumnRowNum = 0
    
    For iRowNum = 1 To iLastRowNum
    
        sCell = GetCellString(sh, iRowNum, 1, sWarningMessage)
        If sCell = "Column:" Then
        
            iColumnRowNum = iRowNum
            
        End If
    
    Next

    ' find the row of default value by finding the "Default:"
    Dim iDefaultRowNum As Integer
    iDefaultRowNum = 0
    
    For iRowNum = 1 To iLastRowNum
    
        sCell = GetCellString(sh, iRowNum, 1, sWarningMessage)
        If sCell = "Default:" Then
        
            iDefaultRowNum = iRowNum
            
        End If
    
    Next

    ' start exporting every columns of every rows...
    If iBeginRowNum > 0 And iColumnRowNum > 0 Then
              
        For iRowNum = iBeginRowNum To iLastRowNum
        
            If Not IsEmptyRow(sh, iRowNum, 1, iLastColNum) Then
        
                sLine = ""
                For iColNum = 1 To iLastColNum
                
                    sCell = GetCellString(sh, iColumnRowNum, iColNum, sWarningMessage)
                    
                    If sCell <> "" Then
                
                        sCell = GetCellString(sh, iRowNum, iColNum, sWarningMessage, iDefaultRowNum)
                        sLine = sLine & sCell
                    
                        If iColNum <> iLastColNum Then sLine = sLine & ","
                    
                    End If
                    
                Next
                
                BinaryStream.WriteText sLine, 1
                
            End If
        Next
    
        BinaryStream.SaveToFile sFilename, 2
        BinaryStream.Close
        
    Else
    
        sWarningMessage = sWarningMessage & " Find no tag of: 'TableName:' and 'Column:'"
    
    End If
    
    If Len(sWarningMessage) > 0 Then
        MsgBox ("In sheet: '" & sh.Name & "'," & Chr(10) & Chr(13) & "Replace " & Chr(34) & " with ' in cells:" & sWarningMessage)
    End If
    
End Sub


