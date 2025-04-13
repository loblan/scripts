' Convert a Word document to an Outlook message (".msg") file.

If WScript.Arguments.Count < 1 Then
    WScript.Echo "Usage: cscript word_to_msg.vbs <input-file>"
    WScript.Quit
End If

Set objWord = CreateObject("Word.Application")

Set objDoc = objWord.Documents.Open(WScript.Arguments(0))

Set objMail = objWord.CreateItem(0)

objDoc.Content.Copy
objMail.BodyFormat = 3 ' olFormatRichText
objMail.HTMLBody = "<html><body>" & objDoc.Content & "</body></html>"


strOutputFile = Left(WScript.Arguments(0), Len(WScript.Arguments(0)) - 5) & ".msg"

objMail.SaveAs strOutputFile, 3 ' olMsg

objDoc.Close
objMail.Close 1 ' olDiscard

objWord.Quit
Set objMail = Nothing
Set objDoc = Nothing
Set objWord = Nothing




