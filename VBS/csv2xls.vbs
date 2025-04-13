If WScript.Arguments.Count < 2 Then
    WScript.Echo "Usage: cscript csv2xls.vbs <inputfile> <outputfile>"
    WScript.Quit
End If

strInputFile = WScript.Arguments.Item(0)
strOutputFile = WScript.Arguments.Item(1)

Set objExcel = CreateObject("Excel.Application")

objExcel.DisplayAlerts = False
objExcel.ScreenUpdating = False

Set objWorkbook = objExcel.Workbooks.Add()
Set objWorksheet = objWorkbook.Worksheets(1)

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objInputFile = objFSO.OpenTextFile(strInputFile, 1)
intRow = 1
Do Until objInputFile.AtEndOfStream
    strLine = objInputFile.ReadLine()
    arrValues = Split(strLine, ",")
    For intCol = 0 To UBound(arrValues)
        objWorksheet.Cells(intRow, intCol + 1).Value = arrValues(intCol)
    Next
    intRow = intRow + 1
Loop
objInputFile.Close()

objWorksheet.Columns.AutoFit() 

objWorkbook.SaveAs strOutputFile, 51
objWorkbook.Close()

Set objWorksheet = Nothing
Set objWorkbook = Nothing
Set objExcel = Nothing
Set objFSO = Nothing