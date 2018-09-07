Attribute VB_Name = "TableExport"


Const g_sTAB_Export_Sheet_Name As String = "Table_Export"
Const g_iExport_Path_RowIdx As Integer = 1
Const g_iExport_Ext_RowIdx As Integer = 2
Const g_iExport_Single_Sheet_RowIdx As Integer = 6
Const g_iExport_Structure_Path_RowIdx As Integer = 10
Const g_iExport_Structure_Ext_RowIdx As Integer = 11
   

Sub CSV_Export()
    
    Dim sPath As String
    Dim sExt As String
    
    Sheets(g_sTAB_Export_Sheet_Name).Select
    
    Dim i As Integer
    For i = 2 To 10
        If Cells(g_iExport_Path_RowIdx, i) <> "" Then
        
            sPath = Cells(g_iExport_Path_RowIdx, i)
            sExt = Cells(g_iExport_Ext_RowIdx, i)
            Call CSV_Export_One(sPath, sExt, "")
            
        End If
    Next
    
End Sub

Sub JSon_Export()
    
    Dim sPath As String
    Dim sExt As String
    
    Sheets(g_sTAB_Export_Sheet_Name).Select
    
    Dim i As Integer
    For i = 2 To 10
        If Cells(g_iExport_Path_RowIdx, i) <> "" Then
        
            sPath = Cells(g_iExport_Path_RowIdx, i)
            sExt = Cells(g_iExport_Ext_RowIdx, i)
            Call JSon_Export_One(sPath, sExt, "")
            
        End If
    Next
    
End Sub

Sub CSV_Export_SingleSheet()
    
    Dim sPath As String
    Dim sExt As String
    
    Sheets(g_sTAB_Export_Sheet_Name).Select
    
    Dim i As Integer
    For i = 2 To 10
        If Cells(g_iExport_Path_RowIdx, i) <> "" Then
        
            sPath = Cells(g_iExport_Path_RowIdx, i)
            sExt = Cells(g_iExport_Ext_RowIdx, i)
            Call CSV_Export_One(sPath, sExt, Cells(g_iExport_Single_Sheet_RowIdx, 2))
            
        End If
    Next
    
End Sub

Sub JSon_Export_SingleSheet()
    
    Dim sPath As String
    Dim sExt As String
    
    Sheets(g_sTAB_Export_Sheet_Name).Select
    
    Dim i As Integer
    For i = 2 To 10
        If Cells(g_iExport_Path_RowIdx, i) <> "" Then
        
            sPath = Cells(g_iExport_Path_RowIdx, i)
            sExt = Cells(g_iExport_Ext_RowIdx, i)
            Call JSon_Export_One(sPath, sExt, Cells(g_iExport_Single_Sheet_RowIdx, 2))
            
        End If
    Next
    
End Sub

Sub Structure_Export()
    
    Dim sPath As String
    Dim sExt As String
    
    Sheets(g_sTAB_Export_Sheet_Name).Select
    
    Dim i As Integer
    For i = 2 To 10
        If Cells(g_iExport_Structure_Path_RowIdx, i) <> "" Then
        
            sPath = Cells(g_iExport_Structure_Path_RowIdx, i)
            sExt = Cells(g_iExport_Structure_Ext_RowIdx, i)
            Call Structure_Export_One(sPath, sExt)
            
        End If
    Next
    
End Sub


Sub CSV_Export_One(sPath As String, sExt As String, sSpecifySheetName As String)

    
    If Len(sPath) = 0 Then
        sPath = ActiveWorkbook.Path
    Else
        If Left(sPath, 1) = "." Then sPath = ActiveWorkbook.Path & "\" & sPath
    End If
    
    'Makes sure the path name ends with "\":
    If Len(sPath) > 0 Then
        If Not Right(sPath, 1) = "\" Then sPath = sPath & "\"
    End If
    
    If Len(Dir(sPath, vbDirectory)) = 0 Then
        MkDir sPath
    End If

    Dim sh As Worksheet
    
    For Each sh In Worksheets
        If sh.Name <> g_sTAB_Export_Sheet_Name And Left(sh.Name, 1) <> "_" Then
        
            If sSpecifySheetName = "" Or sSpecifySheetName = sh.Name Then
            
                Dim sFilename As String
                sFilename = sPath & GetTableName(sh)
                'Makes sure the filename ends with 'sExt'
                If Not Right(sFilename, 4) = sExt Then sFilename = sFilename & sExt
                                    
                Call WriteFileUTF8_CSV(sFilename, sh)
                'Call WriteFileUTF16(sFilename, sh)
                
                'Copies the sheet to a new workbook:
                'sh.Copy
                'The new workbook becomes Activeworkbook:
                'Application.DisplayAlerts = False
                'With ActiveWorkbook
                '    'Saves the new workbook to given folder / filename:
                '    .SaveAs Filename:=sFilename, FileFormat:=xlUnicodeText, CreateBackup:=False
                '
                '    'Closes the file
                '    .Close False
                'End With
                'Application.DisplayAlerts = True
                
            End If
            
        End If
    Next
    
End Sub

Sub JSon_Export_One(sPath As String, sExt As String, sSpecifySheetName As String)

    
    If Len(sPath) = 0 Then
        sPath = ActiveWorkbook.Path
    Else
        If Left(sPath, 1) = "." Then sPath = ActiveWorkbook.Path & "\" & sPath
    End If
    
    'Makes sure the path name ends with "\":
    If Len(sPath) > 0 Then
        If Not Right(sPath, 1) = "\" Then sPath = sPath & "\"
    End If
    
    If Len(Dir(sPath, vbDirectory)) = 0 Then
        MkDir sPath
    End If

    Dim sh As Worksheet
    For Each sh In Worksheets
        If sh.Name <> g_sTAB_Export_Sheet_Name And Left(sh.Name, 1) <> "_" Then
        
            If sSpecifySheetName = "" Or sSpecifySheetName = sh.Name Then
            
                Dim sFilename As String
                sFilename = sPath & GetTableName(sh)
                'Makes sure the filename ends with 'sExt'
                If Not Right(sFilename, 4) = sExt Then sFilename = sFilename & sExt
                        
                Call WriteJSonFileUTF8(sFilename, sh)
            
            End If
            
        End If
    Next
    
End Sub

Sub Structure_Export_One(sPath As String, sExt As String)

    
    If Len(sPath) = 0 Then
        sPath = ActiveWorkbook.Path
    Else
        If Left(sPath, 1) = "." Then sPath = ActiveWorkbook.Path & "\" & sPath
    End If
    
    'Makes sure the path name ends with "\":
    If Len(sPath) > 0 Then
        If Not Right(sPath, 1) = "\" Then sPath = sPath & "\"
    End If
    
    If Len(Dir(sPath, vbDirectory)) = 0 Then
        MkDir sPath
    End If

    Dim sh As Worksheet
    For Each sh In Worksheets
        If sh.Name <> g_sTAB_Export_Sheet_Name And Left(sh.Name, 1) <> "_" Then
        
            Dim sFilename As String
            sFilename = sPath & GetTableName(sh)
            
            'Makes sure the filename ends with 'sExt'
            If Not Right(sFilename, 4) = sExt Then sFilename = sFilename & sExt
        
            Call WriteStructureFileUTF8(sFilename, sExt, sh)
                        
        End If
    Next
    
End Sub

Sub OnScriptLoaded()

    
End Sub


