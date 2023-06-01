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
//float g_fTimer = 0.000000001; // need a fast timer for the ao

// this list is of the animation states so that we can loop through and pick up each one from linkset data.
list g_lAnimStates = [ //http://wiki.secondlife.com/wiki/LlSetAnimationOverride
    "Crouching","CrouchWalking","Falling Down","Flying","FlyingSlow",
    "Hovering","Hovering Down","Hovering Up","Jumping","Landing",
    "PreJumping","Running","Standing","Sitting","Sitting on Ground","Standing Up",
    "Striding","Soft Landing","Taking Off","Turning Left","Turning Right","Walking"
];

list g_lSwimStates = [
    "Flying","FlyingSlow","Hovering","Hovering Down","Hovering Up"
];

// this list is garbage collection to keep the script clean and to solve for a bug causing (: Could not find animation ''.) where a reandom blank animation was beeing injected.
list g_lIgnore = [
    "\\","\"","[","]",".","/"," ",
    "(",")","?","!","@","#","$","%",
    "^","&","*","'",":",";","|","<",
    ">",",","-","=","+","_",""
];

TypingAO()
{
    if(llLinksetDataRead("Typing") != "" && llGetInventoryType(llLinksetDataRead("Typing")) == INVENTORY_ANIMATION && (integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_typingctl"))
    {
        if(!(integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_typing") || !(integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_power"))
        {
            llStopAnimation(llLinksetDataRead("Typing"));
        }
        else
        {
            llStartAnimation(llLinksetDataRead("Typing"));
        }
    }
}

SetAO()
{
    /*
        This Section is greatly simplified because all its going to manage is the ao list
        form Linkset Data we will be able to do tricks in another script to manage things like
        swiming by replacing the fly/hover animations with swim ones so this section
        has no reason to care about a list.
    */
    if (llGetPermissions() & PERMISSION_OVERRIDE_ANIMATIONS && (integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_power") && !(integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_sitanywhere") )
    {
        integer i;
        integer iListLen = llGetListLength(g_lAnimStates);
        string sAnim;
        string sAnimState;
        integer iLoaded = 0;
        for (i = 0; i<iListLen; i++)
        {
            sAnimState = llList2String(g_lAnimStates,i);
            if(~llListFindList(g_lSwimStates,[sAnimState]) && (integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_swiming"))
            {
                // if swimming convert the use the swim animations for these states.
                string sSwimState = "";
                if(sAnimState == "Flying" || sAnimState == "Running")
                {
                    sSwimState = "Swim Forward";
                }
                else if(sAnimState == "FlyingSlow" || sAnimState == "Walking")
                {
                    sSwimState = "Swim Slow";
                }
                else if(sAnimState == "Hovering" || sAnimState == "Striding" || sAnimState == "Falling Down")
                {
                    sSwimState = "Swim Hover";
                }
                else if(sAnimState == "Hovering Down")
                {
                    sSwimState = "Swim Down";
                }
                else if(sAnimState == "Hovering Up")
                {
                    sSwimState = "Swim Up";
                }
                if(llLinksetDataRead(sSwimState) != "") // only use the swim animation if it exists
                {
                    sAnim = llLinksetDataRead(sSwimState);
                }
                else
                {
                    sAnim = llLinksetDataRead(sAnimState);
                }
                sSwimState = "";
            }
            else
            {
                sAnim = llLinksetDataRead(sAnimState);
            }
            if (llGetInventoryType(sAnim) == INVENTORY_ANIMATION && !~llListFindList(g_lIgnore,[sAnim]))
            {
                if((integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_sitctl"))
                {
                    llResetAnimationOverride(sAnimState);
                    llSetAnimationOverride(sAnimState, sAnim);
                }
                else if(sAnimState != "Sitting")
                {
                    llResetAnimationOverride(sAnimState);
                    llSetAnimationOverride(sAnimState, sAnim);
                }
                iLoaded++;
            }
            else if( sAnim != "")
            {
                // we may have to change this up a bit but for now this will alert us if any animations are not in the ao.

                if((integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_sitctl"))
                {
                    llResetAnimationOverride(sAnimState);
                }
                else if(sAnimState != "Sitting")
                {
                    llResetAnimationOverride(sAnimState);
                }
                llOwnerSay("Animation ("+sAnim+") could not be found.");
            }
        }
        //llOwnerSay((string)iLoaded+"/"+(string)iListLen+" Aniamtions were loaded");
        sAnim = "";
        sAnimState = "";
    }
}

StopAO()
{
    llSetTimerEvent(0);
    if(llGetPermissions() & PERMISSION_OVERRIDE_ANIMATIONS && llGetPermissions() & PERMISSION_TRIGGER_ANIMATION)
    {
        llResetAnimationOverride("ALL");
        if(llLinksetDataRead("Typing") != "")
        {
            llStopAnimation(llLinksetDataRead("Typing"));
        }
        if((integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_sitanywhere"))
        {
            llStopAnimation("Sitting on Ground");
        }
    }
}

recordMemory()
{
    llLinksetDataWrite("memory_"+llGetScriptName(),(string)llGetUsedMemory());
}

check_settings(string sToken, string sDefaulVal)
{
    if(!~llListFindList(llLinksetDataListKeys(0,0),[sToken])) // token/key doesn't exist in the list of keys
    {
        llLinksetDataWrite(sToken, sDefaulVal);
    }
    else if(llLinksetDataRead(sToken) == "")
    {
        llLinksetDataWrite(sToken, sDefaulVal);
    }
}

gsitAO()
{
    if((integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_sitanywhere"))
    {
        llOwnerSay("Starting animation:"+llLinksetDataRead("Sitting on Ground"));
        llStartAnimation(llLinksetDataRead("Sitting on Ground"));
    }
    else
    {
        list lGSit = llParseString2List(llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_Sitting on Ground"),[","],[]);
        integer iIndex;
        for(iIndex = 0; iIndex < (llGetListLength(lGSit)-1); iIndex++)
        {
            llStopAnimation(llList2String(lGSit,iIndex));
        }
        lGSit = [];
        llSleep(0.1);
        SetAO();
    }
}

default
{
    state_entry()
    {
        check_settings(llToLower(llLinksetDataRead("addon_name"))+"_wingschange",(string)120);
        check_settings(llToLower(llLinksetDataRead("addon_name"))+"_wingsrand",(string)TRUE);
        check_settings(llToLower(llLinksetDataRead("addon_name"))+"_standchange",(string)120);
        check_settings(llToLower(llLinksetDataRead("addon_name"))+"_standrand",(string)TRUE);
        check_settings(llToLower(llLinksetDataRead("addon_name"))+"_sitanywhere",(string)FALSE);
        check_settings(llToLower(llLinksetDataRead("addon_name"))+"_sitctl",(string)FALSE);
        check_settings(llToLower(llLinksetDataRead("addon_name"))+"_sitchange",(string)120);
        check_settings(llToLower(llLinksetDataRead("addon_name"))+"_sitrand",(string)FALSE);
        check_settings(llToLower(llLinksetDataRead("addon_name"))+"_gsitchange",(string)120);
        check_settings(llToLower(llLinksetDataRead("addon_name"))+"_gsitrand",(string)FALSE);
        check_settings(llToLower(llLinksetDataRead("addon_name"))+"_walkchange",(string)120);
        check_settings(llToLower(llLinksetDataRead("addon_name"))+"_walkrand",(string)TRUE);
        check_settings(llToLower(llLinksetDataRead("addon_name"))+"_typingctl",(string)TRUE);
        if(llGetAttached())
        {
            if((integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_power"))
            {
                if(llGetPermissions() & PERMISSION_OVERRIDE_ANIMATIONS && llGetPermissions() & PERMISSION_TRIGGER_ANIMATION)
                {
                    llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_animstate",llGetAnimation(llGetOwner()));
                    SetAO();
                    gsitAO();
                }
                else
                {
                    llRequestPermissions((key)llGetOwner(),PERMISSION_OVERRIDE_ANIMATIONS | PERMISSION_TRIGGER_ANIMATION);
                }
            }
            if((integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_standchange"))
            {
                llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_standtimer",(string)(llGetUnixTime()+(integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_standchange")));
            }
        }
        recordMemory();
    }
    attach(key kID)
    {
        if(kID != NULL_KEY)
        {
            check_settings(llToLower(llLinksetDataRead("addon_name"))+"_wingschange",(string)120);
            check_settings(llToLower(llLinksetDataRead("addon_name"))+"_wingsrand",(string)TRUE);
            check_settings(llToLower(llLinksetDataRead("addon_name"))+"_standchange",(string)120);
            check_settings(llToLower(llLinksetDataRead("addon_name"))+"_standrand",(string)TRUE);
            check_settings(llToLower(llLinksetDataRead("addon_name"))+"_sitanywhere",(string)FALSE);
            check_settings(llToLower(llLinksetDataRead("addon_name"))+"_sitctl",(string)FALSE);
            check_settings(llToLower(llLinksetDataRead("addon_name"))+"_sitchange",(string)120);
            check_settings(llToLower(llLinksetDataRead("addon_name"))+"_sitrand",(string)FALSE);
            check_settings(llToLower(llLinksetDataRead("addon_name"))+"_gsitchange",(string)120);
            check_settings(llToLower(llLinksetDataRead("addon_name"))+"_gsitrand",(string)FALSE);
            check_settings(llToLower(llLinksetDataRead("addon_name"))+"_walkchange",(string)120);
            check_settings(llToLower(llLinksetDataRead("addon_name"))+"_walkrand",(string)TRUE);
            check_settings(llToLower(llLinksetDataRead("addon_name"))+"_typingctl",(string)TRUE);
            if((integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_power"))
            {
                llSetTimerEvent(1);
                if((llGetPermissions() & PERMISSION_OVERRIDE_ANIMATIONS) && (llGetPermissions() & PERMISSION_TRIGGER_ANIMATION))
                {
                    llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_animstate",llGetAnimation(llGetOwner()));
                    SetAO();
                    gsitAO();
                }
                else
                {
                    llRequestPermissions((key)llGetOwner(),PERMISSION_OVERRIDE_ANIMATIONS | PERMISSION_TRIGGER_ANIMATION);
                }
            }
            recordMemory();
        }
        else
        {
            // Turn off the ao when not worn.
            if(llGetPermissions() & PERMISSION_OVERRIDE_ANIMATIONS && llGetPermissions() & PERMISSION_TRIGGER_ANIMATION)
            {
                llOwnerSay("Detaching so stoping animations!");
                //llResetAnimationOverride("ALL"); - wish it worked this way
            }
        }
    }

    run_time_permissions(integer iPerm)
    {
        if(iPerm & PERMISSION_OVERRIDE_ANIMATIONS)
        {
            SetAO();
        }
    }

    linkset_data(integer iAction,string sName,string sValue)
    {
        if( iAction == LINKSETDATA_UPDATE)
        {
            if(sName == "memory_ping")
            {
                recordMemory();
            }
            if(sName == llToLower(llLinksetDataRead("addon_name"))+"_power")
            {
                if((integer)sValue)
                {
                    llRequestPermissions(llGetOwner(),PERMISSION_OVERRIDE_ANIMATIONS | PERMISSION_TRIGGER_ANIMATION);
                    llOwnerSay("Powering AO on!");
                    llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_animstate",llGetAnimation(llGetOwner()));
                }
                else
                {
                    if(llGetPermissions()&PERMISSION_OVERRIDE_ANIMATIONS)
                    {
                        llOwnerSay("Power Removing Animations!");
                        StopAO();
                    }
                }
            }
            if((integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_power"))
            {
                if(llListFindList(g_lAnimStates,[sName]) != -1 && sValue != "" && !(integer)llLinksetDataRead(llToLower(llLinksetDataRead("addon_name"))+"_sitanywhere"))
                {
                    llResetAnimationOverride(sName);
                    llSleep(0.1);
                    llSetAnimationOverride(sName,sValue);
                }
                else if(sName == llToLower(llLinksetDataRead("addon_name"))+"_sitanywhere")
                {
                    gsitAO();
                }
                else if(sName == llToLower(llLinksetDataRead("addon_name"))+"_swiming")
                {
                    SetAO();
                }
                else if(sName == llToLower(llLinksetDataRead("addon_name"))+"_standchange" && (integer)sValue)
                {
                    if((integer)sValue < 0)
                    {
                        sValue = "0";
                    }
                    llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_standtimer",(string)(llGetUnixTime()+(integer)sValue));
                }
                else if(sName == llToLower(llLinksetDataRead("addon_name"))+"_sitctl" && !(integer)sValue)
                {
                    llResetAnimationOverride("Sitting");
                }
                else if(sName == llToLower(llLinksetDataRead("addon_name"))+"_walkchange" && (integer)sValue)
                {
                    if((integer)sValue < 0)
                    {
                        sValue = "0";
                    }
                    llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_walktimer",(string)(llGetUnixTime()+(integer)sValue));
                }
                else if(sName == llToLower(llLinksetDataRead("addon_name"))+"_sitchange" && (integer)sValue)
                {
                    if((integer)sValue < 0)
                    {
                        sValue = "0";
                    }
                    llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_sittimer",(string)(llGetUnixTime()+(integer)sValue));
                }
                else if(sName == llToLower(llLinksetDataRead("addon_name"))+"_gsitchange" && (integer)sValue)
                {
                    if((integer)sValue < 0)
                    {
                        sValue = "0";
                    }
                    llLinksetDataWrite(llToLower(llLinksetDataRead("addon_name"))+"_gsittimer",(string)(llGetUnixTime()+(integer)sValue));
                }
                else if(sName == llToLower(llLinksetDataRead("addon_name"))+"_loaded" && (integer)sValue)
                {
                    SetAO();
                }
                else if(sName == llToLower(llLinksetDataRead("addon_name"))+"_sitanywhere")
                {
                    SetAO();
                }
                else if(sName == llToLower(llLinksetDataRead("addon_name"))+"_typing")
                {
                    TypingAO();
                }
            }
        }
        else if( iAction == LINKSETDATA_RESET)
        {
            llOwnerSay("Data reset so clearing AO");
            if(llGetPermissions()&PERMISSION_OVERRIDE_ANIMATIONS)
            {
                StopAO();
            }
        }
    }
}
