VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} frmSenha 
   Caption         =   "UserForm1"
   ClientHeight    =   2685
   ClientLeft      =   120
   ClientTop       =   465
   ClientWidth     =   4560
   OleObjectBlob   =   "frmSenha.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "frmSenha"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
' No código do UserForm (frmSenha)
Public senhaCorreta As Boolean

Private Sub btnOK_Click()
    If Me.txtSenha.Text = "nexttsol" Then  ' Substitua pela sua senha
        senhaCorreta = True
    Else
        MsgBox "Senha incorreta!", vbExclamation
        senhaCorreta = False
    End If
    Me.Hide
End Sub

Private Sub UserForm_Initialize()
    Me.txtSenha.PasswordChar = "*"
    Me.Caption = "Acesso Restrito"
    senhaCorreta = False
End Sub
