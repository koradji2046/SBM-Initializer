Dim Fso,Temp,File_Temp,File_Open,File_List,Folder_Name
Dim fileName,sourceString,newString
Set Fso = CreateObject("ScriptIng.FileSystemObject")
Set tch=wscript.createobject("wscript.shell")
fileName=tch.ExpandEnvironmentStrings("%fileName%")
sourceString=tch.ExpandEnvironmentStrings("%sourceString%")
newString=tch.ExpandEnvironmentStrings("%newString%")
sourceString=Replace(sourceString,"@","=")
newString=Replace(newString,"@","=")
Set File_Open = Fso.OpenTextFile(fileName,1)
File_Temp = File_Open.readall
File_Open.Close
File_Temp = Replace(File_Temp,sourceString,newString)
Set File_Open = Fso.OpenTextFile(fileName,2)
File_Open.WriteLIne File_Temp
File_Open.Close