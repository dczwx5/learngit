Attribute VB_Name = "TableExport_Json"
Const g_sOneIndent As String = "    "


Sub WriteJSonFileUTF8(sFilename As String, sh As Worksheet)

    Dim iColNum As Integer
    Dim iRowNum As Integer
    Dim sLine As String
    Dim sCell As String
    Dim sCaption As String
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

    Dim iColumnRowNum As Integer
    iColumnRowNum = 0
    Dim iRuntimeTypeRowNum As Integer
    iRuntimeTypeRowNum = 0
    Dim iRuntimeStructRowNum As Integer
    iRuntimeStructRowNum = 0
    Dim iDefaultRowNum As Integer
    iDefaultRowNum = 0
    Dim iDataBeginRowNum As Integer
    iDataBeginRowNum = 0
    Dim iDataEndRowNum As Integer
    iDataEndRowNum = 0

    BinaryStream.WriteText "[", 1
    
    For iRowNum = 1 To iLastRowNum
        
        If iDataBeginRowNum = 0 Then
        
            sCell = GetCellString(sh, iRowNum, 1, sWarningMessage)
            
            If sCell = "Column:" Then
                iColumnRowNum = iRowNum
            ElseIf sCell = "RuntimeType:" Then
                iRuntimeTypeRowNum = iRowNum
            ElseIf sCell = "RuntimeStruct:" Then
                iRuntimeStructRowNum = iRowNum
            ElseIf sCell = "Default:" Then
                iDefaultRowNum = iRowNum
            ElseIf sCell = "DataBegin:" Then
                iDataBeginRowNum = iRowNum
            End If
                
        ElseIf iDataEndRowNum = 0 Then
        
            sCell = GetCellString(sh, iRowNum, 1, sWarningMessage)
            
            If sCell = "DataEnd:" Then
                iDataEndRowNum = iRowNum
            End If
                
        End If
        
            
        If iDataBeginRowNum <> 0 And iRowNum > iDataBeginRowNum And iDataEndRowNum = 0 Then
                   
            If Not IsEmptyRow(sh, iRowNum, 2, iLastColNum) Then
            
                sLine = GetJSonString(sh, iColumnRowNum, iRuntimeStructRowNum, iRowNum, 1, 1, 2, iLastColNum, sWarningMessage, iDefaultRowNum)
                
                If iRowNum < iLastRowNum - 1 Then
                    sLine = sLine & ","
                End If
                
                BinaryStream.WriteText sLine, 1
                
            End If
                
        End If
        
    Next

    BinaryStream.WriteText "]", 1
    
    BinaryStream.SaveToFile sFilename, 2
    BinaryStream.Close

    If Len(sWarningMessage) > 0 Then
        MsgBox ("In sheet: '" & sh.Name & "'," & Chr(10) & Chr(13) & "Replace " & Chr(34) & " with ' in cells:" & sWarningMessage)
    End If
    
End Sub

