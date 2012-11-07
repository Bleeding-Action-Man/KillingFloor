class KFTab_MidGamePerks extends MidGamePanel;

var automated GUISectionBackground	i_BGPerks;
var	automated KFPerkSelectListBox	lb_PerkSelect;

var automated GUISectionBackground	i_BGPerkEffects;
var automated GUIScrollTextBox		lb_PerkEffects;

var automated GUISectionBackground	i_BGPerkNextLevel;
var	automated KFPerkProgressListBox	lb_PerkProgress;

var	automated GUIButton	b_Save;

var KFSteamStatsAndAchievements KFStatsAndAchievements;


//copied stuff
var automated   GUIButton               b_Team, b_Settings, b_Browser, b_Quit, b_Favs,
                                        b_Leave, b_MapVote, b_KickVote, b_MatchSetup, b_Spec;

var() noexport  bool                    bTeamGame, bFFAGame, bNetGame;

var localized   string                  LeaveMPButtonText, LeaveSPButtonText, SpectateButtonText, JoinGameButtonText;
var localized   array<string>           ContextItems, DefaultItems;
var localized   string                  KickPlayer, BanPlayer;

var localized   string                  BuddyText;
var localized   string                  RedTeam, BlueTeam;
var             string                  PlayerStyleName;
var             GUIStyles               PlayerStyle;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local string s;
    local int i;
    local eFontScale FS;

	Super.InitComponent(MyController, MyOwner);

	s = GetSizingCaption();

	for ( i = 0; i < Controls.Length; i++ )
    {
    	if ( GUIButton(Controls[i]) != None && Controls[i] != b_Team && Controls[i] != b_Save)
        {
            GUIButton(Controls[i]).bAutoSize = true;
            GUIButton(Controls[i]).SizingCaption = s;
            GUIButton(Controls[i]).AutoSizePadding.HorzPerc = 0.04;
            GUIButton(Controls[i]).AutoSizePadding.VertPerc = 0.5;
        }
    }

    PlayerStyle = MyController.GetStyle(PlayerStyleName, fs);

	lb_PerkSelect.List.OnChange = OnPerkSelected;
}

function ShowPanel(bool bShow)
{
	super.ShowPanel(bShow);

	if ( bShow )
	{
		if ( PlayerOwner() != none )
		{
			KFStatsAndAchievements = KFSteamStatsAndAchievements(PlayerOwner().SteamStatsAndAchievements);

			if ( KFStatsAndAchievements != none )
			{
				// Initialize the List
				lb_PerkSelect.List.InitList(KFStatsAndAchievements);
				lb_PerkProgress.List.InitList();
			}
		}

		InitGRI();
	}
}

event Closed(GUIComponent Sender, bool bCancelled)
{
	KFStatsAndAchievements = none;

	super.Closed(Sender, bCancelled);
}

function string GetSizingCaption()
{
    local int i;
    local string s;

    for ( i = 0; i < Controls.Length; i++ )
    {
        if ( GUIButton(Controls[i]) != none && Controls[i] != b_Team && Controls[i] != b_Save)
        {
			if ( s == "" || Len(GUIButton(Controls[i]).Caption) > Len(s) )
            {
                s = GUIButton(Controls[i]).Caption;
            }
        }
    }

    return s;
}

function GameReplicationInfo GetGRI()
{
    return PlayerOwner().GameReplicationInfo;
}

function InitGRI()
{
    local PlayerController PC;
    local GameReplicationInfo GRI;

    GRI = GetGRI();
    PC = PlayerOwner();

    if ( PC == none || PC.PlayerReplicationInfo == none || GRI == none )
    {
        return;
    }

    bInit = False;

    if ( !bTeamGame && !bFFAGame )
    {
        if ( GRI.bTeamGame )
        {
            bTeamGame = True;
        }
        else if ( !(GRI.GameClass ~= "Engine.GameInfo") )
        {
            bFFAGame = True;
        }
    }

    bNetGame = PC.Level.NetMode != NM_StandAlone;

    if ( bNetGame )
    {
        b_Leave.Caption = LeaveMPButtonText;
    }
    else
    {
        b_Leave.Caption = LeaveSPButtonText;
    }

    if ( PC.PlayerReplicationInfo.bOnlySpectator )
    {
        b_Spec.Caption = JoinGameButtonText;
    }
    else
    {
        b_Spec.Caption = SpectateButtonText;
    }

    SetupGroups();
	//InitLists();
}

