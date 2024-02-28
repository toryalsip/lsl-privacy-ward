// Magic Ward of Privacy script
// This script will eject people who stops in the parcel
// You can turn on/off the ward by clicking the object that contains this script
// The owner or the people who are in white list will not be affected

// Please copy and paste this content to a brand new script in your inventory
// then adjust the following script parameters to your needs
// After that if it was created in your inventory, add that script to an object in your parcel to use it

// Please add UUID of the people who should be ignored (thus permitted to enter the parcel) by the script
// The entries currently written in the white list are just examples
// As long as UUID is written, you don't need to include the name as shown in the example
string WHITE_LIST = "

388b3d01-e63c-41f5-b146-dd373e433064 Example 1
c1675eb6-37f2-426a-a61c-208dc526678e Example 2

";

// The speed of which the script will consider the person is moving and not need to eject can be set below
// By the way, the speed of walking is 3.2, running is 5.4, and flying with avatar is about 15 m/s
float MIN_VELOCITY = 0.1;

// The frequency of the script to check the situation can be set below
float CYCLE = 1;

// The message to be sent when the script ejects someone can be set blow, leave it blank if you don't want to send any message
string EJECT_MESSAGE = "You are not allowed to stop at this parcel, please move on";

// The following is the main body of the script ========================================================
key     owner;
integer auto_eject;

default
{
    on_rez(integer i)
    {
        llResetScript();
    }

    state_entry()
    {
        owner = llGetOwner();
        WHITE_LIST = llToLower(WHITE_LIST);
        llOwnerSay("The magic ward is ready, click to enable");

        // メモリ節約の呪文
        llSetMemoryLimit(llGetUsedMemory() +  2048);
    }

    touch_start(integer n)
    {
        if(llDetectedKey(0) != owner)
            return;

        auto_eject = !auto_eject;
        if(auto_eject)
        {
            llSetTimerEvent(CYCLE);
            llOwnerSay("The magic ward is now Enabled");
        }
        else
        {
            llSetTimerEvent(0);
            llOwnerSay("The magic ward is now Disabled");
        }
    }

    timer()
    {
        if(!auto_eject)
            return;

        list agents_in_parcel = llGetAgentList(AGENT_LIST_PARCEL, []);
        integer i = llGetListLength(agents_in_parcel);
        while(--i >= 0)
        {
            key agent_key = llList2Key(agents_in_parcel, i);
            if(agent_key != owner && llSubStringIndex(WHITE_LIST, (string)agent_key) == -1)
                if(MIN_VELOCITY > llVecMag(llList2Vector(llGetObjectDetails(agent_key, [OBJECT_VELOCITY]), 0)))
                {
                    llEjectFromLand(agent_key);
                    if(EJECT_MESSAGE)
                        llRegionSayTo(agent_key, 0, EJECT_MESSAGE);
                    llInstantMessage(owner, "secondlife:///app/agent/" + (string)agent_key + "/about was ejected from the parcel by the magic ward");
                }
        }
    }
}
