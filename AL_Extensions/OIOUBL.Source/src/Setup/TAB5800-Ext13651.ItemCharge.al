// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

tableextension 13651 "OIOUBL-Item Charge" extends "Item Charge"
{
    fields
    {
        field(13630; "OIOUBL-Charge Category"; Option)
        {
            Caption = 'Charge Category';
            DataClassification = CustomerContent;
            OptionMembers = "General Rebate","General Fine","Freight Charge",Duty,Tax;
            OptionCaption = '"General Rebate","General Fine","Freight Charge",Duty,Tax';
        }
    }
}