function float ItemHeight(Canvas C)
{
    local float XL, YL, H;
    local eFontScale f;

    if ( bTeamGame )
    {
        f=FNS_Medium;
    }
    else
    {
        f=FNS_Large;
    }

    PlayerStyle.TextSize(C, MSAT_Blurry, "Wqz, ", XL, H, F);

    if ( C.ClipX > 640 && bNetGame )
    {
        PlayerStyle.TextSize(C, MSAT_Blurry, "Wqz, ", XL, YL, FNS_Small);
    }

    H += YL;
    H += (H * 0.2);

    return h;
}

function SetupGroups()
{
    local int i;
    local PlayerController PC;

    PC = PlayerOwner();

    if ( bTeamGame )
    {
        //RemoveComponent(lb_FFA, True);
        //RemoveComponent(sb_FFA, true);

        if ( PC.GameReplicationInfo != None && PC.GameReplicationInfo.bNoTeamChanges )
        {
            RemoveComponent(b_Team,true);
        }

        //lb_FFA = None;
    }
    else if ( bFFAGame )
    {
        //RemoveComponent(i_JoinRed, true);
        //RemoveComponent(lb_Red, true);
        //RemoveComponent(sb_Red, true);
        RemoveComponent(b_Team, true);
    }
    else
    {
        for ( i = 0; i < Controls.Length; i++ )
        {
            if ( Controls[i] != i_BGPerks &&
			 	 Controls[i] != lb_PerkSelect &&
				 Controls[i] != i_BGPerkEffects &&
				 Controls[i] != lb_PerkEffects &&
				 Controls[i] != i_BGPerkNextLevel &&
				 Controls[i] != lb_PerkProgress &&
				 Controls[i] != b_Save )
			{
				RemoveComponent(Controls[i], True);
			}
        }
    }

    if ( PC.Level.NetMode != NM_Client )
    {
        RemoveComponent(b_Favs);
        RemoveComponent(b_Browser);
    }
    else if ( CurrentServerIsInFavorites() )
    {
        DisableComponent(b_Favs);
    }

    if ( PC.Level.NetMode == NM_StandAlone )
    {
        RemoveComponent(b_MapVote, True);
        RemoveComponent(b_MatchSetup, True);
        RemoveComponent(b_KickVote, True);
    }
    else if ( PC.VoteReplicationInfo != None )
    {
        if ( !PC.VoteReplicationInfo.MapVoteEnabled() )
        {
            RemoveComponent(b_MapVote,True);
        }

        if ( !PC.VoteReplicationInfo.KickVoteEnabled() )
        {
            RemoveComponent(b_KickVote);
        }

        if ( !PC.VoteReplicationInfo.MatchSetupEnabled() )
        {
            RemoveComponent(b_MatchSetup);
        }
    }
    else
    {
        RemoveComponent(b_MapVote);
        RemoveComponent(b_KickVote);
        RemoveComponent(b_MatchSetup);
    }

    RemapComponents();
}

