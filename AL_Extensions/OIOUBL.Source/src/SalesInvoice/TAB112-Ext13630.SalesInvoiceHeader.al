// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

tableextension 13630 "OIOUBL-Sales Invoice Header" extends "Sales Invoice Header"
{
    fields
    {
        field(13630; "OIOUBL-GLN"; Code[13])
        {
            Caption = 'GLN';
            DataClassification = CustomerContent;
        }
        field(13631; "OIOUBL-Account Code"; Text[30])
        {
            Caption = 'Account Code';
            DataClassification = CustomerContent;
        }
        field(13632; "OIOUBL-Profile Code"; Code[10])
        {
            Caption = 'Profile Code';
            DataClassification = CustomerContent;
            TableRelation = "OIOUBL-Profile";
        }
        field(13634; "OIOUBL-Electronic Invoice Created"; Boolean)
        {
            Caption = 'Electronic Invoice Created';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(13635; "OIOUBL-Sell-to Contact Phone No."; Text[30])
        {
            Caption = 'Sell-to Contact Phone No.';
            DataClassification = CustomerContent;
            ExtendedDatatype = PhoneNo;
        }
        field(13636; "OIOUBL-Sell-to Contact Fax No."; Text[30]) { DataClassification = CustomerContent;}
        field(13637; "OIOUBL-Sell-to Contact E-Mail"; Text[80]) { ExtendedDatatype = EMail; DataClassification = CustomerContent;}
        field(13638; "OIOUBL-Sell-to Contact Role"; Option) { OptionMembers = " ",,,"Purchase Responsible",,,Accountant,,,"Budget Responsible",,,Requisitioner; DataClassification = CustomerContent;}
    }
    keys
    {
    }

    procedure AccountCodeLineSpecified(): Boolean
    var
        SalesInvLine: Record "Sales invoice Line";
    begin
        SalesInvLine.RESET();
        SalesInvLine.SETRANGE("Document No.", "No.");
        SalesInvLine.SETFILTER(Type, '>%1', SalesInvLine.Type::" ");
        SalesInvLine.SETFILTER("OIOUBL-Account Code", '<>%1&<>%2', '', "OIOUBL-Account Code");
        exit(NOT SalesInvLine.ISEMPTY());
    end;

    procedure TaxLineSpecified(): Boolean;
    var
        SalesInvLine: Record "Sales Invoice Line";
    begin
        SalesInvLine.RESET();
        SalesInvLine.SETRANGE("Document No.", "No.");
        SalesInvLine.SETFILTER(Type, '>%1', SalesInvLine.Type::" ");
        SalesInvLine.FIND('-');
        SalesInvLine.SETFILTER("VAT %", '<>%1', SalesInvLine."VAT %");
        exit(NOT SalesInvLine.ISEMPTY());
    end;
}