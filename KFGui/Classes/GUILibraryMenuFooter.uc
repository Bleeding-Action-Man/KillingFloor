class GUILibraryMenuFooter extends ButtonFooter;

var automated GUIButton b_Buy,b_Cancel,b_Complete,b_AutoAll,b_Fill;
var automated GUIButton spacer1,spacer2;
var automated GUILabel l_score,l_weight;

function PositionButtons (Canvas C)
{
	local int i;
	local GUIButton b;
	local float x;

	for ( i = 0; i < Controls.Length; i++ )
	{
		b = GUIButton(Controls[i]);
		if ( b != None)
		{
			if ( x == 0 )
				x = ButtonLeft;
			else x += GetSpacer();
			b.WinLeft = b.RelativeLeft( x, True );
			x += b.ActualWidth();
		}
	}
}

function SetPlayerStats(int score, float weight)
{
	 l_score.Caption = "Cash:"@score;
	 l_weight.Caption = "Weight:"@weight;
}

function SetBuyMode(string buyCaption,bool buyEnabled,bool fillVisible,bool fillEnabled)
{
	local bool AutoAmmoEnabled;
	AutoAmmoEnabled = GUILibraryMenu(PageOwner).CanAutoAmmo();
	b_buy.Caption = buyCaption;
	if(buyEnabled && b_buy.MenuState == MSAT_Disabled)
	{
		b_buy.MenuState = MSAT_Blurry;              //    GUILibraryMenu(PageOwner).ItemsBox.List.Elements[GUILibraryMenu(PageOwner).ItemsBox.List.Index]                                   // 
             //   GUILibraryMenu(PageOwner).ItemsBox.List.MenuState = MSAT_Blurry;
        }
        else if(!buyEnabled)
	{
        	b_buy.MenuState = MSAT_Disabled;
             //   GUILibraryMenu(PageOwner).ItemsBox.List.MenuState = MSAT_Disabled;
        }

	if(fillEnabled && b_fill.MenuState == MSAT_Disabled)
		b_fill.MenuState = MSAT_Blurry;
	else if(!fillEnabled)
		b_fill.MenuState = MSAT_Disabled;
	b_fill.bVisible = fillVisible;

	if(AutoAmmoEnabled && b_AutoAll.MenuState == MSAT_Disabled)
		b_AutoAll.MenuState = MSAT_Blurry;
	else if(!AutoAmmoEnabled)
	   b_AutoAll.MenuState = MSAT_Disabled;
}

function bool ButtonsSized(Canvas C)
{
	local int i;
	local GUIButton b;
	local bool bResult;
	local string str;
	local float T, AH, AT;

	if ( !bPositioned )
		return false;

	bResult = true;
	str = GetLongestCaption(C);

	AH = ActualHeight();
	AT = ActualTop();

	for (i = 0; i < Controls.Length; i++ )
	{
		b = GUIButton(Controls[i]);
		if ( b != None )
		{
			if ( bAutoSize && bFixedWidth )
			{
			    if(b.Caption == "")
			        b.SizingCaption = Left(str,Len(str)/2);
				else
					b.SizingCaption = str;
			}
			else b.SizingCaption = "";

			bResult = bResult && b.bPositioned;
			if ( bFullHeight )
				b.WinHeight = b.RelativeHeight(AH,true);
			else b.WinHeight = b.RelativeHeight(ActualHeight(ButtonHeight),true);

			switch ( Justification )
			{
			case TXTA_Left:
				T = ClientBounds[1];
				break;

			case TXTA_Center:
				T = (AT + AH / 2) - (b.ActualHeight() / 2);
				break;

			case TXTA_Right:
				T = ClientBounds[3] - b.ActualHeight();
				break;
			}

//			b.WinTop = b.RelativeTop(T, True );
			b.WinTop = b.RelativeTop(T, true ) + ((WinHeight - ButtonHeight) / 2);
		}
	}

	return bResult;
}

function float GetButtonLeft()
{
	local int i;
	local GUIButton b;
	local float TotalWidth, AW, AL;
	local float FooterMargin;

	AL = ActualLeft();
	AW = ActualWidth();
	FooterMargin = GetMargin();

	for (i = 0; i < Controls.Length; i++ )
	{
		b = GUIButton(Controls[i]);
		if ( b != None )
		{
			if ( TotalWidth > 0 )
				TotalWidth += GetSpacer();

			TotalWidth += b.ActualWidth();
		}
	}

	if ( Alignment == TXTA_Center )
		return (AL + AW) / 2 - FooterMargin / 2 - TotalWidth / 2;

	if ( Alignment == TXTA_Right )
		return (AL + AW - FooterMargin / 2) - TotalWidth;

	return AL + (FooterMargin / 2);
}

// Finds the longest caption of all the buttons
function string GetLongestCaption(Canvas C)
{
	local int i;
	local float XL, YL, LongestW;
	local string str;
	local GUIButton b;

	if ( C == None )
		return "";

	for ( i = 0; i < Controls.Length; i++ )
	{
		b = GUIButton(Controls[i]);
		if ( b != None )
		{
			if ( b.Style != None )
				b.Style.TextSize(C, b.MenuState, b.Caption, XL, YL, b.FontScale);
			else C.StrLen( b.Caption, XL, YL );

			if ( LongestW == 0 || XL > LongestW )
			{
				str = b.Caption;
				LongestW = XL;
			}
		}
	}

	return str;
}