function SetButtonPositions(Canvas C)
{
    local int i, j, ButtonsPerRow, ButtonsLeftInRow, NumButtons;
    local float Width, Height, Center, X, Y, YL, ButtonSpacing;

    Width = b_Settings.ActualWidth();
    Height = b_Settings.ActualHeight();
    Center = ActualLeft() + (ActualWidth() / 2.0);

    ButtonSpacing = Width * 0.05;
    YL = Height * 1.2;
    Y = b_Settings.ActualTop();

    ButtonsPerRow = ActualWidth() / (Width + ButtonSpacing);
    ButtonsLeftInRow = ButtonsPerRow;

    for ( i = 0; i < Components.Length; i++)
	{
		if ( Components[i].bVisible && GUIButton(Components[i]) != none && Components[i] != b_Team && Components[i] != b_Save )
	    {
			NumButtons++;
	    }
    }

    if ( NumButtons < ButtonsPerRow )
    {
    	X = Center - (((Width * float(NumButtons)) + (ButtonSpacing * float(NumButtons - 1))) * 0.5);
    }
    else if ( ButtonsPerRow > 1 )
    {
        X = Center - (((Width * float(ButtonsPerRow)) + (ButtonSpacing * float(ButtonsPerRow - 1))) * 0.5);
    }
    else
    {
        X = Center - Width / 2.0;
    }

    for ( i = 0; i < Components.Length; i++)
	{
		if ( !Components[i].bVisible || GUIButton(Components[i]) == none || Components[i]==b_Team || Components[i] == b_Save )
        {
            continue;
        }

        Components[i].SetPosition( X, Y, Width, Height, true );

        if ( --ButtonsLeftInRow > 0 )
        {
            X += Width + ButtonSpacing;
        }
        else
        {
            Y += YL;

            for ( j = i + 1; j < Components.Length && ButtonsLeftInRow < ButtonsPerRow; j++)
            {
                if ( Components[i].bVisible && GUIButton(Components[i]) != none && Components[i] != b_Team && Components[i] != b_Save )
                {
                    ButtonsLeftInRow++;
                }
            }

            if ( ButtonsLeftInRow > 1 )
            {
                X = Center - (((Width * float(ButtonsLeftInRow)) + (ButtonSpacing * float(ButtonsLeftInRow - 1))) * 0.5);
            }
            else
            {
                X = Center - Width / 2.0;
            }
        }
    }
}

// See if we already have this server in our favorites
function bool CurrentServerIsInFavorites()
{
    local ExtendedConsole.ServerFavorite Fav;
    local string address,portString;

    // Get current network address
    if ( PlayerOwner() == None )
    {
        return true;
    }

    address = PlayerOwner().GetServerNetworkAddress();

    if( address == "" )
    {
        return true; // slightly hacky - dont want to add "none"!
    }

    // Parse text to find IP and possibly port number
    if ( Divide(address, ":", Fav.IP, portstring) )
    {
        Fav.Port = int(portString);
    }
    else
    {
        Fav.IP = address;
    }

    return class'ExtendedConsole'.static.InFavorites(Fav);
}

function bool ButtonClicked(GUIComponent Sender)
{
    local PlayerController PC;
    local GUIController C;

    C = Controller;

    PC = PlayerOwner();

    /*if ( Sender == i_JoinRed )
    {
        //Join Red team
        if ( PC.PlayerReplicationInfo == None || PC.PlayerReplicationInfo.Team == none ||
             PC.PlayerReplicationInfo.Team.TeamIndex != 0 )
        {
            PC.ChangeTeam(0);
        }

        Controller.CloseMenu(false);
    }
    */
	if ( Sender == b_Settings )
    {
        //Settings
        Controller.OpenMenu(Controller.GetSettingsPage());
    }
    else if ( Sender == b_Browser )
    {
        //Server browser
        Controller.OpenMenu("KFGUI.KFServerBrowser");
    }
    else if ( Sender == b_Leave )
    {
		//Forfeit/Disconnect
		PC.ConsoleCommand("DISCONNECT");
        KFGUIController(C).ReturnToMainMenu();
    }
    else if ( Sender == b_Favs )
    {
        //Add this server to favorites
        PC.ConsoleCommand( "ADDCURRENTTOFAVORITES" );
        b_Favs.MenuStateChange(MSAT_Disabled);
    }
    else if ( Sender == b_Quit )
    {
        //Quit game
        Controller.OpenMenu(Controller.GetQuitPage());
    }
    else if ( Sender == b_MapVote )
    {
        //Map voting
        Controller.OpenMenu(Controller.MapVotingMenu);
    }
    else if ( Sender == b_KickVote )
    {
        //Kick voting
        Controller.OpenMenu(Controller.KickVotingMenu);
    }
    else if ( Sender == b_MatchSetup )
    {
        //Match setup
        Controller.OpenMenu(Controller.MatchSetupMenu);
    }
	else if ( Sender == b_Spec )
	{
		Controller.CloseMenu();

		//Spectate/rejoin
		if ( PC.PlayerReplicationInfo.bOnlySpectator )
		{
			PC.BecomeActivePlayer();
		}
		else
        {
            PC.BecomeSpectator();
        }
	}

	return true;
}

