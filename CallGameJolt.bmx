Rem
	Call GameJolt
	
	
	
	
	(c) Jeroen P. Broks, 2016, All rights reserved
	
		This program is free software: you can redistribute it and/or modify
		it under the terms of the GNU General Public License as published by
		the Free Software Foundation, either version 3 of the License, or
		(at your option) any later version.
		
		This program is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		GNU General Public License for more details.
		You should have received a copy of the GNU General Public License
		along with this program.  If not, see <http://www.gnu.org/licenses/>.
		
	Exceptions to the standard GNU license are available with Jeroen's written permission given prior 
	to the project the exceptions are needed for.
Version: 16.07.13
End Rem
Strict

Framework gamejolt.GJ
Import    brl.linkedlist
Import    tricky_units.Dirry
Import    tricky_units.Listfile

MKL_Version "Call GameJolt - CallGameJolt.bmx","16.07.13"
MKL_Lic     "Call GameJolt - CallGameJolt.bmx","GNU General Public License 3"


If (Len AppArgs)<2
	Print "Call GameJolt v"+MKL_NewestVersion()
	Print "A small tool to call the GameJolt API from a batch file."
	Print "(c) Jeroen P. Broks 2016"
	Print "Released under the terms of the GENERAL PUBLIC LICENSE V3"
	Print "Syntax: CallGameJolt GJID:<ID> GJKEY:<PrivateKey> USER:<username> TOKEN:<token> [...]"
	Print "Basically every paramater is a command, ending with : and its parameter"
	Print
	Print "GJID~tGameJolt Game ID"
	Print "GJKEY~tGameJolt Game Private Key"
	Print "USER~tLogin in as user"
	Print "TOKEN~tUser Token"
	Print "AWARD~tAward trophy"
	Print "CHAT~tVerboses all actions. This is only implemented for debugging purposes. Set 'YES' for allowing this, any other value will turn this off"
	Print "IMP~tImports a file. In that file you can put all settings on separate lines, with the same syntax as on the command line tool"
	Print "ASKUSER~tIf set to 'YES' the tool will ask the user his login data and store it in a temp file you can retrieve later"
	Print "RETUSER~tIf set to 'YES' the tool will retrieve the file created before with ASKUSER"
	Print "!WARNING! ASKUSER and RETUSER can cause conflict when multiple sessions are running!"
	Print
	Print "Unfortunately this app only supports trophies for the time being."
	Print "In succesful operation this should return 0 otherwise 1."
	Print
	End
EndIf

Const ufile$ = "$AppSupport$/GameJolt/CallAPI/CALLAPI.DAT"

Global lists:TList = New TList; ListAddLast lists,AppArgs
Global award:TList = New TList
Global C_Chat = False
?debug
C_Chat=True
?

Global C_GJID$,C_GJKEY$,C_USER$,C_TOKEN$

Function Chat(f$)
	If c_Chat Print "GJCALL: "+f
End Function

Function Error(e$)
	chat "ERROR: "+e
	exit_ 1
End Function

Function ex(go$[])
	Local l$
	Local LS$[]
	Local lf:TList,lfl$[]
	Local BT:TStream
	For l = EachIn go
		ls = l.split(":")
		If (Len ls)<>2
			Chat("Incorrect instruction: "+l+" -- Ignored")
		Else
			Select Trim(Upper(LS[0]))
				Case "REM"
					'Do nothing!
				Case "GJID"
					C_GJID$ = Trim(ls[1])
					Chat "GameJolt ID = "+C_GJID
				Case "GJKEY"
					C_GJKey = Trim(Lower(ls[1]))
					chat "GameJolt Private Key = "+C_GJKey
				Case "USER"
					If C_USER error "Duplicated user"
					C_USER = Trim(ls[1])
					chat "User = "+C_USER
				Case "TOKEN"
					If C_TOKEN chat "WARNING! Duplicate token definition!"
					C_TOKEN = Trim(Lower(ls[1]))
					chat "Token = "+C_TOKEN
				Case "CHAT"
					C_CHAT = Trim(Upper(ls[1]))="YES"
					chat "Sure. I'll chat with you!"
				Case "IMP","IMPORT"
					lf = Listfile(ls[1])
					If Not lf error "Cannot import: "+ls[1]
					chat "Importing: "+ls[1]
					lfl = New String[CountList(lf)]
					For Local i=0 Until (Len lfl) lfl[0]=String(lf.valueatindex(i)) Next
					ListAddLast lists,lfl
				Case "ASKUSER"
					If C_USER error "Duplicated user"
					C_USER  = Trim(Input("GameJolt UserName: "))
					C_TOKEN	= Trim(Input("GameJolt Token:    "))
					If Not CreateDir(Dirry(ExtractDir(ufile)),1) error "Could not create data folder"
					BT = WriteFile(Dirry(ufile))
					If Not bt error "Could not save to: "+Dirry(ufile)
					WriteLine bt,C_USER
					WriteLine bt,C_TOKEN
					CloseFile bt
				Case "RETUSER","RETRIEVEUSER"
					bt = ReadFile(Dirry(ufile))
					If bt
						C_USER=ReadLine(BT)
						C_TOKEN=ReadLine(BT)
						CloseFile bt
					Else
						error "Could not retrieve data from: "+Dirry(ufile)	
					EndIf	
				Case "AWARD"
					ListAddLast award,Trim(ls[1])		
				Default
					chat "I do not understand: "+Ls[0]
			End Select
		EndIf
	Next	
End Function

Repeat
	Local O:Object
	Local tL:TList = New TList
	For o=EachIn lists ListAddLast tl,O Next
	ClearList lists
	For Local sa$[] = EachIn tl 
		ex sa
	Next
Until ListIsEmpty(lists)


chat "Logging in on GameJolt"
GJ.Create C_GJKEY,C_GJID.toint()
chat "User: "+C_USER+"; Token: "+C_Token
Global user:gjUser = gjUser.Create(C_USER,C_TOKEN)	
If Not user error "I failed to login"
For Local a$=EachIn award
	chat "Awarding trophy "+a
	user.AddAchieved(a.toint())
Next
chat "All done, byebye!"
	