function bool OnFooterClick(GUIComponent Sender)
{
	if(Sender == b_Complete)
	{
		GUILibraryMenu(PageOwner).CloseSale(true);
	} else if(Sender == b_Cancel)
	{
		GUILibraryMenu(PageOwner).CloseSale(false);
	} else if(Sender == b_Buy)
	{
		GUILibraryMenu(PageOwner).BuyCurrent();
	} else if(Sender == b_Fill)
	{
		GUILibraryMenu(PageOwner).BuyFill();
	} else if(Sender == b_AutoAll)
	{
		GUILibraryMenu(PageOwner).DoAutoAmmo();
	}
	return false;
}

defaultproperties
{
     Begin Object Class=GUIButton Name=Purchase
         Caption="Buy"
         StyleName="FooterButton"
         Hint="Buy currently selected weapon"
         WinTop=0.966146
         WinLeft=0.280000
         WinWidth=0.120000
         WinHeight=0.033203
         RenderWeight=2.000000
         TabOrder=3
         bBoundToParent=True
         OnClick=GUILibraryMenuFooter.OnFooterClick
         OnKeyEvent=Purchase.InternalOnKeyEvent
     End Object
     b_Buy=GUIButton'KFGui.GUILibraryMenuFooter.Purchase'

     Begin Object Class=GUIButton Name=Cancel
         Caption="Cancel"
         StyleName="FooterButton"
         Hint="Don't buy these weapons."
         WinTop=0.966146
         WinLeft=0.350000
         WinWidth=0.120000
         WinHeight=0.033203
         RenderWeight=2.000000
         TabOrder=5
         bBoundToParent=True
         OnClick=GUILibraryMenuFooter.OnFooterClick
         OnKeyEvent=Cancel.InternalOnKeyEvent
     End Object
     b_Cancel=GUIButton'KFGui.GUILibraryMenuFooter.Cancel'

     Begin Object Class=GUIButton Name=Complete
         Caption="Complete"
         StyleName="FooterButton"
         Hint="Purchase weapons and save changes."
         WinTop=0.966146
         WinLeft=0.380000
         WinWidth=0.120000
         WinHeight=0.033203
         RenderWeight=2.000000
         TabOrder=6
         bBoundToParent=True
         OnClick=GUILibraryMenuFooter.OnFooterClick
         OnKeyEvent=Complete.InternalOnKeyEvent
     End Object
     b_Complete=GUIButton'KFGui.GUILibraryMenuFooter.Complete'

     Begin Object Class=GUIButton Name=AutoAmmo
         Caption="AutoAmmo"
         StyleName="FooterButton"
         Hint="Fill ammo for all weapons."
         WinTop=0.966146
         WinLeft=0.200000
         WinWidth=0.120000
         RenderWeight=2.000000
         TabOrder=0
         bBoundToParent=True
         OnClick=GUILibraryMenuFooter.OnFooterClick
         OnKeyEvent=AutoAmmo.InternalOnKeyEvent
     End Object
     b_AutoAll=GUIButton'KFGui.GUILibraryMenuFooter.AutoAmmo'

     Begin Object Class=GUIButton Name=Fill
         Caption="Fill Up"
         StyleName="FooterButton"
         Hint="Fill up on currently selected ammo."
         WinTop=0.966146
         WinLeft=0.250000
         WinWidth=0.120000
         RenderWeight=2.000000
         TabOrder=2
         bBoundToParent=True
         bVisible=False
         OnClick=GUILibraryMenuFooter.OnFooterClick
         OnKeyEvent=Fill.InternalOnKeyEvent
     End Object
     b_Fill=GUIButton'KFGui.GUILibraryMenuFooter.Fill'

     Begin Object Class=GUIButton Name=Sp
         StyleName="Footerbutton"
         WinTop=0.966146
         WinLeft=0.220000
         WinWidth=0.120000
         RenderWeight=2.000000
         TabOrder=1
         bBoundToParent=True
         bVisible=False
         OnKeyEvent=Sp.InternalOnKeyEvent
     End Object
     spacer1=GUIButton'KFGui.GUILibraryMenuFooter.Sp'

     Begin Object Class=GUIButton Name=sp2
         StyleName="Footerbutton"
         WinTop=0.966146
         WinLeft=0.330000
         WinWidth=0.120000
         RenderWeight=2.000000
         TabOrder=4
         bBoundToParent=True
         bVisible=False
         OnKeyEvent=sp2.InternalOnKeyEvent
     End Object
     spacer2=GUIButton'KFGui.GUILibraryMenuFooter.sp2'

     Begin Object Class=GUILabel Name=PlayerScore
         Caption="Cash: 0"
         StyleName="FooterButton"
         WinTop=0.966146
         WinLeft=0.010000
         WinHeight=0.033203
     End Object
     l_score=GUILabel'KFGui.GUILibraryMenuFooter.PlayerScore'

     Begin Object Class=GUILabel Name=playerweight
         Caption="Weight: 0.0"
         StyleName="FooterButton"
         WinTop=0.966146
         WinLeft=0.130000
         WinHeight=0.033203
     End Object
     l_weight=GUILabel'KFGui.GUILibraryMenuFooter.playerweight'

}
