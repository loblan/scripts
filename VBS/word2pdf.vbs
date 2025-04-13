' Converts a Word document to a PDF file using built-in PDF printer

If WScript.Arguments.Count < 1 Then
    WScript.Echo "Usage: cscript word_to_pdf.vbs <input-file>"
    WScript.Quit
End If

strInputFile = WScript.Arguments(0)
strOutputFile = Left(strInputFile, Len(strInputFile) - 5) & ".pdf"

Set objWord = CreateObject("Word.Application")

Set objDoc = objWord.Documents.Open(strInputFile)

objWord.ActivePrinter = "Microsoft Print to PDF"

' Print the document to the PDF printer
' objDoc.PrintOut
objDoc.ExportAsFixedFormat OutputFileName:= strOutFile, ExportFormat:=wdExportFormatPDF, OpenAfterExport:=False, OptimizeFor:=wdExportOptimizeForPrint, Range:= wdExportAllDocument, From:=1, To:=1, Item:=wdExportDocumentContent

' Wait for the print job to complete
Do While objWord.BackgroundPrintingStatus > 0
    WScript.Sleep 100
Loop

WScript.Echo "before saving file"

objDoc.SaveAs strOutputFile, 17 ' wdFormatPDF

objDoc.Close

objWord.Quit
Set objDoc = Nothing
Set objWord = Nothing