function bool InternalOnPreDraw(Canvas C)
{
	local GameReplicationInfo GRI;

	GRI = GetGRI();

    if ( GRI != none )
	{
		if ( bInit )
		{
			InitGRI();
		}

		/*
		if ( bTeamGame )
		{
			if ( PlayerOwner().PlayerReplicationInfo.Team != none )
			{
				sb_Red.HeaderBase = texture'InterfaceArt_tex.Menu.RODisplay';
			}
		}

	    sb_Red.SetPosition((ActualWidth() / 2.0) - ((sb_Red.WinWidth * ActualWidth()) / 2.0), sb_Red.WinTop, sb_Red.WinWidth, sb_Red.WinHeight);
		*/

		SetButtonPositions(C);
		//UpdatePlayerLists();

		if ( (PlayerOwner().myHUD == None || !PlayerOwner().myHUD.IsInCinematic()) && GRI != none && GRI.bMatchHasBegun && !PlayerOwner().IsInState('GameEnded') )
		{
        	EnableComponent(b_Spec);
        }
		else
        {
            DisableComponent(b_Spec);
        }
	}

	return false;
}

function bool ContextMenuOpened(GUIContextMenu Menu)
{
    local GUIList List;
    local PlayerReplicationInfo PRI;
    local byte Restriction;
    local GameReplicationInfo GRI;

    GRI = GetGRI();

    if ( GRI == None )
    {
        return false;
    }

    List = GUIList(Controller.ActiveControl);

    if ( List == None )
    {
        log(Name @ "ContextMenuOpened active control was not a list - active:" $ Controller.ActiveControl.Name);
        return False;
    }

    if ( !List.IsValid() )
    {
        return False;
    }

    PRI = GRI.FindPlayerByID(int(List.GetExtra()));

    if ( PRI == None || PRI.bBot || PlayerIDIsMine(PRI.PlayerID) )
    {
        return False;
    }

    Restriction = PlayerOwner().ChatManager.GetPlayerRestriction(PRI.PlayerID);

    if ( bool(Restriction & 1) )
    {
        Menu.ContextItems[0] = ContextItems[0];
    }
    else
    {
        Menu.ContextItems[0] = DefaultItems[0];
    }

    if ( bool(Restriction & 2) )
    {
        Menu.ContextItems[1] = ContextItems[1];
    }
    else
    {
        Menu.ContextItems[1] = DefaultItems[1];
    }

    if ( bool(Restriction & 4) )
    {
        Menu.ContextItems[2] = ContextItems[2];
    }
    else
    {
        Menu.ContextItems[2] = DefaultItems[2];
    }

    if ( bool(Restriction & 8) )
    {
        Menu.ContextItems[3] = ContextItems[3];
    }
    else
    {
        Menu.ContextItems[3] = DefaultItems[3];
    }

    Menu.ContextItems[4] = "-";
    Menu.ContextItems[5] = BuddyText;

    if ( PlayerOwner().PlayerReplicationInfo.bAdmin )
    {
        Menu.ContextItems[6] = "-";
        Menu.ContextItems[7] = KickPlayer $ "["$List.Get() $ "]";
        Menu.ContextItems[8] = BanPlayer $ "["$List.Get() $ "]";
    }
    else if ( Menu.ContextItems.Length > 6 )
    {
        Menu.ContextItems.Remove(6,Menu.ContextItems.Length - 6);
    }

    return True;
}

