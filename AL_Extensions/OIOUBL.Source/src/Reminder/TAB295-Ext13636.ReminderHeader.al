// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

tableextension 13636 "OIOUBL-Reminder Header" extends "Reminder Header"
{
    fields
    {
        field(13630; "OIOUBL-GLN"; Code[13])
        {
            Caption = 'GLN';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "OIOUBL-GLN" = '' then
                    exit;

                if not OIOUBLDocumentEncode.IsValidGLN("OIOUBL-GLN") then
                    FieldError("OIOUBL-GLN", InvalidGLNErr);
            end;
        }

        field(13631; "OIOUBL-Account Code"; Text[30])
        {
            Caption = 'Account Code';
            DataClassification = CustomerContent;

            trigger OnValidate();
            var
                ReminderLine: Record "Reminder Line";
            begin
                ReminderLine.RESET();
                ReminderLine.SETRANGE("Reminder No.", "No.");
                ReminderLine.SETFILTER(Type, '>%1', ReminderLine.Type::" ");
                ReminderLine.SETFILTER("OIOUBL-Account Code", '%1|%2', xRec."OIOUBL-Account Code", '');
                ReminderLine.MODIFYALL("OIOUBL-Account Code", "OIOUBL-Account Code");
            end;
        }
        field(13635; "OIOUBL-Contact Phone No."; Text[30])
        {
            Caption = 'Contact Phone No.';
            DataClassification = CustomerContent;
            ExtendedDataType = PhoneNo;
        }
        field(13636; "OIOUBL-Contact Fax No."; Text[30])
        {
            Caption = 'Contact Fax No.';
            DataClassification = CustomerContent;
        }
        field(13637; "OIOUBL-Contact E-Mail"; Text[80])
        {
            Caption = 'Contact E-Mail';
            DataClassification = CustomerContent;
            ExtendedDataType = EMail;
        }
        field(13638; "OIOUBL-Contact Role"; Option)
        {
            Caption = 'Contact Role';
            DataClassification = CustomerContent;
            OptionMembers = " ",,,"Purchase Responsible",,,"Accountant",,,"Budget Responsible",,,"Requisitioner";
        }

        modify("Customer No.")
        {
            trigger OnAfterValidate()
            var
                Customer: Record Customer;
            begin
                if not Customer.Get("Customer No.") then
                    exit;

                "OIOUBL-Contact Phone No." := Customer."Phone No.";
                "OIOUBL-Contact Fax No." := Customer."Fax No.";
                "OIOUBL-Contact E-Mail" := Customer."E-Mail";
                "OIOUBL-Contact Role" := "OIOUBL-Contact Role"::" ";
                "OIOUBL-Account Code" := Customer."OIOUBL-Account Code";
                "OIOUBL-GLN" := Customer.GLN;
            end;
        }
    }

    var
        OIOUBLDocumentEncode: Codeunit "OIOUBL-Document Encode";
        InvalidGLNErr: Label 'does not contain a valid, 13-digit GLN', Comment = 'starts with some field name';
}