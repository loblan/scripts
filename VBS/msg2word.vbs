If WScript.Arguments.Count < 1 Then
    WScript.Echo "Usage: cscript msg_to_word.vbs <input-file>"
    WScript.Quit
End If

Set objWord = CreateObject("Word.Application")

' Create a new Word document
Set objDoc = objWord.Documents.Add()

' Open Outlook message file
Set objMsg = objWord.Session.OpenSharedItem(WScript.Arguments(0))

' Copy message content
objMsg.GetInspector.WordEditor.Range.FormattedText.Copy
objDoc.Range.Paste

strOutputFile = Left(WScript.Arguments(0), Len(WScript.Arguments(0)) - 4) & ".docx"
objDoc.SaveAs2 strOutputFile, 16

objDoc.Close

objWord.Quit
Set objMsg = Nothing
Set objDoc = Nothing
Set objWord = Nothing