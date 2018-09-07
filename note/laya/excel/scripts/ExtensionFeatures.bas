Attribute VB_Name = "ExtensionFeatures"


Sub Replace_Localization()

    Dim intChoice As Integer
    Dim strPath As String
    
    'only allow the user to select one file
    Application.FileDialog(msoFileDialogOpen).AllowMultiSelect = False
    'make the file dialog visible to the user
    intChoice = Application.FileDialog(msoFileDialogOpen).Show
    'determine what choice the user made
    If intChoice <> 0 Then
        'get the file path selected by the user
        strPath = Application.FileDialog( _
            msoFileDialogOpen).SelectedItems(1)
    End If
    
    Set TableWorkbook = Workbooks.Open(strPath)
    
    ThisWorkbook.Activate
    
    Dim slabel As String
    For i = 1 To Selection.Cells.Columns.Count
        
        For j = 1 To Selection.Cells.Rows.Count
            
            slabel = Selection.Cells(j, i)
            
            
            Dim sh As Worksheet
            For Each sh In TableWorkbook.Worksheets
                If sh.Name <> "TXT_Export" Then
            
                Dim iLastRowNum As Integer
                iLastRowNum = sh.UsedRange.Row + sh.UsedRange.Rows.Count - 1
            
                For iRowNum = 1 To iLastRowNum
                    If sh.Cells(iRowNum, 1) = slabel Then
                        Selection.Cells(j, i) = sh.Cells(iRowNum, 2)
                        Exit For
                    End If
                Next
            
            
                End If
            Next
            
        Next
        
    Next

End Sub

Sub Comment_Localization()

    Dim intChoice As Integer
    Dim strPath As String
    
    'only allow the user to select one file
    Application.FileDialog(msoFileDialogOpen).AllowMultiSelect = False
    'make the file dialog visible to the user
    intChoice = Application.FileDialog(msoFileDialogOpen).Show
    'determine what choice the user made
    If intChoice <> 0 Then
        'get the file path selected by the user
        strPath = Application.FileDialog( _
            msoFileDialogOpen).SelectedItems(1)
    End If
    
    Set TableWorkbook = Workbooks.Open(strPath)
    
    ThisWorkbook.Activate
    
    Dim slabel As String
    For i = 1 To Selection.Cells.Columns.Count
        
        For j = 1 To Selection.Cells.Rows.Count
            
            slabel = Selection.Cells(j, i)
            
            
            Dim sh As Worksheet
            For Each sh In TableWorkbook.Worksheets
                If sh.Name <> "TXT_Export" Then
            
                Dim iLastRowNum As Integer
                iLastRowNum = sh.UsedRange.Row + sh.UsedRange.Rows.Count - 1
            
                For iRowNum = 1 To iLastRowNum
                    If sh.Cells(iRowNum, 1) = slabel Then
                        Selection.Cells(j, i).ClearComments
                        Dim sComment As String
                        sComment = sh.Cells(iRowNum, 2)
                        Selection.Cells(j, i).AddComment (sComment)
                        Exit For
                    End If
                Next
            
            
                End If
            Next
            
        Next
        
    Next

End Sub


