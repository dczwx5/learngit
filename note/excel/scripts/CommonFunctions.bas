Attribute VB_Name = "CommonFunctions"
Const g_sOneIndent As String = "    "

Function GetTableName(sh As Worksheet) As String

    Dim sDomain As String
    Dim sName As String
    Dim sCell As String
    
    sCell = GetTableDomainAndName(sh, sDomain, sName)
    GetTableName = sName
    
End Function


Function GetTableDomainAndName(sh As Worksheet, ByRef sDomain As String, ByRef sName As String) As String

    Dim iLastRowNum As Integer
    Dim iLastColNum As Integer
    iLastRowNum = sh.UsedRange.Row + sh.UsedRange.Rows.Count - 1
    iLastColNum = sh.UsedRange.Column + sh.UsedRange.Columns.Count - 1
   
    Dim sCell As String
    Dim sWarningMessage As String
    
    Dim iRowNum As Integer
    For iRowNum = 1 To iLastRowNum
        
        sCell = GetCellString(sh, iRowNum, 1, sWarningMessage)
        
        If sCell = "TableName:" Then
        
            sCell = GetCellString(sh, iRowNum, 2, sWarningMessage)
            
            Call SeparateDomainAndName(sCell, sDomain, sName)
            
            If sName = "" Then
            
                sName = sh.Name
                sCell = sCell & sName
                                
            End If
                    
            Exit For
            
        End If
                    
    Next
    
    If sCell = "" Then
    
        GetTableDomainAndName = sh.Name
        
    Else
        
        GetTableDomainAndName = sCell
        
    End If
    
End Function

Function CountArraySize(sh As Worksheet, iColumnRowNum As Integer, sName As String) As String

    Dim iLastColNum As Integer
    iLastColNum = sh.UsedRange.Column + sh.UsedRange.Columns.Count - 1
   
    Dim sCell As String
    Dim sWarningMessage As String
    
    Dim sTheArrayName As String
    sTheArrayName = GetArrayName(sName)
    
    Dim sArrayName As String
    Dim iArrayIdx As Integer
    
    Dim iMax As Integer
    iMax = 0
    
    Dim iColNum As Integer
    For iColNum = 2 To iLastColNum
        
        sCell = GetCellString(sh, iColumnRowNum, iColNum, sWarningMessage)
        
        sArrayName = GetArrayName(sCell)
        iArrayIdx = GetArrayIndex(sCell)
        If sArrayName = sTheArrayName And iMax < iArrayIdx Then
        
            iMax = iArrayIdx
            
        End If
                    
    Next
    
    CountArraySize = iMax + 1
    
End Function

Function GetArrayName(sFullname As String) As String

    Dim iPos As Integer
    iPos = InStr(sFullname, "[")
    
    If iPos <= 0 Then
        
        GetArrayName = ""
    
    Else
    
        GetArrayName = Left(sFullname, iPos - 1)
        
    End If

End Function

Function GetArrayIndex(sFullname As String) As Integer

    Dim iPos As Integer
    iPos = InStr(sFullname, "[")
    
    Dim iPos2 As Integer
    iPos2 = InStr(sFullname, "]")
    
    If iPos <= 0 Or iPos2 <= 0 Then
        
        GetArrayIndex = -1
    
    Else
    
        GetArrayIndex = Int(Mid(sFullname, iPos + 1, iPos2 - iPos - 1))
        
    End If

End Function

Function SeparateDomainAndName(sTableFullname As String, ByRef sDomain As String, ByRef sName As String)

    Dim iPos As Integer
    iPos = InStrRev(sTableFullname, ".")
    
    If iPos <= 0 Then
        
        sDomain = ""
        sName = sTableFullname
    
    Else
    
        sDomain = Left(sTableFullname, iPos - 1)
        sName = Right(sTableFullname, Len(sTableFullname) - iPos)
        
    End If


End Function

Function StripFront(s As String, iStripLayer As Integer, sSymbol As String) As String

    Dim sArray() As String
    Dim iLayer As Integer
    
    sArray = Split(s, sSymbol)
    s = ""
    For iLayer = iStripLayer To UBound(sArray)
    
        If iLayer <> iStripLayer Then
            s = s & sSymbol
        End If
    
        s = s & sArray(iLayer)
    
    Next

    StripFront = s
    
End Function

