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

string UPMENU = "BACK";
//string b_sLock;
//string b_sAccess;
string b_sPower;
string b_sSitAny;
// these buttons will be used for making loops.
string b_sSitAO;
list g_lCheckBoxes = ["▢","▣"];
list g_lCustomCards = [];
//

Dialog(key kID, string sPrompt, list lChoices, list lUtilityButtons, integer iPage, integer iAuth, string sName)
{
    list g_lMenuIDs = llCSV2List(llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_menu"));
    integer iChannel = llRound(llFrand(10000000)) + 100000;
    while (~llListFindList(g_lMenuIDs, [iChannel]))
    {
        iChannel = llRound(llFrand(10000000)) + 100000;
    }
    integer iListener = llListen(iChannel, "",kID, "");
    integer iTime = llGetUnixTime() + 180;
    integer iIndex = llListFindList(g_lMenuIDs, [kID]);
    if (~iIndex)
    {
        llListenRemove(llList2Integer(g_lMenuIDs,2));
        g_lMenuIDs = llListReplaceList(g_lMenuIDs,[kID, iChannel, iListener, iTime, sName, iAuth],iIndex,iIndex+4);
    }
    else
    {
        g_lMenuIDs = [kID, iChannel, iListener, iTime, sName, iAuth];
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

Menu(key kID, integer iAuth)
{
    string sPrompt = "|====="+llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_addon")+" Main=====|"+
        "\n Version: "+llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_ver");
    // load toggle buttons.
    b_sPower = llList2String(g_lCheckBoxes,(integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_power"))+"Power";
    b_sSitAny= llList2String(g_lCheckBoxes,(integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_sitanywhere"))+"Sit Anywhere";
    b_sSitAO = llList2String(g_lCheckBoxes,(integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_sitctl"))+"Sit AO";
    // set status information.
    sPrompt +=  "\nNotecard:"+llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_card")+
                "\n"+llList2String(g_lCheckBoxes,(integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_loaded"))+"Loaded"+
                "\n"+llList2String(g_lCheckBoxes,(integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_online"))+"Collar Addon"+
                "\n"+b_sPower+
                "\n"+b_sSitAny
    ;
    // Populate Buttons list.
    list lButtons  = [b_sPower,"Load",b_sSitAny,b_sSitAO,"Anims"];
    // Start dialog.
    Dialog(kID, sPrompt, lButtons, ["Admin", UPMENU], 0, iAuth, "Menu~Main");
}

MenuLoad(key kID, integer iPage, integer iAuth)
{
    if (!iPage)
    {
        g_iPage = 0;
    }
    string sPrompt = "\nLoad an animation set!";
    list lButtons;
    g_lCustomCards = [];
    integer iEnd = llGetInventoryNumber(INVENTORY_NOTECARD);
    integer iCountCustomCards;
    string sNotecardName;
    integer i;
    while (i < iEnd)
    {
        sNotecardName = llGetInventoryName(INVENTORY_NOTECARD, i++);
        if (llSubStringIndex(sNotecardName,".") && sNotecardName != "")
        {
            if (!llSubStringIndex(sNotecardName,"SET"))
            {
                g_lCustomCards += [sNotecardName,"Wildcard "+(string)(++iCountCustomCards)];// + g_lCustomCards;
            }
            else if(llStringLength(sNotecardName) < 24)
            {
                lButtons += sNotecardName;
            }
            else
            {
                llOwnerSay(sNotecardName+"'s name is too long to be displayed in menus and cannot be used.");
            }
        }
    }
    i = 1;
    while (i <= 2*iCountCustomCards)
    {
        lButtons += llList2List(g_lCustomCards,i,i);
        i += 2;
    }
    list lStaticButtons = ["BACK"];
    if (llGetListLength(lButtons) > 11)
    {
        lStaticButtons = ["◄","►","BACK"];
        g_iNumberOfPages = llGetListLength(lButtons)/9;
        lButtons = llList2List(lButtons,iPage*9,iPage*9+8);
    }
    if (!llGetListLength(lButtons)){
        llOwnerSay("There aren't any animation sets installed!");
    }
    Dialog(kID, sPrompt, lButtons, lStaticButtons, iPage, iAuth,"Menu~Load");
}

MenuAdmin(key kID, integer iAuth)
{
    string sPrompt = "|=====Adnimistration=====|";

    list lButtons  = ["ResetAO"];
    list lUtilityButtons = [];// this is only here so we can set ultities to respect online and offline mode.

    if( (integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_online")) // we only need certain buttons when they are nesissary.
    {
        lUtilityButtons = ["Collar","DISCONNECT",UPMENU];
    }
    else
    {
        lUtilityButtons = ["CONNECT",UPMENU];
    }

    Dialog(kID, sPrompt, lButtons, lUtilityButtons, 0, iAuth, "Menu~Admin");
}

Menu_Confirm(key kID, integer iAuth, string sMenu, string sQuery)
{
    //llOwnerSay("Prompting confirmation!");
    string sPrompt = "\n ao Confirmation Menu\n\n"+sQuery;
    string sQMenu = "Menu-Q"+sMenu;
    list lButtons = ["Yes","No"];
    Dialog(kID, sPrompt, lButtons, [], 0, iAuth, sQMenu);
}

default
{
    state_entry()
    {
        if(llGetAttached())
        {
            llLinksetDataWrite("auth_wearer",llGetOwner());
            if(llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_menu") != "")
            {
                llOwnerSay("Clearing old menues!");
                llLinksetDataDelete(llToLower(llLinksetDataRead("addon_name"))+"_menu");
            }
            llSetTimerEvent(1);
        }
    }

    timer()
    {
        // clear active menues weather from this script or another one.
        list g_lMenuIDs = llParseString2List(llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_menu"),[","],[]);
        if(llGetListLength(g_lMenuIDs))
        {
            if(llGetUnixTime() > llList2Integer(g_lMenuIDs,3))
            {
                llListenRemove(llList2Integer(g_lMenuIDs,2));
                llLinksetDataDelete(llToLower(llLinksetDataRead("addon_name"))+"_menu");
                g_lCustomCards = [];
            }
        }
        g_lMenuIDs=[];
    }

    listen(integer iChannel, string sName, key kID, string sMsg)
    {
        if (~llListFindList( llParseString2List(llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_menu"),[","],[]),[(string)kID,(string)iChannel]))
        {
            list g_lMenuIDs = llParseString2List(llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_menu"),[","],[]);
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
            if (sMenu == "Menu~Main")
            {
                if (sMsg == "Admin")
                {
                    MenuAdmin(kID, iAuth);
                    iRespring = FALSE;
                }
                else if (sMsg == "Anims")
                {
                    iRespring = FALSE;
                    llMessageLinked(LINK_SET,iAuth,"MenuAnims",kID);
                }
                else if (sMsg == "Load")
                {
                    MenuLoad(kID, 0, iAuth);
                    iRespring = FALSE;
                }
                else if(sMsg == b_sSitAO)
                {
                    llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_sitctl",(string)(!(integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_sitctl")));
                }
                else if (sMsg == b_sPower)
                {
                    llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_power",(string)(!(integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_power")));
                }
                else if( sMsg == b_sSitAny)
                {
                    llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_sitanywhere",(string)(!(integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_sitanywhere")));
                }
                if(iRespring)
                {
                    Menu(kID,iAuth);
                }
            }
            else if( sMenu == "Menu~Load")
            {
                integer index = llListFindList(g_lCustomCards,[sMsg]);
                if (~index)
                {
                    sMsg = llList2String(g_lCustomCards,index-1);
                }
                if (llGetInventoryType(sMsg) == INVENTORY_NOTECARD)
                {
                    if(llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_card") != sMsg) // there is no point in expending the time to read whats already in memory.
                    {
                        if(llGetInventoryType(sMsg) == INVENTORY_NOTECARD)
                        {
                            llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_loaded",(string)FALSE);
                            llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_card",sMsg);
                        }
                        else if (kID != "" && kID != NULL_KEY)
                        {
                            llInstantMessage(kID,"that card does not seem to exist!");
                            MenuLoad(kID,g_iPage,iAuth);
                        }
                    }
                    else if (kID != "" && kID != NULL_KEY)
                    {
                        llInstantMessage(kID,"Card is already loaded try a different one or clear memory");
                        MenuLoad(kID,g_iPage,iAuth);
                    }
                    return;
                }
                else if ((integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_loaded")&& sMsg == "BACK")
                {
                    Menu(kID,iAuth);
                    g_lCustomCards = [];
                    return;
                }
                else if (sMsg == "►")
                {
                    if (++g_iPage > g_iNumberOfPages)
                    {
                        g_iPage = 0;
                    }
                }
                else if (sMsg == "◄")
                {
                    if (--g_iPage < 0)
                    {
                        g_iPage = g_iNumberOfPages;
                    }
                }
                else if (!(integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_loaded"))
                {
                     llOwnerSay("Please load an animation set first.");
                }
                else
                {
                    llOwnerSay("Could not find animation set: "+sMsg);
                }
                MenuLoad(kID,g_iPage,iAuth);
            }
            else if( sMenu == "Menu~Admin")
            {
                if (sMsg == UPMENU)
                {
                    iRespring = FALSE;
                    Menu(kID, iAuth);
                }
                else if (sMsg == "Reset AO") // so we can clear memory in the event of bugs.
                {
                    iRespring = FALSE;
                    Menu_Confirm(kID,iAuth,"mem","Would you like to clear LinksetData?");
                }
                else if (sMsg == "Print Memory")
                {
                    llOwnerSay("Requestiong Memory");
                    llMessageLinked(LINK_SET,0,"memory_print",(string)kID);
                }
                else if (sMsg == "Print LSD")
                {
                    list lLSD = llListSort(llLinksetDataListKeys(0,llLinksetDataCountKeys()-1),1,TRUE);
                    integer iIndex = 0;
                    string sKey;
                    for(iIndex = 0; iIndex < llGetListLength(lLSD); iIndex++)
                    {
                        sKey = llList2String(lLSD,iIndex);
                        llInstantMessage(kID,sKey+"="+llLinksetDataRead(sKey));
                    }
                    sKey="";
                    lLSD = [];
                }
                else if (sMsg == "Collar")
                {
                    iRespring = FALSE;
                    llMessageLinked(LINK_SET,iAuth,"CollarMenu",kID);
                }
                else if (sMsg == "DISCONNECT")
                {
                    iRespring = FALSE;
                    llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_online",(string)FALSE);
                }
                else if (sMsg == "CONNECT")
                {
                    iRespring = FALSE;
                    // if the collar disconects but is available we want the user to be able to connect it if they don't wish to safe word.
                    llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_online",(string)TRUE);
                }
                if(iRespring)
                {
                    MenuAdmin(kID,iAuth);
                }
            }
            else if(~llSubStringIndex(sMenu,"Menu-Q"))
            {
                if( sMsg == "Yes")
                {
                    if(~llSubStringIndex(sMenu,"mem"))
                    {
                        llOwnerSay("AO memory is being wiped and scripts being reset");
                        llLinksetDataReset();
                    }
                }
                else if( sMsg == "No")
                {
                    if(~llSubStringIndex(sMenu,"mem"))
                    {
                        MenuAdmin(kID, iAuth);
                    }
                }
            }
        }
    }

    link_message(integer iLink, integer iNum,string sMsg, key kID)
    {
        if (iNum <= CMD_WEARER && iNum >= CMD_OWNER)
        {
            if(sMsg == "Menu")
            {
                Menu(kID,iNum);
            }
        }
    }

    linkset_data(integer iAction,string sName,string sVal)
    {
        if(iAction == LINKSETDATA_UPDATE)
        {
            if(sName == llToLower(llLinksetDataRead("addon_name"))+"_loaded" && (integer)sVal) // bring up this menu from any other script.
            {
                llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_power",(string)TRUE);
            }
        }
        else if(iAction == LINKSETDATA_RESET)
        {
            // should alway reset the scripts if LSD changes to make sure settings are reloaded or updated.
            llResetScript();
        }
    }
}