function ContextClick(GUIContextMenu Menu, int ClickIndex)
{
    local bool bUndo;
    local byte Type;
    local GUIList List;
    local PlayerController PC;
    local PlayerReplicationInfo PRI;
    local GameReplicationInfo GRI;

    GRI = GetGRI();

    if ( GRI == None )
    {
        return;
    }

    PC = PlayerOwner();
    bUndo = Menu.ContextItems[ClickIndex] == ContextItems[ClickIndex];
    List = GUIList(Controller.ActiveControl);

    if ( List == None )
    {
        return;
    }

    PRI = GRI.FindPlayerById(int(List.GetExtra()));

    if ( PRI == None )
    {
        return;
    }

    if ( ClickIndex > 5 ) // Admin stuff
    {
        switch ( ClickIndex )
        {
            case 6:
            case 7: PC.AdminCommand("admin kick"@List.GetExtra()); break;
            case 8: PC.AdminCommand("admin kickban"@List.GetExtra()); break;
        }

        return;
    }

    if ( ClickIndex > 3 )
    {
        Controller.AddBuddy(List.Get());

        return;
    }

    Type = 1 << ClickIndex;

    if ( bUndo )
    {
        if ( PC.ChatManager.ClearRestrictionID(PRI.PlayerID, Type) )
        {
            PC.ServerChatRestriction(PRI.PlayerID, PC.ChatManager.GetPlayerRestriction(PRI.PlayerID));
            ModifiedChatRestriction(Self, PRI.PlayerID);
        }
    }
    else
    {
        if ( PC.ChatManager.AddRestrictionID(PRI.PlayerID, Type) )
        {
            PC.ServerChatRestriction(PRI.PlayerID, PC.ChatManager.GetPlayerRestriction(PRI.PlayerID));
            ModifiedChatRestriction(Self, PRI.PlayerID);
        }
    }
}

function OnPerkSelected(GUIComponent Sender)
{
	if ( KFStatsAndAchievements.bUsedCheats )
	{
		lb_PerkEffects.SetContent(class'LobbyMenu'.default.PerksDisabledString);
	}
	else
	{
		lb_PerkEffects.SetContent(class'KFGameType'.default.LoadedSkills[lb_PerkSelect.GetIndex()].default.LevelEffects[KFStatsAndAchievements.PerkHighestLevelAvailable(lb_PerkSelect.GetIndex())]);

		lb_PerkProgress.List.PerkChanged(KFStatsAndAchievements, lb_PerkSelect.GetIndex());
	}
}

function bool OnSaveButtonClicked(GUIComponent Sender)
{
	local PlayerController PC;

	PC = PlayerOwner();

	class'KFPlayerController'.default.SelectedVeterancy = class'KFGameType'.default.LoadedSkills[lb_PerkSelect.GetIndex()];

	if ( KFPlayerController(PC) != none )
	{
		KFPlayerController(PC).SelectedVeterancy = class'KFGameType'.default.LoadedSkills[lb_PerkSelect.GetIndex()];
		KFPlayerController(PC).SendSelectedVeterancyToServer();
		PC.SaveConfig();
	}
	else
	{
		class'KFPlayerController'.static.StaticSaveConfig();
	}

	return true;
}

