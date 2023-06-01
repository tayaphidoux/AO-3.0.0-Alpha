/*
    A minimal re write of the AO System to use Linkset Data
    this script is intended to be a stand alone ao managed from linkset storage
    which would allow it to be populated by any interface script.
    Created: Febuary 5 2023
    By: Phidoux (taya.Maruti)
    ------------------------------------
    | Contributers  and updates below  |
    ------------------------------------
    | Name | Date | comment            |
    ------------------------------------
*/
//string g_sVersion = "1.2.0"; // version (major.minor(no greater than 9 if so rolle to major).bug)

default
{
    state_entry()
    {
        llSetTimerEvent(1);
    }
    attach(key kID)
    {
        if(kID != NULL_KEY)
        {
            llSetTimerEvent(1);
        }
        else
        {
            llSetTimerEvent(0);
        }
    }
    linkset_data(integer iAction,string sName,string sValue)
    {
        if( iAction == LINKSETDATA_UPDATE)
        {
            if(sName == llToLower(llLinksetDataRead("addon_name"))+"_power")
            {
                if((integer)sValue)
                {
                    llSetTimerEvent(1);
                }
                else
                {
                    llSetTimerEvent(0);
                }
            }
        }
        else if( iAction == LINKSETDATA_RESET)
        {
            llResetScript();
        }
    }
    timer()
    {
    
        integer iTyping = (llGetAgentInfo(llGetOwner())&AGENT_TYPING);
        vector vPos = llGetPos();
        float fWater = llWater(ZERO_VECTOR);
        if(vPos.z <= fWater)
        {
            llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_swiming",(string)TRUE);
        }
        else
        {
            llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_swiming",(string)FALSE);
        }

        if(iTyping != (integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_typing"))
        {
            llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_typing",(string)iTyping);
        }

        // Detact if we are in water to enable the swimming anims.
        //llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_animstate",llGetAnimation(llGetOwner()));

        if((integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_standchange") != 0 && llGetUnixTime() > (integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_standtimer"))
        {
            list lAnims = llParseString2List(llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_Standing"),[","],[]);
            integer i;
            if((integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_standrand"))
            {
                i = (integer)llFrand((llGetListLength(lAnims)-1));
            }
            else
            {
                i = llListFindList(lAnims,[llLinksetDataRead("Standing")])+1;
                if ( i >= llGetListLength(lAnims))
                {
                    i = 0;
                }
            }
            string sAnim = llList2String(lAnims,i);
            if(llGetInventoryType(sAnim) == INVENTORY_ANIMATION && sAnim != llLinksetDataRead("Standing"))
            {
                llLinksetDataWrite("Standing",sAnim);
                llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_standtimer",(string)(llGetUnixTime()+(integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_standchange")));
            }
            sAnim = "";
            lAnims = [];
        }
        else if((integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_walkchange") != 0 && llGetUnixTime() > (integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_walktimer"))
        {
            list lAnims = llParseString2List(llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_Walking"),[","],[]);
            integer i;
            if((integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_walkrand"))
            {
                i = (integer)llFrand((llGetListLength(lAnims)-1));
            }
            else
            {
                i = llListFindList(lAnims,[llLinksetDataRead("Walking")])+1;
                if ( i >= llGetListLength(lAnims))
                {
                    i = 0;
                }
            }
            string sAnim = llList2String(lAnims,i);
            if(llGetInventoryType(sAnim) == INVENTORY_ANIMATION && sAnim != llLinksetDataRead("Walking"))
            {
                llLinksetDataWrite("Walking",sAnim);
                llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_walktimer",(string)(llGetUnixTime()+(integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_walkchange")));
            }
            sAnim = "";
            lAnims = [];
        }
        else if((integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_sitchange") != 0 && (integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_sitctl") && llGetUnixTime() > (integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_sittimer"))
        {
            list lAnims = llParseString2List(llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_Sitting"),[","],[]);
            integer i;
            if((integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_sitrand"))
            {
                llOwnerSay("Choosing random animation for sit");
                i = (integer)llFrand((llGetListLength(lAnims)-1));
            }
            else
            {
                llOwnerSay("Choosing next animation for sitting");
                i = llListFindList(lAnims,[llLinksetDataRead("Sitting")])+1;
                if ( i >= llGetListLength(lAnims))
                {
                    i = 0;
                }
            }
            string sAnim = llList2String(lAnims,i);
            if(llGetInventoryType(sAnim) == INVENTORY_ANIMATION && sAnim != llLinksetDataRead("Sitting"))
            {
                llOwnerSay("Changing Sit to "+sAnim);
                llLinksetDataWrite("Sitting",sAnim);
                llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_sittimer",(string)(llGetUnixTime()+(integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_sitchange")));
            }
            sAnim = "";
            lAnims = [];
        }
        else if((integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_gsitchange") != 0 && llGetUnixTime() > (integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_gsittimer"))
        {
            list lAnims = llParseString2List(llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_Sitting on Ground"),[","],[]);
            integer i;
            if((integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_gsitrand"))
            {
                i = (integer)llFrand((llGetListLength(lAnims)-1));
            }
            else
            {
                i = llListFindList(lAnims,[llLinksetDataRead("Sitting on Ground")])+1;
                if ( i >= llGetListLength(lAnims))
                {
                    i = 0;
                }
            }
            string sAnim = llList2String(lAnims,i);
            llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_gsitold",llLinksetDataRead("Sitting on Ground"));
            if((llGetInventoryType(sAnim) & INVENTORY_ANIMATION) && sAnim != llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_gsitold"))
            {
                llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_gsittimer",(string)(llGetUnixTime()+(integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_gsitchange")));
                llLinksetDataWrite("Sitting on Ground",sAnim);
                if((integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_sitanywhere"))
                {
                    llStopAnimation(llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_gsitold"));
                    llSleep(0.1);
                    llStartAnimation(sAnim);
            `   }
            }
            sAnim = "";
            lAnims = [];
        }
    }
}
