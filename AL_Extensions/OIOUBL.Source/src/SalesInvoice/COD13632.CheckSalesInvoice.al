// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 13632 "OIOUBL-Check Sales Invoice"
{
    TableNo = "Sales Invoice Header";
    trigger OnRun();
    var
        OIOUBLManagement: Codeunit "OIOUBL-Management";
        DSMCheckPosting: Codeunit DSMCheckPosting;
    begin
        //DSMDK#2000 ->
        DealerServMgtSetup.GET();
        IF NOT DealerServMgtSetup."Use OIOXML" THEN
            EXIT;
        //DSMDK#2000 <-
        if NOT OIOUBLManagement.IsOIOUBLCheckRequired("OIOUBL-GLN", "Sell-to Customer No.") then
            exit;

        if NOT OIOUBLDocumentEncode.IsValidGLN("OIOUBL-GLN") then
            FIELDERROR("OIOUBL-GLN", InvalidGLNErr);

        ReadCompanyInfo();
        ReadGLSetup();

        CompanyInfo.OIOUBLVerifyAndSetInfo();

        TESTFIELD("External Document No.");
        TESTFIELD("Payment Terms Code");

        OIOUBLDocumentEncode.IsValidCountryCode("Sell-to Country/Region Code");
        TESTFIELD("Sell-to Contact");
        TESTFIELD("VAT Registration No.");
        DSMCheckPosting.CheckCVR("VAT Registration No."); //DSMDK#2001

        OIOUBLDocumentEncode.GetOIOUBLCountryRegionCode("Bill-to Country/Region Code");
        OIOUBLDocumentEncode.GetOIOUBLCountryRegionCode(CompanyInfo."Country/Region Code");

        "Currency Code" := OIOUBLDocumentEncode.GetOIOUBLCurrencyCode("Currency Code");
    end;

    var
        CompanyInfo: Record "Company Information";
        GLSetup: Record "General Ledger Setup";
        DealerServMgtSetup: record "Dealer Service Mgt. Setup";
        OIOUBLDocumentEncode: Codeunit "OIOUBL-Document Encode";
        InvalidGLNErr: Label 'does not contain a valid, 13-digit GLN', Comment = 'starts with some field name';
        CompanyInfoRead: Boolean;
        GLSetupRead: Boolean;

    procedure ReadCompanyInfo();
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
}