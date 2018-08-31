Attribute VB_Name = "ScriptLoader"

Private Sub ImportModules()

    Dim sScriptPath As String
    sScriptPath = Application.ThisWorkbook.Path & "\scripts\"
    Dim sCustomScriptPath As String
    sCustomScriptPath = Application.ThisWorkbook.Path & "\custom_scripts\"
    
    Dim objFSO As Scripting.FileSystemObject
    Set objFSO = New Scripting.FileSystemObject
    
    Dim wkbTarget As Excel.Workbook
    Set wkbTarget = Application.Workbooks(ActiveWorkbook.Name)
    
    Dim cmpComponents As VBIDE.VBComponents
    Set cmpComponents = wkbTarget.VBProject.VBComponents
    
    Call DeleteModules
    
    Dim objFile As Scripting.File
    For Each objFile In objFSO.GetFolder(sScriptPath).Files
    
        If (objFSO.GetExtensionName(objFile.Name) = "cls") Or _
            (objFSO.GetExtensionName(objFile.Name) = "frm") Or _
            (objFSO.GetExtensionName(objFile.Name) = "bas") Then
    
            If objFile.Name <> "ScriptLoader.bas" Then
    
                cmpComponents.Import objFile.Path
    
            End If
            
        End If
        
    Next objFile
    
    If Len(Dir(sCustomScriptPath, vbDirectory)) <> 0 Then
    
        For Each objFile In objFSO.GetFolder(sCustomScriptPath).Files
        
            If (objFSO.GetExtensionName(objFile.Name) = "cls") Or _
                (objFSO.GetExtensionName(objFile.Name) = "frm") Or _
                (objFSO.GetExtensionName(objFile.Name) = "bas") Then
                
                cmpComponents.Import objFile.Path
                
            End If
            
        Next objFile
        
    End If
    
    OnScriptLoaded
    
End Sub

Private Sub ExportModules()

    Dim sScriptPath As String
    sScriptPath = Application.ThisWorkbook.Path & "\scripts_exported\"
    
    If Len(Dir(sScriptPath, vbDirectory)) = 0 Then
        MkDir sScriptPath
    End If
    
    Dim objFSO As Scripting.FileSystemObject
    Set objFSO = New Scripting.FileSystemObject
    
    Dim wkbTarget As Excel.Workbook
    Set wkbTarget = Application.Workbooks(ActiveWorkbook.Name)
    
    Dim cmpComponents As VBIDE.VBComponents
    Set cmpComponents = wkbTarget.VBProject.VBComponents
    
    Dim bExport As Boolean
    Dim sFilename As String
    
    Dim cmpComponent As VBIDE.VBComponent
    For Each cmpComponent In cmpComponents
        
        bExport = False
        sFilename = cmpComponent.Name

        Select Case cmpComponent.Type
            Case vbext_ct_StdModule
                sFilename = sFilename & ".bas"
                bExport = True
        End Select
        
        If bExport Then
            cmpComponent.Export sScriptPath & sFilename
        End If
   
    Next cmpComponent
        
End Sub

Private Sub DeleteModules()

        Dim VBProj As VBIDE.VBProject
        Dim VBComp As VBIDE.VBComponent
        
        Set VBProj = ActiveWorkbook.VBProject
        
        For Each VBComp In VBProj.VBComponents
        
            If VBComp.Type = vbext_ct_StdModule And VBComp.Name <> "ScriptLoader" Then
            
                VBProj.VBComponents.Remove VBComp
                
            End If
            
        Next VBComp
        
End Sub
