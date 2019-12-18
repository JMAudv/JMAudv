// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

tableextension 13639 "OIOUBL-Issued Reminder Line" extends "Issued Reminder Line"
{
    fields
    {
        field(13631; "OIOUBL-Account Code"; Text[30])
        {
            Caption = 'Account Code';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
    }

    procedure GetDescription(CurrencyCode: Code[10]): Text[1024];
    var
        AutoFormatManagement: Codeunit AutoFormatManagement;
    begin
        case Type of
            Type::" ":
                exit(Description + CrLf());
            Type::"G/L Account":
                exit(
                  STRSUBSTNO('%1: %2; ', FIELDCAPTION(Description), Description) +
                  STRSUBSTNO('%1: %2; ', FIELDCAPTION(Amount), FORMAT(Amount, 0, AutoFormatManagement.AutoFormatTranslate(1, CurrencyCode))) +
                  CrLf());
            Type::"Customer Ledger Entry":
                exit(
                  STRSUBSTNO('%1: %2; ', FIELDCAPTION("Document Date"), FORMAT("Document Date")) +
                  STRSUBSTNO('%1: %2; ', FIELDCAPTION("Document Type"), FORMAT("Document Type")) +
                  STRSUBSTNO('%1: %2; ', FIELDCAPTION("Document No."), FORMAT("Document No.")) +
                  STRSUBSTNO('%1: %2; ', FIELDCAPTION("Due Date"), FORMAT("Due Date")) +
                  STRSUBSTNO('%1: %2; ', FIELDCAPTION("Original Amount"),
                  FORMAT("Original Amount", 0, AutoFormatManagement.AutoFormatTranslate(1, CurrencyCode))) +
                  STRSUBSTNO('%1: %2; ', FIELDCAPTION("Remaining Amount"),
                  FORMAT("Remaining Amount", 0, AutoFormatManagement.AutoFormatTranslate(1, CurrencyCode))) +
                  CrLf());
        end;
    end;

    local procedure CrLf() CrLf: Text[2];
    begin
        CrLf[1] := 13;
        CrLf[2] := 10;
    end;
}