Function GetJSonString(sh As Worksheet, iColumnRowNum As Integer, iRuntimeStructRowNum As Integer, iRowNum As Integer, iOrgLayer As Integer, iLayer As Integer, iFromCol As Integer, iToCol As Integer, ByRef sWarningMessage As String, iDefaultRowNum As Integer) As String

    Dim sCurrentIndent As String
    Dim iIndent As Integer
    For iIndent = 1 To iLayer
        sCurrentIndent = sCurrentIndent & g_sOneIndent
    Next
    
    Dim sOrgCaption As String
    Dim sOrgStruct As String
    Dim sCaption As String
    Dim sStruct As String
    
    Dim sLine As String
    
    sLine = sCurrentIndent & "{" & Chr(10)

    Dim iColNum As Integer
    For iColNum = iFromCol To iToCol
    
        sOrgCaption = GetCellString(sh, iColumnRowNum, iColNum, sWarningMessage)
        If sOrgCaption <> "" Then
        
            sCaption = StripFront(sOrgCaption, iLayer - iOrgLayer, ".")
             
            sOrgStruct = GetCellString(sh, iRuntimeStructRowNum, iColNum, sWarningMessage)
            sStruct = StripFront(sOrgStruct, iLayer - iOrgLayer, ".")
                    
            If iColNum <> iFromCol Then
                sLine = sLine & "," & Chr(10)
            End If
             
            
            If IsEmpty(sStruct) Or sStruct = "" Then
             
                Dim iColNumAdvance As Integer
                Dim sJSonValue As String
                sJSonValue = GetJSonValue(sh, iColumnRowNum, iRowNum, iColNum, iToCol, iColNumAdvance, sWarningMessage, iDefaultRowNum)
                 
                If iColNumAdvance > 0 Then sCaption = StripBack(sCaption, 1, "[")
                 
                sLine = sLine & sCurrentIndent & g_sOneIndent & Chr(34) & sCaption & Chr(34) & " : "
                sLine = sLine & sJSonValue
                 
                iColNum = iColNum + iColNumAdvance
                     
            Else
             
                ' try getting structure's end column index first
                Dim iToColNum As Integer
                Dim sToStruct As String
                Dim sToCaption As String
                For iToColNum = iColNum To iToCol
                    sToStruct = GetCellString(sh, iRuntimeStructRowNum, iToColNum, sWarningMessage)
                    If sToStruct <> sStruct Then
                    
                        sToCaption = GetCellString(sh, iColumnRowNum, iToColNum, sWarningMessage)
                        If sToCaption <> "" Then Exit For
                        
                    End If
                Next
                iToColNum = iToColNum - 1
                 
                sCaption = StripBack(sCaption, 1, ".")
                 
                sLine = sLine & sCurrentIndent & g_sOneIndent & Chr(34) & sCaption & Chr(34) & " : " & Chr(10)
                sLine = sLine & GetJSonString(sh, iColumnRowNum, iRuntimeStructRowNum, iRowNum, iLayer, iLayer + 1, iColNum, iToColNum, sWarningMessage, iDefaultRowNum)
                 
                iColNum = iToColNum
             
            End If
    
        End If
        
    Next
    
    GetJSonString = sLine & Chr(10) & sCurrentIndent & "}"
    
End Function

Function GetJSonValue(sh As Worksheet, iColumnRowNum As Integer, iRowNum As Integer, iFromCol As Integer, iToCol As Integer, ByRef iColNumAdvance As Integer, ByRef sWarningMessage As String, iDefaultRowNum As Integer) As String

    Dim sCell As String
    
    Dim sOrgCaption As String
    sOrgCaption = GetCellString(sh, iColumnRowNum, iFromCol, sWarningMessage)
    
    Dim iIdx As Integer
    iIdx = InStr(sOrgCaption, "[")
    
    If iIdx > 0 Then
    
        Dim sCaption As String
        
        Dim sResult As String
        sResult = "[ "
        
        Dim iColNum As Integer
        For iColNum = iFromCol To iToCol
        
            sCaption = GetCellString(sh, iColumnRowNum, iColNum, sWarningMessage)
            If sCaption <> "" Then
            
                If Left(sCaption, iIdx) <> Left(sOrgCaption, iIdx) Then Exit For
                
                If iColNum <> iFromCol Then sResult = sResult & ", "
                
                sCell = GetCellString(sh, iRowNum, iColNum, sWarningMessage, iDefaultRowNum, False)
                
                If IsNumeric(sCell) Then
                    sResult = sResult & sCell
                Else
                    sResult = sResult & Chr(34) & sCell & Chr(34)
                End If
                
            End If
            
        Next
        
        sResult = sResult & " ]"
        
        Dim iEndColNum As Integer
        iEndColNum = iColNum - 1
        
        iColNumAdvance = iEndColNum - iFromCol
        GetJSonValue = sResult
        
    Else
    
        iColNumAdvance = 0
        
        sCell = GetCellString(sh, iRowNum, iFromCol, sWarningMessage, iDefaultRowNum, False)
       
        If IsNumeric(sCell) Then
            GetJSonValue = sCell
        Else
            GetJSonValue = Chr(34) & sCell & Chr(34)
        End If
        
        
    End If

    
End Function