Function StripBack(s As String, iStripLayer As Integer, sSymbol As String) As String

    Dim sArray() As String
    Dim iLayer As Integer
    
    sArray = Split(s, sSymbol)
    s = ""
    For iLayer = 0 To UBound(sArray) - iStripLayer
    
        If iLayer <> 0 Then
            s = s & sSymbol
        End If
    
        s = s & sArray(iLayer)
    
    Next
    
    StripBack = s

End Function

Function ConvertToLetter(iCol As Integer) As String

   Dim iAlpha As Integer
   Dim iRemainder As Integer
   
   iAlpha = Int(iCol / 27)
   iRemainder = iCol - (iAlpha * 26)
   
   If iAlpha > 0 Then
   
      ConvertToLetter = Chr(iAlpha + 64)
      
   End If
   
   If iRemainder > 0 Then
   
      ConvertToLetter = ConvertToLetter & Chr(iRemainder + 64)
      
   End If
   
End Function

Sub DeleteFile(ByVal FileToDelete As String)

   If FileExists(FileToDelete) Then 'See above
   
      SetAttr FileToDelete, vbNormal
      Kill FileToDelete
      
   End If
   
End Sub

Function FileExists(ByVal FileToTest As String) As Boolean

   FileExists = (Dir(FileToTest) <> "")
   
End Function

Function GetCellString(sh As Worksheet, iRowNum As Integer, iColNum As Integer, ByRef sReplaceQuoteWarningMsg As String, Optional iDefaultRowNum As Integer = 0, Optional bAutoQuotes As Boolean = True) As String

    sCell = sh.Cells(iRowNum, iColNum)
    If sCell = "" And iDefaultRowNum > 0 And iColNum > 1 Then
    
        sCell = sh.Cells(iDefaultRowNum, iColNum)
    
    End If
    
    'check quote char - ", replace it with ' if found it
    Dim iQuotePos As Integer
    iQuotePos = InStr(sCell, Chr(34))
    
    If iQuotePos <> 0 Then
    
        sCell = Replace(sCell, Chr(34), "'")
        sReplaceQuoteWarningMsg = sReplaceQuoteWarningMsg & " (" & ConvertToLetter(iColNum) & iRowNum & ")"
        
    Else
    
        If Left(sCell, 1) = "." And IsNumeric(sCell) Then

            sCell = "0" & sCell
            
        End If
    
    End If
     
    If bAutoQuotes Then
    
        Dim bWrap As Boolean
        bWrap = False
        
        ' check comma, if users use it, quote the entire string
        Dim iPos As Integer
        iPos = InStr(sCell, ",")
        If iPos <> 0 Then bWrap = True
        
        ' check space, if users use it, quote the entire string
        iPos = InStr(sCell, " ")
        If iPos <> 0 Then bWrap = True
        
        ' check tab, if users use it, quote the entire string
        iPos = InStr(sCell, Chr(9))
        If iPos <> 0 Then bWrap = True
        
        ' check enter, if users use it, quote the entire string
        iPos = InStr(sCell, Chr(10))
        If iPos <> 0 Then bWrap = True
        iPos = InStr(sCell, Chr(13))
        If iPos <> 0 Then bWrap = True
        
        If bWrap Then sCell = Chr(34) & sCell & Chr(34)
    
    End If
    
    GetCellString = sCell
    
End Function

Function IsEmptyRow(sh As Worksheet, iRowNum As Integer, iFromCol As Integer, iToCol As Integer) As Boolean

    Dim bEmpty As Boolean
    bEmpty = True
    
    Dim sCell As String
    Dim iColNum As Integer
    For iColNum = iFromCol To iToCol
    
        sCell = sh.Cells(iRowNum, iColNum)
        If sCell <> "" Then
        
            bEmpty = False
            Exit For
            
        End If
    Next
    
    IsEmptyRow = bEmpty

End Function

Function GetIndentString(iIndentCounts As Integer) As String

    Dim sIndent As String
    sIndent = ""
    
    Dim iCount As Integer
    For iCount = 1 To iIndentCounts

        sIndent = sIndent & g_sOneIndent
        
    Next
    
    GetIndentString = sIndent
    
End Function

Sub CreatePath(ByVal strPath As String)
    Dim i As Long, strPaths() As String
     
    strPaths = Split(strPath, "\")
    strPath = ""
    For i = 0 To UBound(strPaths)
        strPath = strPath + IIf(i > 0, "\", "") + strPaths(i)
        If Dir(strPath, vbDirectory) = vbNullString Then MkDir strPath
    Next
End Sub