defaultproperties
{
     Begin Object Class=GUISectionBackground Name=BGPerks
         bFillClient=True
         Caption="Select Perk"
         WinTop=0.012063
         WinLeft=0.019240
         WinWidth=0.457166
         WinHeight=0.796032
         OnPreDraw=BGPerks.InternalPreDraw
     End Object
     i_BGPerks=GUISectionBackground'KFGui.KFTab_MidGamePerks.BGPerks'

     Begin Object Class=KFPerkSelectListBox Name=PerkSelectList
         OnCreateComponent=PerkSelectList.InternalOnCreateComponent
         WinTop=0.057760
         WinLeft=0.029240
         WinWidth=0.437166
         WinHeight=0.742836
     End Object
     lb_PerkSelect=KFPerkSelectListBox'KFGui.KFTab_MidGamePerks.PerkSelectList'

     Begin Object Class=GUISectionBackground Name=BGPerkEffects
         bFillClient=True
         Caption="Perk Effects"
         WinTop=0.012063
         WinLeft=0.486700
         WinWidth=0.491566
         WinHeight=0.366816
         OnPreDraw=BGPerkEffects.InternalPreDraw
     End Object
     i_BGPerkEffects=GUISectionBackground'KFGui.KFTab_MidGamePerks.BGPerkEffects'

     Begin Object Class=GUIScrollTextBox Name=PerkEffectsScroll
         CharDelay=0.002500
         EOLDelay=0.100000
         OnCreateComponent=PerkEffectsScroll.InternalOnCreateComponent
         WinTop=0.093121
         WinLeft=0.500554
         WinWidth=0.465143
         WinHeight=0.323477
         TabOrder=9
     End Object
     lb_PerkEffects=GUIScrollTextBox'KFGui.KFTab_MidGamePerks.PerkEffectsScroll'

     Begin Object Class=GUISectionBackground Name=BGPerksNextLevel
         bFillClient=True
         Caption="Next Level Requirements"
         WinTop=0.392889
         WinLeft=0.486700
         WinWidth=0.490282
         WinHeight=0.415466
         OnPreDraw=BGPerksNextLevel.InternalPreDraw
     End Object
     i_BGPerkNextLevel=GUISectionBackground'KFGui.KFTab_MidGamePerks.BGPerksNextLevel'

     Begin Object Class=KFPerkProgressListBox Name=PerkProgressList
         OnCreateComponent=PerkProgressList.InternalOnCreateComponent
         WinTop=0.476850
         WinLeft=0.499269
         WinWidth=0.463858
         WinHeight=0.341256
     End Object
     lb_PerkProgress=KFPerkProgressListBox'KFGui.KFTab_MidGamePerks.PerkProgressList'

     Begin Object Class=GUIButton Name=SaveButton
         Caption="Select Perk"
         Hint="Use Selected Perk"
         WinTop=0.822807
         WinLeft=0.302670
         WinWidth=0.363829
         WinHeight=0.042757
         TabOrder=2
         bBoundToParent=True
         OnClick=KFTab_MidGamePerks.OnSaveButtonClicked
         OnKeyEvent=SaveButton.InternalOnKeyEvent
     End Object
     b_Save=GUIButton'KFGui.KFTab_MidGamePerks.SaveButton'

     Begin Object Class=GUIButton Name=SettingsButton
         Caption="Settings"
         WinTop=0.878657
         WinLeft=0.194420
         WinWidth=0.147268
         WinHeight=0.048769
         TabOrder=0
         bBoundToParent=True
         bScaleToParent=True
         OnClick=KFTab_MidGamePerks.ButtonClicked
         OnKeyEvent=SettingsButton.InternalOnKeyEvent
     End Object
     b_Settings=GUIButton'KFGui.KFTab_MidGamePerks.SettingsButton'

     Begin Object Class=GUIButton Name=BrowserButton
         Caption="Server Browser"
         bAutoSize=True
         WinTop=0.850000
         WinLeft=0.375000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=1
         bBoundToParent=True
         bScaleToParent=True
         OnClick=KFTab_MidGamePerks.ButtonClicked
         OnKeyEvent=BrowserButton.InternalOnKeyEvent
     End Object
     b_Browser=GUIButton'KFGui.KFTab_MidGamePerks.BrowserButton'

     Begin Object Class=GUIButton Name=QuitGameButton
         Caption="Exit Game"
         bAutoSize=True
         WinTop=0.870000
         WinLeft=0.725000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=11
         OnClick=KFTab_MidGamePerks.ButtonClicked
         OnKeyEvent=QuitGameButton.InternalOnKeyEvent
     End Object
     b_Quit=GUIButton'KFGui.KFTab_MidGamePerks.QuitGameButton'

     Begin Object Class=GUIButton Name=FavoritesButton
         Caption="Add to Favs"
         bAutoSize=True
         Hint="Add this server to your Favorites"
         WinTop=0.870000
         WinLeft=0.025000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=3
         bBoundToParent=True
         bScaleToParent=True
         OnClick=KFTab_MidGamePerks.ButtonClicked
         OnKeyEvent=FavoritesButton.InternalOnKeyEvent
     End Object
     b_Favs=GUIButton'KFGui.KFTab_MidGamePerks.FavoritesButton'

     Begin Object Class=GUIButton Name=LeaveMatchButton
         bAutoSize=True
         WinTop=0.870000
         WinLeft=0.725000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=10
         bBoundToParent=True
         bScaleToParent=True
         OnClick=KFTab_MidGamePerks.ButtonClicked
         OnKeyEvent=LeaveMatchButton.InternalOnKeyEvent
     End Object
     b_Leave=GUIButton'KFGui.KFTab_MidGamePerks.LeaveMatchButton'

     Begin Object Class=GUIButton Name=MapVotingButton
         Caption="Map Voting"
         bAutoSize=True
         WinTop=0.890000
         WinLeft=0.025000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=5
         OnClick=KFTab_MidGamePerks.ButtonClicked
         OnKeyEvent=MapVotingButton.InternalOnKeyEvent
     End Object
     b_MapVote=GUIButton'KFGui.KFTab_MidGamePerks.MapVotingButton'

     Begin Object Class=GUIButton Name=KickVotingButton
         Caption="Kick Voting"
         bAutoSize=True
         WinTop=0.890000
         WinLeft=0.375000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=6
         OnClick=KFTab_MidGamePerks.ButtonClicked
         OnKeyEvent=KickVotingButton.InternalOnKeyEvent
     End Object
     b_KickVote=GUIButton'KFGui.KFTab_MidGamePerks.KickVotingButton'

     Begin Object Class=GUIButton Name=MatchSetupButton
         Caption="Match Setup"
         bAutoSize=True
         WinTop=0.890000
         WinLeft=0.725000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=7
         OnClick=KFTab_MidGamePerks.ButtonClicked
         OnKeyEvent=MatchSetupButton.InternalOnKeyEvent
     End Object
     b_MatchSetup=GUIButton'KFGui.KFTab_MidGamePerks.MatchSetupButton'

     Begin Object Class=GUIButton Name=SpectateButton
         Caption="Spectate"
         bAutoSize=True
         WinTop=0.890000
         WinLeft=0.725000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=9
         OnClick=KFTab_MidGamePerks.ButtonClicked
         OnKeyEvent=SpectateButton.InternalOnKeyEvent
     End Object
     b_Spec=GUIButton'KFGui.KFTab_MidGamePerks.SpectateButton'

     LeaveMPButtonText="Disconnect"
     LeaveSPButtonText="Forfeit"
     SpectateButtonText="Spectate"
     JoinGameButtonText="Join"
     ContextItems(0)="Unignore text"
     ContextItems(1)="Unignore speech"
     ContextItems(2)="Unignore voice chat"
     ContextItems(3)="Unban from voice chat"
     DefaultItems(0)="Ignore text"
     DefaultItems(1)="Ignore speech"
     DefaultItems(2)="Ignore voice chat"
     DefaultItems(3)="Ban from voice chat"
     KickPlayer="Kick "
     BanPlayer="Ban "
     PlayerStyleName="TextLabel"
     PropagateVisibility=False
     WinTop=0.125000
     WinLeft=0.250000
     WinWidth=0.500000
     WinHeight=0.750000
     Begin Object Class=GUIContextMenu Name=PlayerListContextMenu
         OnOpen=KFTab_MidGamePerks.ContextMenuOpened
         OnSelect=KFTab_MidGamePerks.ContextClick
     End Object
     ContextMenu=GUIContextMenu'KFGui.KFTab_MidGamePerks.PlayerListContextMenu'

     OnPreDraw=KFTab_MidGamePerks.InternalOnPreDraw
}
