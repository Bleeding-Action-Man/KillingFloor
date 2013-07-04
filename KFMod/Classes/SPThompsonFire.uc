//=============================================================================
// SPThompsonFire
//=============================================================================
// Steampunk Thompson SMG primary fire class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - IJC Weapon Development and John "Ramm-Jaeger" Gibson
//=============================================================================
class SPThompsonFire extends KFHighROFFire;

defaultproperties
{
     FireEndSoundRef="KF_SP_ThompsonSnd.SP_Thompson_Fire_LoopEnd_M"
     FireEndStereoSoundRef="KF_SP_ThompsonSnd.SP_Thompson_Fire_LoopEnd_S"
     AmbientFireSoundRef="KF_SP_ThompsonSnd.SP_Thompson_Fire_Loop"
     RecoilRate=0.080000
     maxVerticalRecoilAngle=140
     maxHorizontalRecoilAngle=100
     ShellEjectClass=Class'ROEffects.KFShellEjectMP5SMG'
     ShellEjectBoneName="Shell_eject"
     bRandomPitchFireSound=False
     FireSoundRef="KF_SP_ThompsonSnd.SP_Thompson_Fire_Single_M"
     StereoFireSoundRef="KF_SP_ThompsonSnd.SP_Thompson_Fire_Single_S"
     NoAmmoSoundRef="KF_AK47Snd.AK47_DryFire"
     DamageType=Class'KFMod.DamTypeSPThompson'
     DamageMin=35
     DamageMax=40
     Momentum=12500.000000
     FireRate=0.085700
     AmmoClass=Class'KFMod.SPThompsonAmmo'
     ShakeRotMag=(X=50.000000,Y=50.000000,Z=350.000000)
     ShakeRotRate=(X=5000.000000,Y=5000.000000,Z=5000.000000)
     ShakeRotTime=0.750000
     ShakeOffsetMag=(X=6.000000,Y=3.000000,Z=7.500000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=1.250000
     BotRefireRate=0.150000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stSPThompson'
     aimerror=42.000000
     Spread=0.009500
     SpreadStyle=SS_Random
}
