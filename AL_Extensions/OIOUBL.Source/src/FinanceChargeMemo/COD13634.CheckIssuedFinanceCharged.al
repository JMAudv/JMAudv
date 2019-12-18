// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 13634 "OIOUBL-Check Issued Fin. Chrg"
{
    TableNo = "Issued Fin. Charge Memo Header";
    trigger OnRun();
    var
        OIOUBLManagement: Codeunit "OIOUBL-Management";
        DSMCheckPosting: Codeunit DSMCheckPosting;
    begin
        //DSMJMA#1 ->
        DealerServMgtSetup.GET();
        IF NOT DealerServMgtSetup."Use OIOXML" THEN
            EXIT;
        //DSMJMA#1 <-

        if NOT OIOUBLManagement.IsOIOUBLCheckRequired("OIOUBL-GLN", "Customer No.") then
            exit;

        if NOT OIOUBLDocumentEncode.IsValidGLN("OIOUBL-GLN") then
            FIELDERROR("OIOUBL-GLN", InvalidGLNErr);

        ReadCompanyInfo();
        ReadGLSetup();

        CompanyInfo.TESTFIELD("VAT Registration No.");
        CompanyInfo.TESTFIELD(Name);
        CompanyInfo.TESTFIELD(Address);
        CompanyInfo.TESTFIELD(City);
        CompanyInfo.TESTFIELD("Post Code");
        CompanyInfo.TESTFIELD("Country/Region Code");
        if CompanyInfo.IBAN = '' then
            CompanyInfo.TESTFIELD("Bank Account No.");
        CompanyInfo.TESTFIELD("Bank Branch No.");

        OIOUBLDocumentEncode.GetOIOUBLCountryRegionCode("Country/Region Code");
        OIOUBLDocumentEncode.GetOIOUBLCountryRegionCode(CompanyInfo."Country/Region Code");
        OIOUBLDocumentEncode.IsValidCountryCode("Country/Region Code");
        TESTFIELD(Name);
        TESTFIELD(Address);
        TESTFIELD(City);
        TESTFIELD("Post Code");
        TESTFIELD(Contact);
        DSMCheckPosting.CheckCVR("VAT Registration No."); //DSMDK#2003
        "Currency Code" := OIOUBLDocumentEncode.GetOIOUBLCurrencyCode("Currency Code");
        CheckForNegativeLines(Rec);      //DSMDK#2004

    end;

    var
        GLSetup: Record "General Ledger Setup";
        CompanyInfo: Record "Company Information";
        DealerServMgtSetup: record "Dealer Service Mgt. Setup";
        OIOUBLDocumentEncode: Codeunit "OIOUBL-Document Encode";
        CompanyInfoRead: Boolean;
        GLSetupRead: Boolean;
        InvalidGLNErr: Label 'does not contain a valid, 13-digit GLN', Comment = 'starts with some field name';
        Text6038950: Label 'Fin. Charge Memo Lines with Amount < 0 not allowed';

    local procedure ReadCompanyInfo();
    begin
        if NOT CompanyInfoRead then begin
            CompanyInfo.GET();
            CompanyInfoRead := TRUE;
        end;
    end;

    procedure ReadGLSetup();
    begin
        if NOT GLSetupRead then begin
            GLSetup.GET();
            GLSetupRead := TRUE;
        end;
    end;

    local procedure CheckForNegativeLines(IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header")
    var
        myInt: Integer;
        IssuedFinChargeMemoLine: Record "Issued Fin. Charge Memo Line";
    begin
        //DSMDK#2004 ->
        IssuedFinChargeMemoLine.SETRANGE("Finance Charge Memo No.", IssuedFinChargeMemoHeader."No.");
        IssuedFinChargeMemoLine.SETFILTER(Amount, '<%1', 0);
        IF NOT IssuedFinChargeMemoLine.ISEMPTY() THEN
            ERROR(Text6038950);
        //DSMDK#2004 <-

    end;
}