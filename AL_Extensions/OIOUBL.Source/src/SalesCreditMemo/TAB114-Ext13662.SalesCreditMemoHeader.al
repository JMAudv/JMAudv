// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

tableextension 13632 "OIOUBL-Sales Cr.Memo Header" extends "Sales Cr.Memo Header"
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
        field(13634; "OIOUBL-Electronic Credit Memo Created"; Boolean)
        {
            Caption = 'Electronic Credit Memo Created';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(13635; "OIOUBL-Sell-to Contact Phone No."; Text[30])
        {
            Caption = 'Sell-to Contact Phone No.';
            DataClassification = CustomerContent;
            ExtendedDatatype = PhoneNo;
        }
        field(13636; "OIOUBL-Sell-to Contact Fax No."; Text[30])
        {
            Caption = 'Sell-to Contact Fax No.';
            DataClassification = CustomerContent;
        }
        field(13637; "OIOUBL-Sell-to Contact E-Mail"; Text[80])
        {
            Caption = 'Sell-to Contact E-Mail';
            DataClassification = CustomerContent;
            ExtendedDatatype = EMail;
        }
        field(13638; "OIOUBL-Sell-to Contact Role"; Option)
        {
            Caption = 'Sell-to Contact Role';
            DataClassification = CustomerContent;
            OptionMembers = " ",,,"Purchase Responsible",,,Accountant,,,"Budget Responsible",,,Requisitioner;
        }
    }
    keys
    {
    }

    procedure AccountCodeLineSpecified(): Boolean;
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        SalesCrMemoLine.RESET();
        SalesCrMemoLine.SETRANGE("Document No.", "No.");
        SalesCrMemoLine.SETFILTER(Type, '>%1', SalesCrMemoLine.Type::" ");
        SalesCrMemoLine.SETFILTER("OIOUBL-Account Code", '<>%1&<>%2', '', "OIOUBL-Account Code");
        exit(NOT SalesCrMemoLine.ISEMPTY());
    end;

    procedure TaxLineSpecified(): Boolean;
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        SalesCrMemoLine.RESET();
        SalesCrMemoLine.SETRANGE("Document No.", "No.");
        SalesCrMemoLine.SETFILTER(Type, '>%1', SalesCrMemoLine.Type::" ");
        SalesCrMemoLine.FIND('-');
        SalesCrMemoLine.SETFILTER("VAT %", '<>%1', SalesCrMemoLine."VAT %");
        exit(NOT SalesCrMemoLine.ISEMPTY());
    end;

}