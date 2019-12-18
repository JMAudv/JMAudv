// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 13629 "OIOUBL-Check Sales Header"
{
    TableNo = "Sales Header";
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
        CheckOIOUBLProfile(Rec);
        ReadCompanyInfo();
        ReadGLSetup();
        CompanyInfo.OIOUBLVerifyAndSetInfo();
        DSMCheckPosting.CheckCVR("VAT Registration No."); //DSMDK#2002

        if NOT OIOUBLDocumentEncode.IsValidGLN("OIOUBL-GLN") then
            FIELDERROR("OIOUBL-GLN", InvalidGLNErr);

        if "External Document No." = '' then
            ERROR(EmptyExtDocNoErr, "Document Type", "No.");
        TESTFIELD("Payment Terms Code");

        if "Document Type" in ["Document Type"::Invoice, "Document Type"::Order] then
            TESTFIELD("Order Date");
        TESTFIELD("Bill-to Name");
        TESTFIELD("Bill-to Address");
        TESTFIELD("Bill-to City");
        TESTFIELD("Bill-to Post Code");

        TESTFIELD("Sell-to Contact");
        TESTFIELD("VAT Registration No.");
        OIOUBLDocumentEncode.IsValidCountryCode("Sell-to Country/Region Code");
        OIOUBLDocumentEncode.GetOIOUBLCountryRegionCode("Bill-to Country/Region Code");
        OIOUBLDocumentEncode.GetOIOUBLCountryRegionCode(CompanyInfo."Country/Region Code");

        OIOUBLDocumentEncode.GetOIOUBLCurrencyCode("Currency Code");
        CheckSalesLines(Rec);
        DSMCheckSalesLines(Rec); //DSMJMA#5001
    end;

    var
        CompanyInfo: Record "Company Information";
        GLSetup: Record "General Ledger Setup";
        DealerServMgtSetup: Record "Dealer Service Mgt. Setup";
        OIOUBLDocumentEncode: Codeunit "OIOUBL-Document Encode";
        CompanyInfoRead: Boolean;
        GLSetupRead: Boolean;
        InvalidGLNErr: Label 'does not contain a valid, 13-digit GLN', Comment = 'starts with some field name';
        EmptyExtDocNoErr: Label '"You must specify the External Document No. in Sales Header Document Type=''%1'', No.=''%2''.\\If you are using OIOUBL, this field is mandatory regardless of the value in the Ext. Doc. No. Mandatory field in Sales & Receivables Setup."', Comment = '%1 - document type, %2 - document no.';
        EmptyDescriptionErr: Label 'The %1 %2 contains lines in which the Type and the No. are specified, but the Description is empty. This is not allowed for an OIOUBL document which might be created from the posted document.', Comment = '%1 - document type, %2 - document no.';
        EmptyFieldsQst: Label 'The %1 %2 contains lines in which either the Type, the No. or the Description is empty. Such lines will not be taken into account when creating an OIOUBL document.\Do you want to continue?', Comment = '%1 - document type, %2 - document no.';
        WarningExistErr: Label 'The posting has been interrupted to respect the warning.';
        EmptyUnitOfMeasureErr: Label 'The %1 %2 contains lines in which the Unit of Measure field is empty. This is not permitted for an OIOUBL document that is to be created from the posted document.', Comment = '%1 - document type, %2 - document no.';
        ValueNegativeErr: Label 'cannot be negative', Comment = 'starts with some field name';
        AmountNegativeErr: Label 'The total Line Amount cannot be negative.';
        DiscountAmountNegativeErr: Label 'The total Line Discount Amount cannot be negative.';
        Text002: Label 'The total Line Discount Amount cannot be negative.';

    local procedure ReadCompanyInfo();
    begin
        if NOT CompanyInfoRead then begin
            CompanyInfo.GET();
            CompanyInfoRead := TRUE;
        end;
    end;

    local procedure ReadGLSetup();
    begin
        if NOT GLSetupRead then begin
            GLSetup.GET();
            GLSetupRead := TRUE;
        end;
    end;

    local procedure CheckSalesLines(SalesHeader: Record "Sales Header");
    var
        SalesLine: Record "Sales Line";
        EmptyLineFound: Boolean;
        TotalLineAmount: Decimal;
        TotalLineDiscountAmount: Decimal;
    begin
        //DSMDK#2001->
        EXIT;
        //DSMDK#2001<-
        EmptyLineFound := FALSE;
        TotalLineAmount := 0;
        TotalLineDiscountAmount := 0;
        WITH SalesLine do begin
            RESET();
            SETRANGE("Document Type", SalesHeader."Document Type");
            SETRANGE("Document No.", SalesHeader."No.");
            if FINDSET() then
                repeat
                    if (Type <> Type::" ") AND ("No." <> '') AND ("Unit of Measure" = '') then
                        ERROR(EmptyUnitOfMeasureErr, "Document Type", "Document No.");
                    if Description = '' then
                        if (Type <> Type::" ") AND ("No." <> '') then
                            ERROR(EmptyDescriptionErr, "Document Type", "Document No.");
                    TotalLineAmount += "Line Amount";
                    TotalLineDiscountAmount += "Line Discount Amount";
                    if (Type = Type::" ") OR ("No." = '')
                    then
                        EmptyLineFound := TRUE;
                    if "Line Discount %" < 0 then
                        FIELDERROR("Line Discount %", ValueNegativeErr);
                until (NEXT() = 0);
            if TotalLineAmount < 0 then
                ERROR(AmountNegativeErr);
            if TotalLineDiscountAmount < 0 then
                ERROR(DiscountAmountNegativeErr);

            if EmptyLineFound then
                if NOT CONFIRM(EmptyFieldsQst, TRUE, "Document Type", "Document No.") then
                    ERROR(WarningExistErr);
        end;
    end;

    procedure CheckOIOUBLProfile(SalesHeader: Record "Sales Header");
    var
        OIOUBLProfile: Record "OIOUBL-Profile";
        Customer: Record Customer;
    begin
        Customer.GET(SalesHeader."Sell-to Customer No.");
        //if Customer."OIOUBL-Profile Code Required" then begin
        IF (Customer."OIOUBL-Profile Code Required") AND (SalesHeader."Coll.Invoice No." = '') THEN BEGIN //DSMJMA#5000
            SalesHeader.TESTFIELD("OIOUBL-Profile Code");
            OIOUBLProfile.GET(SalesHeader."OIOUBL-Profile Code");
            OIOUBLProfile.TESTFIELD("OIOUBL-Profile ID");
        end;
    end;

    local procedure DSMCheckSalesLines(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        EmptyLineFound: Boolean;
        TotalLineAmount: Decimal;
        TotalLineDiscountAmount: Decimal;
    begin
        //DSMJMA#5001 ->
        TotalLineDiscountAmount := 0;
        WITH SalesLine DO BEGIN
            RESET;
            SETRANGE("Document Type", SalesHeader."Document Type");
            SETRANGE("Document No.", SalesHeader."No.");
            IF FINDSET THEN
                REPEAT
                    TotalLineDiscountAmount += "Line Discount Amount";
                UNTIL (NEXT = 0);
            IF TotalLineDiscountAmount < 0 THEN
                ERROR(Text002);
        end;
        //DSMJMA#5001 <-

    end;
}