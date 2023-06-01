//integer CMD_ZERO            = 0;
integer CMD_OWNER           = 500;
//integer CMD_TRUSTED         = 501;
//integer CMD_GROUP           = 502;
integer CMD_WEARER          = 503;
//integer CMD_EVERYONE        = 504;
//integer CMD_BLOCKED         = 598; // <--- Used in auth_request, will not return on a CMD_ZERO
//integer CMD_RLV_RELAY       = 507;
//integer CMD_SAFEWORD        = 510;
//integer CMD_RELAY_SAFEWORD  = 511;
//integer CMD_NOACCESS        = 599;

//integer g_iMenuStride;
integer g_iPage = 0;
integer g_iNumberOfPages;
//integer g_iStandTime = 120; // Default Stand timer.

string UPMENU = "BACK";
//string b_sStandLoop;
string b_sStandRand;
//string b_sWalkLoop;
string b_sWalkRand;
//string b_sSitLoop;
string b_sSitRand;
//string b_sGroundSitLoop;
string b_sGroundSitRand;
list g_lCheckBoxes = ["▢","▣"];
list g_lTimerButtons = ["+1","+5","+10","-1","-5","-10"];
//
Dialog(key kID, string sPrompt, list lChoices, list lUtilityButtons, integer iPage, integer iAuth, string sName)
{
    list g_lMenuIDs;
    if(llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_menu") != "")
    {
        g_lMenuIDs = llParseString2List(llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_menu"),[","],[]);
    }
    integer iChannel = llRound(llFrand(10000000)) + 100000;
    while (~llListFindList(g_lMenuIDs, [iChannel]))
    {
        iChannel = llRound(llFrand(10000000)) + 100000;
    }
    integer iListener = llListen(iChannel, "",kID, "");
    integer iTime = llGetUnixTime() + 180;
    integer iIndex = llListFindList(g_lMenuIDs, [(string)kID]);
    if (~iIndex)
    {
        llListenRemove(llList2Integer(g_lMenuIDs,2));
        g_lMenuIDs = llListReplaceList(g_lMenuIDs,[kID, iChannel, iListener, iTime, sName, iAuth],iIndex,iIndex+4);
    }
    else
    {
        g_lMenuIDs += [kID, iChannel, iListener, iTime, sName, iAuth];
    }
    llDialog(kID,sPrompt,SortButtons(lChoices,lUtilityButtons),iChannel);
    llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_menu",llDumpList2String(g_lMenuIDs,","));
    iPage = 0;
    g_lMenuIDs = [];
}

list SortButtons(list lButtons, list lStaticButtons)
{
    list lSpacers;
    list lAllButtons = lButtons + lStaticButtons;
    //cutting off too many buttons, no multi page menus as of now
    while (llGetListLength(lAllButtons)>12)
    {
        lButtons = llDeleteSubList(lButtons,0,0);
        lAllButtons = lButtons + lStaticButtons;
    }
    while (llGetListLength(lAllButtons) % 3 != 0 && llGetListLength(lAllButtons) < 12)
    {
        lSpacers += "-";
        lAllButtons = lButtons + lSpacers + lStaticButtons;
    }
    integer i = llListFindList(lAllButtons, ["BACK"]);
    if (~i)
    {
        lAllButtons = llDeleteSubList(lAllButtons, i, i);
    }
    list lOut = llList2List(lAllButtons, 9, 11);
    lOut += llList2List(lAllButtons, 6, 8);
    lOut += llList2List(lAllButtons, 3, 5);
    lOut += llList2List(lAllButtons, 0, 2);
    if (~i)
    {
        lOut = llListInsertList(lOut, ["BACK"], 2);
    }
    lAllButtons = [];
    lButtons = [];
    lSpacers = [];
    lStaticButtons = [];
    return lOut;
}

MenuAnims(key kID, integer iAuth)
{
    string sPrompt = "|=====Animations=====|";
    list lButtons  = ["GroundSit","Sitting","Standing","Walking"];
    // Start dialog.
    Dialog(kID, sPrompt, lButtons, [UPMENU], 0, iAuth, "Menu~Anims");
}

MenuStanding(key kID, integer iAuth)
{
    string sPrompt = "|=====Stands=====|";
    // load toggle buttons.
    b_sStandRand = llList2String(g_lCheckBoxes,(integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_standrand"))+"Shuffle Stand";
    // set status information.
    sPrompt +=  "\n Current Stand Timer:"+llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_standchange")+
                "\n"+b_sStandRand;
    // Populate Buttons list.
    list lButtons  = [];
    if((integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_standchange") > 0)
    {
        lButtons = ["Stand Time",b_sStandRand];
    }
    else
    {
        lButtons = ["Select Stand","Stand Time"];
    }
    // Start dialog.
    Dialog(kID, sPrompt, lButtons, [UPMENU], 0, iAuth, "Stand~Main");
}

MenuStandTime(key kID, integer iAuth)
{
    string sPrompt = "|=====Stand Time=====|";
    // load toggle buttons.
    // set status information.
    sPrompt +=  "\n Current Stand Timer:"+llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_standchange")+
                "\n"+b_sStandRand+
                "\n 0 = Disabled";
    // Populate Buttons list.
    list lButtons = g_lTimerButtons+["Custom"];
    // Start dialog.
    Dialog(kID, sPrompt, lButtons, ["Disable",UPMENU], 0, iAuth, "Stand~Time");
}

MenuWalking(key kID, integer iAuth)
{
    string sPrompt = "|=====Walks=====|";
    // load toggle buttons.
    b_sWalkRand = llList2String(g_lCheckBoxes,(integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_walkrand"))+"Shuffle Walk";
    // set status information.
    sPrompt +=  "\n Current Walk Timer:"+llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_walkchange")+
                "\n"+b_sWalkRand;
    // Populate Buttons list.
    list lButtons  = [];
    if((integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_walkchange") > 0)
    {
        lButtons = ["Walk Time",b_sWalkRand];
    }
    else
    {
        lButtons = ["Select Walk","Walk Time"];
    }
    // Start dialog.
    Dialog(kID, sPrompt, lButtons, [UPMENU], 0, iAuth, "Walk~Main");
}

MenuWalkTime(key kID, integer iAuth)
{
    string sPrompt = "|=====Walk Time=====|";
    // load toggle buttons.
    // set status information.
    sPrompt +=  "\n Current Walk Timer:"+llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_walkchange")+
                "\n"+b_sWalkRand+
                "\n 0 = Disabled";
    // Populate Buttons list.
    list lButtons = g_lTimerButtons+["Custom"];
    // Start dialog.
    Dialog(kID, sPrompt, lButtons, ["Disable",UPMENU], 0, iAuth, "Walk~Time");
}

MenuSitting(key kID, integer iAuth)
{
    string sPrompt = "|=====Sits=====|";
    // load toggle buttons.
    b_sSitRand = llList2String(g_lCheckBoxes,(integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_sitrand"))+"Shuffle Sit";
    // set status information.
    sPrompt +=  "\n Current Sit Timer:"+llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_sitchange")+
                "\n"+b_sSitRand;
    // Populate Buttons list.
    list lButtons  = [];
    if((integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_sitchange") > 0)
    {
        lButtons = ["Sit Time",b_sSitRand];
    }
    else
    {
        lButtons = ["Select Sit","Sit Time"];
    }
    // Start dialog.
    Dialog(kID, sPrompt, lButtons, [UPMENU], 0, iAuth, "Sit~Main");
}

MenuSitTime(key kID, integer iAuth)
{
    string sPrompt = "|=====Sit Time=====|";
    // load toggle buttons.
    // set status information.
    sPrompt +=  "\n Current Sit Timer:"+llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_sitchange")+
                "\n"+b_sSitRand+
                "\n 0 = Disabled";
    // Populate Buttons list.
    list lButtons = g_lTimerButtons+["Custom"];
    // Start dialog.
    Dialog(kID, sPrompt, lButtons, ["Disable",UPMENU], 0, iAuth, "Sit~Time");
}
MenuGSitting(key kID, integer iAuth)
{
    string sPrompt = "|=====GroundSits=====|";
    // load toggle buttons.
    b_sGroundSitRand = llList2String(g_lCheckBoxes,(integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_gsitrand"))+"Shuffle GroundSit";
    // set status information.
    sPrompt +=  "\n Current GroundSit Timer:"+llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_gsitchange")+
                "\n"+b_sGroundSitRand;
    // Populate Buttons list.
    list lButtons  = [];
    if((integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_gsitchange") > 0)
    {
        lButtons = ["GroundSit Time",b_sGroundSitRand];
    }
    else
    {
        lButtons = ["Select GroundSit","GroundSit Time"];
    }
    // Start dialog.
    Dialog(kID, sPrompt, lButtons, [UPMENU], 0, iAuth, "GroundSit~Main");
}

MenuGroundSitTime(key kID, integer iAuth)
{
    string sPrompt = "|=====GroundSit Time=====|";
    // load toggle buttons.
    // set status information.
    sPrompt +=  "\n Current GroundSit Timer:"+llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_gsitchange")+
                "\n 0 = Disabled";
    // Populate Buttons list.
    list lButtons = g_lTimerButtons+["Custom"];
    // Start dialog.
    Dialog(kID, sPrompt, lButtons, ["Disable",UPMENU], 0, iAuth, "GroundSit~Time");
}


default
{
    listen(integer iChannel, string sName, key kID, string sMsg)
    {
        if (~llListFindList( llParseString2List(llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_menu"),[","],[]),[(string)kID,(string)iChannel]))
        {
            list g_lMenuIDs = llParseString2List(llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_menu"),[","],[]);
            //llOwnerSay(llToLower(llLinksetDataRead("addon_name"))+"_menu"+" Data is\n["+llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_menu")+"]\nand g_lMenuIDs Data is\n["+llDumpList2String(g_lMenuIDs,",")+"]");
            if(llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_menu") == "")
            {
                llOwnerSay("Error Menu is Blank when it should not be!");
                g_lMenuIDs = [];
            }
            integer iMenuIndex = llListFindList(g_lMenuIDs, [(string)kID]);
            integer iAuth = llList2Integer(g_lMenuIDs,iMenuIndex+5);
            string sMenu = llList2String(g_lMenuIDs, iMenuIndex+4);
            llListenRemove(llList2Integer(g_lMenuIDs,iMenuIndex+2));
            g_lMenuIDs = llDeleteSubList(g_lMenuIDs,iMenuIndex, iMenuIndex+4);
            llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_menu",llDumpList2String(g_lMenuIDs,","));
            g_lMenuIDs=[];
            integer iRespring = TRUE;
            if( sMenu == "Menu~Anims")
            {
                if (sMsg == UPMENU)
                {
                    iRespring = FALSE;
                    llMessageLinked(LINK_SET,iAuth,"Menu",kID);
                }
                else if( sMsg == "GroundSit")
                {
                    iRespring = FALSE;
            MenuGSitting(kID, iAuth);
                }
                else if( sMsg == "Sitting")
                {
                    iRespring = FALSE;
            MenuSitting(kID, iAuth);
                }
                else if( sMsg == "Standing")
                {
                    iRespring = FALSE;
            MenuStanding(kID, iAuth);
                }
                else if( sMsg == "Walking")
                {
                    iRespring = FALSE;
            MenuWalking(kID, iAuth);
                }
                if(iRespring)
                {
                    MenuAnims(kID,iAuth);
                }
            }
            else if( sMenu == "Stand~Main")
            {
                if (sMsg == UPMENU)
                {
                    iRespring = FALSE;
            MenuAnims(kID, iAuth);
                }
                else if (sMsg == b_sStandRand)
                {
                    llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_standrand",(string)(!(integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_standrand")));
                }
                else if (sMsg == "Stand Time")
                {
                    iRespring = FALSE;
                    MenuStandTime(kID, iAuth);
                }
                if(iRespring)
                {
                    MenuStanding(kID, iAuth);
                }
            }
            else if( sMenu == "Stand~Time")
            {
                if (sMsg == UPMENU)
                {
                    MenuStanding(kID, iAuth);
                    iRespring = FALSE;
                }
                else if(sMsg == "Disable")
                {
                    if((integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_standchange"))
                    {
                        llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_standchange",(string)0);
                    }
                    else
                    {
                        llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_standchange",(string)120);
                    }
                }
                else if(llGetSubString(sMsg,0,0) == "+")
                {
                    sMsg = llDeleteSubString(sMsg,0,0);
                    llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_standchange",(string)((integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_standchange")+(integer)sMsg));
                }
                else if(llGetSubString(sMsg,0,0) == "-")
                {
                    sMsg = llDeleteSubString(sMsg,0,0);
                    if((integer)sMsg > (integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_standchange"))
                    {
                        llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_standchange","0");
                    }
                    else
                    {
                        llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_standchange",(string)((integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_standchange")-(integer)sMsg));
                    }
                }
                if(iRespring)
                {
                    MenuStandTime(kID, iAuth);
                }
            }
            else if( sMenu == "Walk~Main")
            {
                if (sMsg == UPMENU)
                {
                    iRespring = FALSE;
            MenuAnims(kID, iAuth);
                }
                else if (sMsg == b_sWalkRand)
                {
                    llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_walkrand",(string)(!(integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_walkrand")));
                }
                else if (sMsg == "Walk Time")
                {
                    iRespring = FALSE;
                    MenuWalkTime(kID, iAuth);
                }
                if(iRespring)
                {
                    MenuWalking(kID, iAuth);
                }
            }
            else if( sMenu == "Walk~Time")
            {
                if (sMsg == UPMENU)
                {
                    MenuWalking(kID, iAuth);
                    iRespring = FALSE;
                }
                else if(sMsg == "Disable")
                {
                    if((integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_walkchange"))
                    {
                        llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_walkchange",(string)0);
                    }
                    else
                    {
                        llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_walkchange",(string)120);
                    }
                }
                else if(llGetSubString(sMsg,0,0) == "+")
                {
                    sMsg = llDeleteSubString(sMsg,0,0);
                    llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_walkchange",(string)((integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_walkchange")+(integer)sMsg));
                }
                else if(llGetSubString(sMsg,0,0) == "-")
                {
                    sMsg = llDeleteSubString(sMsg,0,0);
                    if((integer)sMsg > (integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_walkchange"))
                    {
                        llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_walkchange","0");
                    }
                    else
                    {
                        llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_walkchange",(string)((integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_walkchange")-(integer)sMsg));
                    }
                }
                if(iRespring)
                {
                    MenuWalkTime(kID, iAuth);
                }
            }
        else if( sMenu == "Sit~Main")
            {
                if (sMsg == UPMENU)
                {
                    iRespring = FALSE;
            MenuAnims(kID, iAuth);
                }
                else if (sMsg == b_sSitRand)
                {
                    llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_sitrand",(string)(!(integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_sitrand")));
                }
                else if (sMsg == "Sit Time")
                {
                    iRespring = FALSE;
                    MenuSitTime(kID, iAuth);
                }
                if(iRespring)
                {
                    MenuSitting(kID, iAuth);
                }
            }
            else if( sMenu == "Sit~Time")
            {
                if (sMsg == UPMENU)
                {
                    MenuSitting(kID, iAuth);
                    iRespring = FALSE;
                }
                else if(sMsg == "Disable")
                {
                    if((integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_sitchange"))
                    {
                        llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_sitchange",(string)0);
                    }
                    else
                    {
                        llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_sitchange",(string)120);
                    }
                }
                else if(llGetSubString(sMsg,0,0) == "+")
                {
                    sMsg = llDeleteSubString(sMsg,0,0);
                    llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_sitchange",(string)((integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_sitchange")+(integer)sMsg));
                }
                else if(llGetSubString(sMsg,0,0) == "-")
                {
                    sMsg = llDeleteSubString(sMsg,0,0);
                    if((integer)sMsg > (integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_sitchange"))
                    {
                        llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_sitchange","0");
                    }
                    else
                    {
                        llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_sitchange",(string)((integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_sitchange")-(integer)sMsg));
                    }
                }
                if(iRespring)
                {
                    MenuSitTime(kID, iAuth);
                }
            }
            else if( sMenu == "GroundSit~Main")
            {
                if (sMsg == UPMENU)
                {
                    iRespring = FALSE;
            MenuAnims(kID, iAuth);
                }
                else if (sMsg == b_sGroundSitRand)
                {
                    llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_gsitrand",(string)(!(integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_gsitrand")));
                }
                else if (sMsg == "GroundSit Time")
                {
                    iRespring = FALSE;
                    MenuGroundSitTime(kID, iAuth);
                }
                if(iRespring)
                {
                    MenuGSitting(kID, iAuth);
                }
            }
            else if( sMenu == "GroundSit~Time")
            {
                if (sMsg == UPMENU)
                {
                    MenuGSitting(kID, iAuth);
                    iRespring = FALSE;
                }
                else if(sMsg == "Disable")
                {
                    if((integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_gsitchange"))
                    {
                        llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_gsitchange",(string)0);
                    }
                    else
                    {
                        llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_gsitchange",(string)120);
                    }
                }
                else if(llGetSubString(sMsg,0,0) == "+")
                {
                    sMsg = llDeleteSubString(sMsg,0,0);
                    llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_gsitchange",(string)((integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_gsitchange")+(integer)sMsg));
                }
                else if(llGetSubString(sMsg,0,0) == "-")
                {
                    sMsg = llDeleteSubString(sMsg,0,0);
                    if((integer)sMsg > (integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_gsitchange"))
                    {
                        llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_gsitchange","0");
                    }
                    else
                    {
                        llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_gsitchange",(string)((integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_gsitchange")-(integer)sMsg));
                    }
                }
                if(iRespring)
                {
                    MenuGroundSitTime(kID, iAuth);
                }
            }
        }
    }

    link_message(integer iLink, integer iNum,string sMsg, key kID)
    {
        if (iNum <= CMD_WEARER && iNum >= CMD_OWNER)
        {
            if(sMsg == "MenuAnims")
            {
                if(llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_menu") != "")
                {
                    llLinksetDataDelete(llToLower(llLinksetDataRead("addon_name"))+"_menu");
                }
                MenuAnims(kID, iNum);
            }
        }
    }

    linkset_data(integer iAction,string sName,string sVal)
    {
        if(iAction == LINKSETDATA_RESET)
        {
            llResetScript();
        }
    }
}
